import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class ActivityViewModel {
    private let modelContext: ModelContext
    private let user: UserAccount
    private let healthKitService: HealthKitService

    var todayStepCount: Int?
    var todayActiveEnergyBurned: Double?
    var healthKitErrorMessage: String?

    var workoutEntries: [ActivityEntry] = []
    var newWorkoutName: String = ""
    var newWorkoutCaloriesText: String = ""
    var formErrorMessage: String?

    init(modelContext: ModelContext, user: UserAccount, healthKitService: HealthKitService = HealthKitManager()) {
        self.modelContext = modelContext
        self.user = user
        self.healthKitService = healthKitService
        loadWorkouts()
    }

    var manualCaloriesBurnedToday: Double {
        let calendar = Calendar.current
        return workoutEntries
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.caloriesBurned }
    }

    var totalCaloriesBurnedToday: Double {
        (todayActiveEnergyBurned ?? 0) + manualCaloriesBurnedToday
    }

    func loadHealthKitData() async {
        healthKitErrorMessage = nil
        do {
            try await healthKitService.requestAuthorization()
            async let steps = healthKitService.fetchTodayStepCount()
            async let energy = healthKitService.fetchTodayActiveEnergyBurned()
            todayStepCount = try await steps
            todayActiveEnergyBurned = try await energy
        } catch {
            healthKitErrorMessage = error.localizedDescription
        }
    }

    func loadWorkouts() {
        let ownerEmail = user.email
        let descriptor = FetchDescriptor<ActivityEntry>(
            predicate: #Predicate<ActivityEntry> { $0.ownerEmail == ownerEmail },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        workoutEntries = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addWorkout() {
        formErrorMessage = nil
        guard !newWorkoutName.trimmingCharacters(in: .whitespaces).isEmpty else {
            formErrorMessage = "運動の名前を入力してください。"
            return
        }
        guard let calories = Double(newWorkoutCaloriesText), calories > 0 else {
            formErrorMessage = "消費カロリーは数値で入力してください。"
            return
        }
        let entry = ActivityEntry(workoutName: newWorkoutName, caloriesBurned: calories, ownerEmail: user.email)
        modelContext.insert(entry)
        try? modelContext.save()
        newWorkoutName = ""
        newWorkoutCaloriesText = ""
        loadWorkouts()
    }
}
