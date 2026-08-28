import SwiftUI
import SwiftData

struct DietPlanView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DietPlanViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    DietPlanContentView(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("プラン")
        }
        .onAppear {
            if viewModel == nil, let user = appState.currentUser {
                viewModel = DietPlanViewModel(modelContext: modelContext, user: user)
            }
        }
    }
}

private struct DietPlanContentView: View {
    @Bindable var viewModel: DietPlanViewModel

    var body: some View {
        Form {
            Section("目標") {
                HStack {
                    Text("目標体重")
                    Spacer()
                    TextField("kg", text: $viewModel.targetWeightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                DatePicker("達成したい日", selection: $viewModel.targetDate, displayedComponents: .date)
            }

            Section("必要な一日のカロリー収支") {
                if let balance = viewModel.requiredDailyCalorieBalance {
                    if balance > 1 {
                        Text(String(format: "1日あたり約%.0f kcalの赤字が必要です", balance))
                    } else if balance < -1 {
                        Text(String(format: "1日あたり約%.0f kcalの黒字(増量)になります", -balance))
                    } else {
                        Text("現状維持でOKです")
                    }
                } else {
                    Text("「体重」タブで今日の体重を記録すると、必要なカロリー収支を計算します。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button("プランを保存") {
                viewModel.savePlan()
            }
            .buttonStyle(.borderedProminent)
            .tint(.dietAppAccent)
        }
    }
}
