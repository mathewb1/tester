import SwiftUI
import SwiftData

struct FlightTotalsView: View {
    @Query private var flightLogs: [FlightLogEntry]
    
    // Calculate total flights
    private var totalFlights: Int {
        return flightLogs.count
    }
    
    // Calculate total hours and minutes
    private var totalTime: (hours: Int, minutes: Int) {
        let times = flightLogs.map { log in
            let components = log.duration.split(separator: ":")
            let hours = Int(components[0]) ?? 0
            let minutes = Int(components[1]) ?? 0
            return (hours, minutes)
        }
        
        let totalMinutes = times.reduce(0) { $0 + $1.0 * 60 + $1.1 }
        return (totalMinutes / 60, totalMinutes % 60)
    }
    
    // Calculate decimal hours
    private var totalHoursDecimal: Double {
        let (hours, minutes) = totalTime
        return Double(hours) + (Double(minutes) / 60.0)
    }
    
    // Calculate longest flight
    private var longestFlight: String {
        let longest = flightLogs.max { a, b in
            let aComponents = a.duration.split(separator: ":")
            let bComponents = b.duration.split(separator: ":")
            let aMinutes = (Int(aComponents[0]) ?? 0) * 60 + (Int(aComponents[1]) ?? 0)
            let bMinutes = (Int(bComponents[0]) ?? 0) * 60 + (Int(bComponents[1]) ?? 0)
            return aMinutes < bMinutes
        }
        return longest?.duration ?? "00:00"
    }
    
    // Calculate shortest flight
    private var shortestFlight: String {
        let shortest = flightLogs.min { a, b in
            let aComponents = a.duration.split(separator: ":")
            let bComponents = b.duration.split(separator: ":")
            let aMinutes = (Int(aComponents[0]) ?? 0) * 60 + (Int(aComponents[1]) ?? 0)
            let bMinutes = (Int(bComponents[0]) ?? 0) * 60 + (Int(bComponents[1]) ?? 0)
            return aMinutes < bMinutes
        }
        return shortest?.duration ?? "00:00"
    }
    
    // Calculate average flight duration
    private var averageFlight: String {
        guard !flightLogs.isEmpty else { return "00:00" }
        let (hours, minutes) = totalTime
        let totalMinutes = hours * 60 + minutes
        let avgMinutes = totalMinutes / flightLogs.count
        return String(format: "%02d:%02d", avgMinutes / 60, avgMinutes % 60)
    }
    
    private var flightStatistics: [FlightStatistic] {
        [
            FlightStatistic(title: "Total Flights", value: "\(totalFlights)"),
            FlightStatistic(title: "Total Hours", value: String(format: "%02d:%02d", totalTime.hours, totalTime.minutes)),
            FlightStatistic(title: "Total Hours Decimal", value: String(format: "%.1f", totalHoursDecimal)),
            FlightStatistic(title: "Longest Flight", value: longestFlight),
            FlightStatistic(title: "Shortest Flight", value: shortestFlight),
            FlightStatistic(title: "Average Flight Duration", value: averageFlight)
        ]
    }
    
    struct FlightStatistic: Identifiable {
        let id = UUID()
        let title: String
        let value: String
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                List(flightStatistics) { stat in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(stat.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(stat.value)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Flight Totals")
        }
    }
}

struct FlightTotalsView_Previews: PreviewProvider {
    static var previews: some View {
        FlightTotalsView()
            .modelContainer(for: FlightLogEntry.self, inMemory: true)
    }
}
