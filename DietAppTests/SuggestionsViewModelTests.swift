import XCTest
import SwiftData
@testable import DietApp

@MainActor
final class SuggestionsViewModelTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var user: UserAccount!

    override func setUpWithError() throws {
        let schema = Schema([UserAccount.self, MealEntry.self, ActivityEntry.self, WeightRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])

        let (hash, salt) = PasswordHasher.hash(password: "password123")
        user = UserAccount(email: "suggest@example.com", displayName: "Test", passwordHash: hash, passwordSalt: salt)
        modelContainer.mainContext.insert(user)
    }

    func testShowsGuidanceMessageWhenNoWeightOrPlanIsSet() {
        let viewModel = SuggestionsViewModel(modelContext: modelContainer.mainContext, user: user)

        XCTAssertTrue(viewModel.mealSuggestions.isEmpty)
        XCTAssertTrue(viewModel.workoutSuggestions.isEmpty)
        XCTAssertFalse(viewModel.summaryMessage.isEmpty)
    }

    func testSuggestsWorkoutsClosestToRemainingGapWhenDeficitNotYetReached() throws {
        user.targetWeightKilograms = 65
        user.targetDate = Calendar.current.date(byAdding: .day, value: 100, to: .now)
        modelContainer.mainContext.insert(WeightRecord(date: .now, weightKilograms: 70, ownerEmail: user.email))
        try modelContainer.mainContext.save()

        let viewModel = SuggestionsViewModel(modelContext: modelContainer.mainContext, user: user)

        // 5kg / 100日 なので、目標未達(gap > 0)のはず
        XCTAssertFalse(viewModel.workoutSuggestions.isEmpty)
        XCTAssertFalse(viewModel.mealSuggestions.isEmpty)
    }

    func testSuggestsNoWorkoutsWhenDeficitAlreadyAchievedToday() throws {
        user.targetWeightKilograms = 69
        user.targetDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)
        modelContainer.mainContext.insert(WeightRecord(date: .now, weightKilograms: 70, ownerEmail: user.email))
        modelContainer.mainContext.insert(
            ActivityEntry(date: .now, workoutName: "ランニング", caloriesBurned: 1000, ownerEmail: user.email)
        )
        try modelContainer.mainContext.save()

        let viewModel = SuggestionsViewModel(modelContext: modelContainer.mainContext, user: user)

        XCTAssertTrue(viewModel.workoutSuggestions.isEmpty)
        XCTAssertFalse(viewModel.mealSuggestions.isEmpty)
    }
}
