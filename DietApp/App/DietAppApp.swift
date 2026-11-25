import SwiftUI
import SwiftData

@main
struct DietAppApp: App {
    @State private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AuthRootView()
                .environment(appState)
        }
        .modelContainer(PersistenceController.shared.container)
        .onChange(of: scenePhase) {
            // バックグラウンドに移るタイミングでウィジェット用の集計を更新する
            guard scenePhase == .background, let user = appState.currentUser else { return }
            WidgetSyncService.refresh(modelContext: PersistenceController.shared.container.mainContext, user: user)
        }
    }
}
