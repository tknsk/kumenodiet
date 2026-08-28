import Foundation

protocol HealthKitService {
    func requestAuthorization() async throws
    func fetchTodayStepCount() async throws -> Int
    func fetchTodayActiveEnergyBurned() async throws -> Double
}
