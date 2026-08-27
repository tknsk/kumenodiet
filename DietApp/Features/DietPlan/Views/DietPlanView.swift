import SwiftUI

struct DietPlanView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "ダイエットプランは準備中",
                systemImage: "target",
                description: Text("目標体重・期間から必要な一日のカロリーを提示します。")
            )
            .navigationTitle("プラン")
        }
    }
}
