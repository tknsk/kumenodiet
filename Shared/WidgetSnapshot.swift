import Foundation

/// メインアプリとウィジェットで共有する、当日のカロリー集計。
/// App Group の UserDefaults 経由で受け渡す(端末外には送信しない)。
struct WidgetSnapshot: Codable, Equatable {
    var date: Date
    var caloriesConsumed: Int
    var caloriesBurned: Int
    var dailyCalorieGoal: Int

    var caloriesRemaining: Int {
        dailyCalorieGoal - caloriesConsumed + caloriesBurned
    }

    static let empty = WidgetSnapshot(date: .now, caloriesConsumed: 0, caloriesBurned: 0, dailyCalorieGoal: WidgetSnapshotStore.defaultDailyGoal)
}

enum WidgetSnapshotStore {
    static let appGroupID = "group.com.example.dietapp"
    static let defaultDailyGoal = 1800
    private static let snapshotKey = "widgetSnapshot"
    private static let goalKey = "dailyCalorieGoal"
    private static let healthBurnedKey = "healthKitBurnedToday"
    private static let healthBurnedDateKey = "healthKitBurnedDate"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static var dailyCalorieGoal: Int {
        get {
            let value = defaults.integer(forKey: goalKey)
            return value > 0 ? value : defaultDailyGoal
        }
        set { defaults.set(newValue, forKey: goalKey) }
    }

    /// HealthKitから取得した当日の消費カロリーを保持する(日付が変われば無効)
    static func saveHealthKitBurned(_ calories: Double) {
        defaults.set(calories, forKey: healthBurnedKey)
        defaults.set(Date.now, forKey: healthBurnedDateKey)
    }

    static var healthKitBurnedToday: Double {
        guard let date = defaults.object(forKey: healthBurnedDateKey) as? Date,
              Calendar.current.isDateInToday(date) else { return 0 }
        return defaults.double(forKey: healthBurnedKey)
    }

    static func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    static func load() -> WidgetSnapshot {
        guard let data = defaults.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data),
              Calendar.current.isDateInToday(snapshot.date) else {
            var empty = WidgetSnapshot.empty
            empty.dailyCalorieGoal = dailyCalorieGoal
            return empty
        }
        return snapshot
    }
}
