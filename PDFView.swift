//
//  PDFView.swift
//  LOGBOOKAPP
//
//  Created by Mathew Bellamy on 19/02/2025.
//


import SwiftUI
import PDFKit

struct PDFView: View {
    // Sample PDF file name (ensure this file exists in your project bundle)
    private let samplePDFFileName = "SampleDocument"

    var body: some View {
        NavigationView {
            if let pdfDocument = loadPDF(named: samplePDFFileName) {
                PDFKitView(document: pdfDocument)
                    .navigationTitle("PDF Viewer")
            } else {
                Text("Unable to load PDF document.")
                    .font(.headline)
                    .foregroundColor(.red)
                    .navigationTitle("PDF Viewer")
            }
        }
    }

    // Helper function to load a PDF document from the app bundle
    private func loadPDF(named fileName: String) -> PDFDocument? {
        if let filePath = Bundle.main.url(forResource: fileName, withExtension: "pdf") {
            return PDFDocument(url: filePath)
        }
        return nil
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
        // No updates needed for now
    }
}

struct PDFView_Previews: PreviewProvider {
    static var previews: some View {
        PDFView()
    }
}
