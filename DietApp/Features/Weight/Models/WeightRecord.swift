import Foundation
import SwiftData

@Model
final class WeightRecord {
    var date: Date
    var weightKilograms: Double
    var ownerEmail: String

    init(date: Date = .now, weightKilograms: Double, ownerEmail: String) {
        self.date = date
        self.weightKilograms = weightKilograms
        self.ownerEmail = ownerEmail
    }
}
