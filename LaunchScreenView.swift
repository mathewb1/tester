import SwiftUI

class LaunchScreenStateManager: ObservableObject {
    @Published var showLaunchScreen = true
    
    func dismissLaunchScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 1.5)) {
                self.showLaunchScreen = false
            }
        }
    }
}

struct LaunchScreenView: View {
    @ObservedObject var launchScreenState: LaunchScreenStateManager  // Changed to @ObservedObject since it's passed in
    @State private var isOpening = false
    @State private var imageScale = 0.8
    @State private var imageOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var textOffset = CGFloat(50)
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("launchimage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(imageScale)
                    .opacity(imageOpacity)
                    .rotation3DEffect(
                        Angle(degrees: isOpening ? 360 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                
                Text("Flight Logbook")
                    .font(.largeTitle)
                    .bold()
                    .opacity(textOpacity)
                    .offset(y: textOffset)
            }
            .onAppear {
                // Initial fade in and scaling of the image
                withAnimation(.easeOut(duration: 1.0)) {
                    imageScale = 1.0
                    imageOpacity = 1.0
                }
                
                // Start rotation after initial fade in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        isOpening = true
                    }
                }
                
                // Fade in and slide up text
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        textOpacity = 1.0
                        textOffset = 0
                    }
                }
                
                // Trigger the transition to main view
                launchScreenState.dismissLaunchScreen()
            }
        }
    }
}

#Preview {
    LaunchScreenView(launchScreenState: LaunchScreenStateManager())
}
