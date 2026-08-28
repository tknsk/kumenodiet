import Foundation

enum DietPlanCalculator {
    /// 体脂肪1kgあたりの概算カロリー
    static let kilocaloriesPerKilogramOfFat: Double = 7700

    /// 目標体重・目標日までに必要な1日あたりのカロリー収支(正の値=赤字が必要、負の値=黒字になる)を返す
    static func requiredDailyCalorieBalance(
        currentWeightKilograms: Double,
        targetWeightKilograms: Double,
        from startDate: Date,
        to targetDate: Date,
        calendar: Calendar = .current
    ) -> Double? {
        let days = calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 0
        guard days > 0 else { return nil }

        let weightDifference = currentWeightKilograms - targetWeightKilograms
        let totalCalories = weightDifference * kilocaloriesPerKilogramOfFat
        return totalCalories / Double(days)
    }
}
