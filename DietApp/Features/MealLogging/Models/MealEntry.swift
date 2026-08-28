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
    var ownerEmail: String

    init(
        date: Date = .now,
        name: String,
        calories: Double,
        proteinGrams: Double,
        fatGrams: Double,
        photoFileName: String? = nil,
        ownerEmail: String
    ) {
        self.date = date
        self.name = name
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.photoFileName = photoFileName
        self.ownerEmail = ownerEmail
    }
}
