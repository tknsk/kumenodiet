import Foundation
import SwiftData

@Model
final class WeightRecord {
    var date: Date
    var weightKilograms: Double

    init(date: Date = .now, weightKilograms: Double) {
        self.date = date
        self.weightKilograms = weightKilograms
    }
}
