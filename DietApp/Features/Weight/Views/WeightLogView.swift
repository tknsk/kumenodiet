import SwiftUI

struct WeightLogView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "体重記録は準備中",
                systemImage: "scalemass.fill",
                description: Text("毎朝の体重を記録し、BMIを計算します。")
            )
            .navigationTitle("体重")
        }
    }
}
