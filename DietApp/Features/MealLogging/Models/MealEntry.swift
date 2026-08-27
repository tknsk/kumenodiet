import Foundation
import SwiftData

@Model
final class MealEntry {
    var date: Date
    var name: String
    var calories: Double
    var proteinGrams: Double
    var fatGrams: Double
    var photoFileName: String?

    init(
        date: Date = .now,
        name: String = "",
        calories: Double = 0,
        proteinGrams: Double = 0,
        fatGrams: Double = 0,
        photoFileName: String? = nil
    ) {
        self.date = date
        self.name = name
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.photoFileName = photoFileName
    }
}
