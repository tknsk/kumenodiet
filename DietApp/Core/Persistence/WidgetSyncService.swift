import Foundation
import SwiftData
import WidgetKit

/// SwiftDataの当日の記録を集計し、ウィジェット用スナップショットとして書き出す。
@MainActor
enum WidgetSyncService {
    static func refresh(modelContext: ModelContext, user: UserAccount) {
        let ownerEmail = user.email
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)

        let mealDescriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate<MealEntry> { $0.ownerEmail == ownerEmail && $0.date >= startOfDay }
        )
        let activityDescriptor = FetchDescriptor<ActivityEntry>(
            predicate: #Predicate<ActivityEntry> { $0.ownerEmail == ownerEmail && $0.date >= startOfDay }
        )
        let consumed = ((try? modelContext.fetch(mealDescriptor)) ?? []).reduce(0) { $0 + $1.calories }
        let manualBurned = ((try? modelContext.fetch(activityDescriptor)) ?? []).reduce(0) { $0 + $1.caloriesBurned }

        let snapshot = WidgetSnapshot(
            date: .now,
            caloriesConsumed: Int(consumed.rounded()),
            caloriesBurned: Int((manualBurned + WidgetSnapshotStore.healthKitBurnedToday).rounded()),
            dailyCalorieGoal: WidgetSnapshotStore.dailyCalorieGoal
        )
        WidgetSnapshotStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
