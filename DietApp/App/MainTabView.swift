import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MealHistoryView()
                .tabItem { Label("食事", systemImage: "fork.knife") }

            ActivityDashboardView()
                .tabItem { Label("運動", systemImage: "figure.walk") }

            WeightLogView()
                .tabItem { Label("体重", systemImage: "scalemass") }

            DietPlanView()
                .tabItem { Label("プラン", systemImage: "target") }

            SuggestionsView()
                .tabItem { Label("提案", systemImage: "sparkles") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
        .tint(.dietAppAccent)
    }
}
