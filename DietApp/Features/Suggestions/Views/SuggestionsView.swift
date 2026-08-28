import SwiftUI
import SwiftData

struct SuggestionsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SuggestionsViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    SuggestionsContentView(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("提案")
        }
        .onAppear {
            guard let user = appState.currentUser else { return }
            if let viewModel {
                viewModel.refresh()
            } else {
                viewModel = SuggestionsViewModel(modelContext: modelContext, user: user)
            }
        }
    }
}

private struct SuggestionsContentView: View {
    var viewModel: SuggestionsViewModel

    var body: some View {
        List {
            Section {
                Text(viewModel.summaryMessage)
                    .font(.subheadline)
            }

            if !viewModel.mealSuggestions.isEmpty {
                Section("食事の提案") {
                    ForEach(viewModel.mealSuggestions, id: \.title) { suggestion in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(suggestion.title)
                                .font(.headline)
                            Text(suggestion.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f kcal", suggestion.estimatedCalories))
                                .font(.caption2)
                        }
                    }
                }
            }

            if !viewModel.workoutSuggestions.isEmpty {
                Section("運動の提案") {
                    ForEach(viewModel.workoutSuggestions, id: \.title) { suggestion in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(suggestion.title)
                                .font(.headline)
                            Text(suggestion.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "約%.0f kcal消費", suggestion.estimatedCaloriesBurned))
                                .font(.caption2)
                        }
                    }
                }
            }
        }
    }
}
