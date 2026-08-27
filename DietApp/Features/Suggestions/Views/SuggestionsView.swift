import SwiftUI

struct SuggestionsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "提案機能は準備中",
                systemImage: "sparkles",
                description: Text("目標達成に必要な食事メニュー・運動メニューを提案します。")
            )
            .navigationTitle("提案")
        }
    }
}
