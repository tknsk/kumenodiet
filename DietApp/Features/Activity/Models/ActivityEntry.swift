import Foundation
import SwiftData

@Model
final class ActivityEntry {
    var date: Date
    var stepCount: Int
    var workoutName: String?
    var caloriesBurned: Double

    init(
        date: Date = .now,
        stepCount: Int = 0,
        workoutName: String? = nil,
        caloriesBurned: Double = 0
    ) {
        self.date = date
        self.stepCount = stepCount
        self.workoutName = workoutName
        self.caloriesBurned = caloriesBurned
    }
}
