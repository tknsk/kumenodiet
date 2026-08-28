import SwiftUI
import SwiftData

struct ActivityDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ActivityViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    ActivityDashboardContentView(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("運動")
        }
        .onAppear {
            if viewModel == nil, let user = appState.currentUser {
                let vm = ActivityViewModel(modelContext: modelContext, user: user)
                viewModel = vm
                Task { await vm.loadHealthKitData() }
            }
        }
    }
}

private struct ActivityDashboardContentView: View {
    @Bindable var viewModel: ActivityViewModel

    var body: some View {
        List {
            Section("今日の歩数・消費カロリー") {
                if let steps = viewModel.todayStepCount {
                    LabeledContent("歩数", value: "\(steps) 歩")
                }
                LabeledContent("消費カロリー(合計)", value: String(format: "%.0f kcal", viewModel.totalCaloriesBurnedToday))
                if let errorMessage = viewModel.healthKitErrorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section("運動を記録") {
                TextField("運動の内容(例: ジム、ランニング)", text: $viewModel.newWorkoutName)
                TextField("消費カロリー(kcal)", text: $viewModel.newWorkoutCaloriesText)
                    .keyboardType(.decimalPad)
                Button("記録") {
                    viewModel.addWorkout()
                }
                .buttonStyle(.borderedProminent)
                .tint(.dietAppAccent)
                if let formErrorMessage = viewModel.formErrorMessage {
                    Text(formErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section("記録") {
                if viewModel.workoutEntries.isEmpty {
                    Text("まだ記録がありません")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.workoutEntries) { entry in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(entry.workoutName)
                                Text(entry.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(String(format: "%.0f kcal", entry.caloriesBurned))
                        }
                    }
                }
            }
        }
    }
}
