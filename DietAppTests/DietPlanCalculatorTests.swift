import XCTest
@testable import DietApp

final class DietPlanCalculatorTests: XCTestCase {
    func testRequiredDailyCalorieBalanceForWeightLoss() {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let target = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1))!

        let balance = DietPlanCalculator.requiredDailyCalorieBalance(
            currentWeightKilograms: 70,
            targetWeightKilograms: 65,
            from: start,
            to: target,
            calendar: calendar
        )

        // 5kg × 7700kcal ÷ 120日 ≒ 320.8 kcal/日
        XCTAssertEqual(balance ?? 0, 320.8, accuracy: 1.0)
    }

    func testRequiredDailyCalorieBalanceReturnsNilWhenTargetDateIsNotInFuture() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!

        let balance = DietPlanCalculator.requiredDailyCalorieBalance(
            currentWeightKilograms: 70,
            targetWeightKilograms: 65,
            from: date,
            to: date,
            calendar: calendar
        )

        XCTAssertNil(balance)
    }
}
