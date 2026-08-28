import Foundation
import SwiftData

@Model
final class ActivityEntry {
    var date: Date
    var workoutName: String
    var caloriesBurned: Double
    var ownerEmail: String

    init(
        date: Date = .now,
        workoutName: String,
        caloriesBurned: Double,
        ownerEmail: String
    ) {
        self.date = date
        self.workoutName = workoutName
        self.caloriesBurned = caloriesBurned
        self.ownerEmail = ownerEmail
    }
}
