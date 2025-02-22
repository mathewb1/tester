import SwiftUI
import SwiftData

@main
struct LogbookApp: App {
    @State private var showLaunchScreen = true
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                FlightLogEntry.self,
                Aircraft.self,
                Airfield.self,
                Pilot.self,
                SavedPDF.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not configure SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .modelContainer(container)
                
                if showLaunchScreen {
                    LaunchScreenView(launchScreenState: LaunchScreenStateManager())
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Dismiss the launch screen after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}