import SwiftUI

@main
struct FirstLearnApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.profile == nil {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .animation(.easeInOut, value: appState.profile == nil)
    }
}
