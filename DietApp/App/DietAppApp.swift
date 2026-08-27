import SwiftUI

@main
struct DietAppApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AuthRootView()
                .environment(appState)
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
