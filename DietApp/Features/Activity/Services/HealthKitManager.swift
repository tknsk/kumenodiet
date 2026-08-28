import Foundation
import HealthKit

enum HealthKitError: LocalizedError {
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "この端末ではヘルスケアのデータを利用できません。"
        }
    }
}

final class HealthKitManager: HealthKitService {
    private let healthStore = HKHealthStore()

    private var stepCountType: HKQuantityType { HKQuantityType(.stepCount) }
    private var activeEnergyType: HKQuantityType { HKQuantityType(.activeEnergyBurned) }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        let typesToRead: Set<HKObjectType> = [stepCountType, activeEnergyType]
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }

    func fetchTodayStepCount() async throws -> Int {
        let sum = try await fetchTodaySum(for: stepCountType, unit: .count())
        return Int(sum)
    }

    func fetchTodayActiveEnergyBurned() async throws -> Double {
        try await fetchTodaySum(for: activeEnergyType, unit: .kilocalorie())
    }

    private func fetchTodaySum(for type: HKQuantityType, unit: HKUnit) async throws -> Double {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
}
