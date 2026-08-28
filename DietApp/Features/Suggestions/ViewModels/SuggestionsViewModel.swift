import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SuggestionsViewModel {
    private let modelContext: ModelContext
    private let user: UserAccount

    var mealSuggestions: [MealSuggestion] = []
    var workoutSuggestions: [WorkoutSuggestion] = []
    var summaryMessage: String = ""

    init(modelContext: ModelContext, user: UserAccount) {
        self.modelContext = modelContext
        self.user = user
        refresh()
    }

    func refresh() {
        let calendar = Calendar.current
        let ownerEmail = user.email

        let mealDescriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate<MealEntry> { $0.ownerEmail == ownerEmail }
        )
        let caloriesEatenToday = ((try? modelContext.fetch(mealDescriptor)) ?? [])
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.calories }

        let activityDescriptor = FetchDescriptor<ActivityEntry>(
            predicate: #Predicate<ActivityEntry> { $0.ownerEmail == ownerEmail }
        )
        let caloriesBurnedToday = ((try? modelContext.fetch(activityDescriptor)) ?? [])
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.caloriesBurned }

        let weightDescriptor = FetchDescriptor<WeightRecord>(
            predicate: #Predicate<WeightRecord> { $0.ownerEmail == ownerEmail },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let currentWeight = (try? modelContext.fetch(weightDescriptor))?.first?.weightKilograms

        guard
            let currentWeight,
            let targetWeight = user.targetWeightKilograms,
            let targetDate = user.targetDate,
            let requiredDeficit = DietPlanCalculator.requiredDailyCalorieBalance(
                currentWeightKilograms: currentWeight,
                targetWeightKilograms: targetWeight,
                from: .now,
                to: targetDate
            )
        else {
            summaryMessage = "「体重」タブで体重を、「プラン」タブで目標を設定すると、その日にあった提案を表示します。"
            mealSuggestions = []
            workoutSuggestions = []
            return
        }

        let deficitSoFar = caloriesBurnedToday - caloriesEatenToday
        let gap = requiredDeficit - deficitSoFar

        if gap > 1 {
            summaryMessage = String(format: "目標まであと約%.0f kcalの調整が必要です。", gap)
            mealSuggestions = SuggestionCatalog.meals
                .sorted { abs($0.estimatedCalories - gap) < abs($1.estimatedCalories - gap) }
            workoutSuggestions = SuggestionCatalog.workouts
                .sorted { abs($0.estimatedCaloriesBurned - gap) < abs($1.estimatedCaloriesBurned - gap) }
        } else {
            summaryMessage = "今日の目標は達成できています。無理のない範囲で選んでください。"
            mealSuggestions = SuggestionCatalog.meals.sorted { $0.estimatedCalories < $1.estimatedCalories }
            workoutSuggestions = []
        }
    }
}
