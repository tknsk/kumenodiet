import Foundation

struct FoodRecognitionResult {
    let foodName: String
    let estimatedCalories: Double
    let proteinGrams: Double
    let fatGrams: Double
}

protocol FoodRecognitionService {
    func recognize(imageData: Data) async throws -> [FoodRecognitionResult]
}

// TODO: 無料枠のあるクラウド画像認識API(例: LogMeal等)に接続する実装に差し替える。
// APIキーはリポジトリに含めず、Xcodeの設定/Keychain経由で注入すること。
struct UnimplementedFoodRecognitionService: FoodRecognitionService {
    enum ServiceError: Error {
        case notConfigured
    }

    func recognize(imageData: Data) async throws -> [FoodRecognitionResult] {
        throw ServiceError.notConfigured
    }
}
