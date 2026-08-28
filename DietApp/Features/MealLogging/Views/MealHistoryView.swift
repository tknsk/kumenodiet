import SwiftUI
import SwiftData

struct MealHistoryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var showingCapture = false

    var body: some View {
        NavigationStack {
            Group {
                if let user = appState.currentUser {
                    MealHistoryContentView(user: user)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("食事")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCapture = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCapture) {
                MealCaptureView()
            }
        }
    }
}

private struct MealHistoryContentView: View {
    @Query private var entries: [MealEntry]

    init(user: UserAccount) {
        let ownerEmail = user.email
        _entries = Query(
            filter: #Predicate<MealEntry> { $0.ownerEmail == ownerEmail },
            sort: [SortDescriptor(\MealEntry.date, order: .reverse)]
        )
    }

    private var todaysCalories: Double {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        List {
            Section("今日の摂取カロリー") {
                Text(String(format: "%.0f kcal", todaysCalories))
                    .font(.title.bold())
            }

            Section("記録") {
                if entries.isEmpty {
                    Text("まだ記録がありません。右上の＋から写真を追加してください。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.name)
                                .font(.headline)
                            Text(String(
                                format: "%.0f kcal ・ たんぱく質 %.1fg ・ 脂質 %.1fg",
                                entry.calories, entry.proteinGrams, entry.fatGrams
                            ))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            Text(entry.date, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
    }
}
