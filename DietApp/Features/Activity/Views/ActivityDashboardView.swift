import SwiftUI

struct ActivityDashboardView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "運動記録は準備中",
                systemImage: "figure.walk.circle",
                description: Text("HealthKitと連携して歩数・消費カロリーを表示します。")
            )
            .navigationTitle("運動")
        }
    }
}
