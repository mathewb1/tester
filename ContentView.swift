import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var launchScreenState = LaunchScreenStateManager()
    
    var body: some View {
        ZStack {
            TabView {
                LogbookView()
                    .tabItem {
                        Label("Logbook", systemImage: "book")
                    }
                
                FlightTotalsView()
                    .tabItem {
                        Label("Flight Totals", systemImage: "chart.bar")
                    }
                
                AircraftView()
                    .tabItem {
                        Label("Aircraft", systemImage: "airplane")
                    }
                
                AirfieldsView()
                    .tabItem {
                        Label("Airfields", systemImage: "map")
                    }
                
                PilotsView()
                    .tabItem {
                        Label("Pilots", systemImage: "person.3")
                    }
                
                PDFView()
                    .tabItem {
                        Label("PDF Viewer", systemImage: "doc.text")
                    }
            }
            .opacity(launchScreenState.showLaunchScreen ? 0 : 1)
            
            if launchScreenState.showLaunchScreen {
                LaunchScreenView(launchScreenState: launchScreenState)
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FlightLogEntry.self, Aircraft.self, Airfield.self, Pilot.self], inMemory: true)
}
