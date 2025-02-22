import SwiftUI
import PDFKit
import SwiftData

@Model
class SavedPDF {
    var id: UUID
    var fileName: String
    var dateCreated: Date
    
    init(fileName: String) {
        self.id = UUID()
        self.fileName = fileName
        self.dateCreated = Date()
    }
}

extension PDFView {
    private func saveCurrentPDF() {
        guard let sourceURL = currentPDFPath else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "FlightLog_\(dateFormatter.string(from: Date())).pdf"
        
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationURL = documentsURL.appendingPathComponent(fileName)
            
            do {
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                let savedPDF = SavedPDF(fileName: fileName)
                modelContext.insert(savedPDF)
                pdfDocument = nil
                currentPDFPath = nil
            } catch {
                print("Error saving PDF: \(error)")
            }
        }
    }

    private func loadSavedPDF(fileName: String) {
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            if let document = PDFDocument(url: fileURL) {
                pdfDocument = document
                currentPDFPath = fileURL
            }
        }
    }

    private func deleteSavedPDFs(at offsets: IndexSet) {
        for index in offsets {
            let pdfToDelete = savedPDFs[index]
            
            // Delete file from documents directory
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsURL.appendingPathComponent(pdfToDelete.fileName)
                try? FileManager.default.removeItem(at: fileURL)
            }
            
            // Delete record from SwiftData
            modelContext.delete(pdfToDelete)
        }
    }
}

struct PDFView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var flightLogs: [FlightLogEntry]
    @Query private var savedPDFs: [SavedPDF]
    @State private var pdfDocument: PDFDocument?
    @State private var showGenerateButton = true
    @State private var currentPDFPath: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                if let document = pdfDocument {
                    VStack {
                        PDFKitView(document: document)
                        Button(action: saveCurrentPDF) {
                            Text("Save PDF")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .navigationTitle("Flight Logbook PDF")
                } else {
                    List {
                        Section {
                            if showGenerateButton {
                                Button(action: generatePDF) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Generate New Flight Logbook PDF")
                                    }
                                }
                            } else {
                                ProgressView("Generating PDF...")
                            }
                        }
                        
                        Section("Saved PDFs") {
                            ForEach(savedPDFs) { savedPDF in
                                HStack {
                                    Button(action: { loadSavedPDF(fileName: savedPDF.fileName) }) {
                                        HStack {
                                            Image(systemName: "doc.fill")
                                            VStack(alignment: .leading) {
                                                Text(savedPDF.fileName)
                                                    .font(.headline)
                                                Text(savedPDF.dateCreated, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: deleteSavedPDFs)
                        }
                    }
                    .navigationTitle("PDF Viewer")
                }
            }
            .toolbar {
                if pdfDocument == nil {
                    EditButton()
                } else {
                    Button("Done") {
                        pdfDocument = nil
                        currentPDFPath = nil
                    }
                }
            }
        }
    }
}

extension PDFView {
    private func generatePDF() {
        showGenerateButton = false

            let pdfMetaData = [
                kCGPDFContextCreator: "Flight Logbook App",
                kCGPDFContextAuthor: "Generated by App"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]

            let pageWidth: CGFloat = 841.89
            let pageHeight: CGFloat = 595.28
            let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

            let data = renderer.pdfData { context in
                context.beginPage()

                let titleFont = UIFont.boldSystemFont(ofSize: 24)
                let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
                let titleString = "Flight Logbook"
                let titleStringSize = titleString.size(withAttributes: titleAttributes)
                let titleX = (pageWidth - titleStringSize.width) / 2
                titleString.draw(at: CGPoint(x: titleX, y: 40), withAttributes: titleAttributes)

                let headers = ["Date", "Pilot", "Aircraft", "From", "To", "Duration", "T/O", "Ldg"]
                let columnWidths: [CGFloat] = [100, 150, 150, 100, 100, 100, 50, 50]
                let startY: CGFloat = 100
                let rowHeight: CGFloat = 35
                var currentX: CGFloat = 40
                var currentY = startY

                let headerFont = UIFont.boldSystemFont(ofSize: 14)
                let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont]

                context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
                context.cgContext.fill(CGRect(x: 40, y: currentY, width: pageWidth - 80, height: rowHeight))

                for (index, header) in headers.enumerated() {
                    let rect = CGRect(x: currentX, y: currentY, width: columnWidths[index], height: rowHeight)
                    header.draw(in: rect, withAttributes: headerAttributes)
                    currentX += columnWidths[index]
                }

                context.cgContext.setLineWidth(1.0)
                context.cgContext.move(to: CGPoint(x: 40, y: currentY + rowHeight))
                context.cgContext.addLine(to: CGPoint(x: pageWidth - 40, y: currentY + rowHeight))
                context.cgContext.strokePath()

                let dataFont = UIFont.systemFont(ofSize: 12)
                let dataAttributes: [NSAttributedString.Key: Any] = [.font: dataFont]

                currentY += rowHeight
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short

                for log in flightLogs {
                    if currentY + rowHeight > pageHeight - 50 {
                        context.beginPage()
                        currentY = 50
                    }

                    currentX = 40
                    let date = dateFormatter.string(from: log.date)

                    let rowData = [
                        date,
                        log.pilotName,
                        log.aircraft,
                        log.departureLocation,
                        log.arrivalLocation,
                        log.duration,
                        String(log.takeoffs),
                        String(log.landings)
                    ]

                    for (index, data) in rowData.enumerated() {
                        let rect = CGRect(x: currentX, y: currentY, width: columnWidths[index], height: rowHeight)
                        data.draw(in: rect, withAttributes: dataAttributes)
                        currentX += columnWidths[index]
                    }

                    currentY += rowHeight

                    context.cgContext.setLineWidth(0.5)
                    context.cgContext.move(to: CGPoint(x: 40, y: currentY))
                    context.cgContext.addLine(to: CGPoint(x: pageWidth - 40, y: currentY))
                    context.cgContext.strokePath()
                }
            }

            pdfDocument = PDFDocument(data: data)
            showGenerateButton = true
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFKit.PDFView, context: Context) {
        // No updates needed
    }
}