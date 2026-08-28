import Foundation

struct FoodRecognitionResult: Equatable {
    let foodName: String
    let estimatedCalories: Double
    let proteinGrams: Double
    let fatGrams: Double
}

protocol FoodRecognitionService {
    func recognize(imageData: Data) async throws -> [FoodRecognitionResult]
}
