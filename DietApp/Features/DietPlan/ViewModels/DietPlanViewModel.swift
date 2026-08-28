import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class DietPlanViewModel {
    private let modelContext: ModelContext
    private let user: UserAccount

    var targetWeightText: String = ""
    var targetDate: Date
    var errorMessage: String?

    init(modelContext: ModelContext, user: UserAccount) {
        self.modelContext = modelContext
        self.user = user
        if let target = user.targetWeightKilograms {
            targetWeightText = String(target)
        }
        targetDate = user.targetDate ?? Calendar.current.date(byAdding: .month, value: 4, to: .now) ?? .now
    }

    var currentWeightKilograms: Double? {
        let ownerEmail = user.email
        let descriptor = FetchDescriptor<WeightRecord>(
            predicate: #Predicate<WeightRecord> { $0.ownerEmail == ownerEmail },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor))?.first?.weightKilograms
    }

    var requiredDailyCalorieBalance: Double? {
        guard
            let currentWeight = currentWeightKilograms,
            let targetWeight = Double(targetWeightText)
        else {
            return nil
        }
        return DietPlanCalculator.requiredDailyCalorieBalance(
            currentWeightKilograms: currentWeight,
            targetWeightKilograms: targetWeight,
            from: .now,
            to: targetDate
        )
    }

    func savePlan() {
        errorMessage = nil
        guard let targetWeight = Double(targetWeightText), targetWeight > 0 else {
            errorMessage = "目標体重は数値で入力してください。"
            return
        }
        user.targetWeightKilograms = targetWeight
        user.targetDate = targetDate
        try? modelContext.save()
    }
}
