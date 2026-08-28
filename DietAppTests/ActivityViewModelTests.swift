import XCTest
import SwiftData
@testable import DietApp

private struct FakeHealthKitService: HealthKitService {
    func requestAuthorization() async throws {}
    func fetchTodayStepCount() async throws -> Int { 1234 }
    func fetchTodayActiveEnergyBurned() async throws -> Double { 200 }
}

@MainActor
final class ActivityViewModelTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var user: UserAccount!
    private var viewModel: ActivityViewModel!

    override func setUpWithError() throws {
        let schema = Schema([UserAccount.self, ActivityEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])

        let (hash, salt) = PasswordHasher.hash(password: "password123")
        user = UserAccount(email: "activity@example.com", displayName: "Test", passwordHash: hash, passwordSalt: salt)
        modelContainer.mainContext.insert(user)

        viewModel = ActivityViewModel(
            modelContext: modelContainer.mainContext,
            user: user,
            healthKitService: FakeHealthKitService()
        )
    }

    func testTotalCaloriesBurnedTodayCombinesHealthKitAndManualEntries() async {
        await viewModel.loadHealthKitData()
        viewModel.newWorkoutName = "ランニング"
        viewModel.newWorkoutCaloriesText = "300"
        viewModel.addWorkout()

        XCTAssertEqual(viewModel.totalCaloriesBurnedToday, 500, accuracy: 0.01)
    }

    func testAddWorkoutWithInvalidCaloriesShowsError() {
        viewModel.newWorkoutName = "ヨガ"
        viewModel.newWorkoutCaloriesText = "abc"
        viewModel.addWorkout()

        XCTAssertNotNil(viewModel.formErrorMessage)
        XCTAssertTrue(viewModel.workoutEntries.isEmpty)
    }
}
