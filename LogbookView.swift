import SwiftUI
import SwiftData

@Model
class FlightLogEntry {
    var id: UUID
    var date: Date
    var pilotName: String
    var designation: String
    var aircraft: String
    var departureLocation: String
    var departureTime: Date
    var arrivalLocation: String
    var arrivalTime: Date
    var dayNight: String
    var takeoffs: Int
    var landings: Int
    var duration: String
    var remarks: String
    
    init(date: Date = Date(), pilotName: String = "", designation: String = "", aircraft: String = "",
         departureLocation: String = "", departureTime: Date = Date(),
         arrivalLocation: String = "", arrivalTime: Date = Date(),
         dayNight: String = "Day", takeoffs: Int = 0, landings: Int = 0,
         duration: String = "", remarks: String = "") {
        self.id = UUID()
        self.date = date
        self.pilotName = pilotName
        self.designation = designation
        self.aircraft = aircraft
        self.departureLocation = departureLocation
        self.departureTime = departureTime
        self.arrivalLocation = arrivalLocation
        self.arrivalTime = arrivalTime
        self.dayNight = dayNight
        self.takeoffs = takeoffs
        self.landings = landings
        self.duration = duration
        self.remarks = remarks
    }
}

struct FlightDetailView: View {
    let log: FlightLogEntry
    
    var body: some View {
        List {
            Section("Flight Information") {
                Text(log.date, format: Date.FormatStyle().day().month().year())
                Text("Pilot: \(log.pilotName)")
                Text("Designation: \(log.designation)")
                Text("Aircraft: \(log.aircraft)")
                Text("Duration: \(log.duration)")
            }
            
            Section("Route") {
                Text("Departure: \(log.departureLocation)")
                Text("Departure Time: \(log.departureTime.formatted(date: .omitted, time: .shortened))")
                Text("Arrival: \(log.arrivalLocation)")
                Text("Arrival Time: \(log.arrivalTime.formatted(date: .omitted, time: .shortened))")
            }
            
            Section("Flight Details") {
                Text("Day/Night: \(log.dayNight)")
                Text("Takeoffs: \(log.takeoffs)")
                Text("Landings: \(log.landings)")
            }
            
            if !log.remarks.isEmpty {
                Section("Remarks & Endorsements") {
                    Text(log.remarks)
                }
            }
        }
        .navigationTitle("Flight Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LogbookView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var flightLogs: [FlightLogEntry]
    @State private var isShowingAddForm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                List {
                    ForEach(flightLogs) { log in
                        NavigationLink(destination: FlightDetailView(log: log)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(log.date, format: .dateTime.day().month().year())
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("Pilot:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(log.pilotName)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                
                                HStack {
                                    Text("Aircraft:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(log.aircraft)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                
                                HStack {
                                    Text("Route:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("\(log.departureLocation) → \(log.arrivalLocation)")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Logbook")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isShowingAddForm = true }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $isShowingAddForm) {
                AddFlightLogView(isPresented: $isShowingAddForm)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(flightLogs[index])
            }
        }
    }
}

struct AddFlightLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @Query private var pilots: [Pilot]
    @Query private var aircraft: [Aircraft]
    @Query private var airfields: [Airfield]
    
    @State private var date = Date()
    @State private var selectedPilot = ""
    @State private var designation = "PIC"
    @State private var selectedAircraft = ""
    @State private var departureLocation = ""
    @State private var departureTime = Date()
    @State private var arrivalLocation = ""
    @State private var arrivalTime = Date()
    @State private var dayNight = "Day"
    @State private var takeoffs = 0
    @State private var landings = 0
    @State private var remarks = ""
    
    let designationOptions = ["PIC", "P/UT"]
    let dayNightOptions = ["Day", "Night"]
    
    private var calculatedDuration: String {
        let timeInterval = arrivalTime.timeIntervalSince(departureTime)
        let totalMinutes = Int(ceil(timeInterval / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if totalMinutes <= 0 {
            return "00:00"
        }
        
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Basic Information")) {
                        DatePicker("Date", selection: $date, displayedComponents: [.date])
                        
                        Picker("Pilot", selection: $selectedPilot) {
                            Text("Select Pilot").tag("")
                            ForEach(pilots) { pilot in
                                Text(pilot.name)
                                    .tag(pilot.name)
                            }
                        }
                        
                        Picker("Designation", selection: $designation) {
                            ForEach(designationOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        
                        Picker("Aircraft", selection: $selectedAircraft) {
                            Text("Select Aircraft").tag("")
                            ForEach(aircraft) { aircraft in
                                Text("\(aircraft.registration) - \(aircraft.make) \(aircraft.model)")
                                    .tag(aircraft.registration)
                            }
                        }
                    }
                    
                    Section(header: Text("Departure")) {
                        Picker("Location", selection: $departureLocation) {
                            Text("Select Location").tag("")
                            ForEach(airfields) { airfield in
                                Text("\(airfield.code) - \(airfield.name ?? "")")
                                    .tag(airfield.code)
                            }
                        }
                        
                        DatePicker("Time", selection: $departureTime, displayedComponents: [.hourAndMinute])
                    }
                    
                    Section(header: Text("Arrival")) {
                        Picker("Location", selection: $arrivalLocation) {
                            Text("Select Location").tag("")
                            ForEach(airfields) { airfield in
                                Text("\(airfield.code) - \(airfield.name ?? "")")
                                    .tag(airfield.code)
                            }
                        }
                        
                        DatePicker("Time", selection: $arrivalTime, displayedComponents: [.hourAndMinute])
                    }
                    
                    Section(header: Text("Flight Details")) {
                        Picker("Day/Night", selection: $dayNight) {
                            ForEach(dayNightOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        
                        Stepper("Takeoffs: \(takeoffs)", value: $takeoffs, in: 0...99)
                        Stepper("Landings: \(landings)", value: $landings, in: 0...99)
                        
                        HStack {
                            Text("Duration:")
                            Spacer()
                            Text(calculatedDuration)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section(header: Text("Remarks & Endorsements")) {
                        TextEditor(text: $remarks)
                            .frame(height: 100)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Flight Log")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    let newEntry = FlightLogEntry(
                        date: date,
                        pilotName: selectedPilot,
                        designation: designation,
                        aircraft: selectedAircraft,
                        departureLocation: departureLocation,
                        departureTime: departureTime,
                        arrivalLocation: arrivalLocation,
                        arrivalTime: arrivalTime,
                        dayNight: dayNight,
                        takeoffs: takeoffs,
                        landings: landings,
                        duration: calculatedDuration,
                        remarks: remarks
                    )
                    modelContext.insert(newEntry)
                    isPresented = false
                }
                .disabled(selectedPilot.isEmpty || selectedAircraft.isEmpty)
            )
        }
    }
}

struct LogbookView_Previews: PreviewProvider {
    static var previews: some View {
        LogbookView()
            .modelContainer(for: [FlightLogEntry.self, Pilot.self, Aircraft.self, Airfield.self], inMemory: true)
    }
}
