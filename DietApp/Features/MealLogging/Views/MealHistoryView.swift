import SwiftUI

struct MealHistoryView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "食事記録は準備中",
                systemImage: "fork.knife.circle",
                description: Text("写真からカロリー・栄養素を推定する機能をここに実装していきます。")
            )
            .navigationTitle("食事")
        }
    }
}
