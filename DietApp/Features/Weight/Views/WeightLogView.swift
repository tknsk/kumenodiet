import SwiftUI
import SwiftData

struct WeightLogView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WeightViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    WeightLogContentView(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("体重")
        }
        .onAppear {
            if viewModel == nil, let user = appState.currentUser {
                viewModel = WeightViewModel(modelContext: modelContext, user: user)
            }
        }
    }
}

private struct WeightLogContentView: View {
    @Bindable var viewModel: WeightViewModel

    var body: some View {
        List {
            Section("身長") {
                HStack {
                    TextField("身長(cm)", text: $viewModel.heightInputText)
                        .keyboardType(.decimalPad)
                    Button("保存") {
                        viewModel.saveHeight()
                    }
                }
            }

            Section("今日の体重") {
                HStack {
                    TextField("体重(kg)", text: $viewModel.newWeightText)
                        .keyboardType(.decimalPad)
                    Button("記録") {
                        viewModel.addTodayWeight()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.dietAppAccent)
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            if let bmi = viewModel.bmi {
                Section("BMI") {
                    Text(String(format: "%.1f", bmi))
                        .font(.title.bold())
                }
            }

            Section("記録") {
                if viewModel.records.isEmpty {
                    Text("まだ記録がありません")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.records) { record in
                        HStack {
                            Text(record.date, style: .date)
                            Spacer()
                            Text(String(format: "%.1f kg", record.weightKilograms))
                        }
                    }
                }
            }
        }
    }
}
