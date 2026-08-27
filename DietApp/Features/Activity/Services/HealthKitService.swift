import Foundation

// TODO: HealthKit連携(歩数・アクティブカロリーの読み取り)を実装する
protocol HealthKitService {
    func requestAuthorization() async throws
    func fetchTodayStepCount() async throws -> Int
    func fetchTodayActiveEnergyBurned() async throws -> Double
}
