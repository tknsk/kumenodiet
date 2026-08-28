import Foundation

// LogMeal API v2 (https://docs.logmeal.com/) を使った食品認識・栄養推定。
// 1) /v2/image/segmentation/complete で画像から imageId と料理候補を取得
// 2) /v2/nutrition/recipe/nutritionalInfo で imageId から栄養情報を取得
final class LogMealFoodRecognitionService: FoodRecognitionService {
    enum ServiceError: LocalizedError {
        case missingAPIKey
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "LogMealのAPIキーが設定されていません。設定画面で入力してください。"
            case .invalidResponse:
                return "LogMealからの応答を解析できませんでした。"
            }
        }
    }

    private let session: URLSession
    private let apiKey: String?

    init(session: URLSession = .shared, apiKey: String? = FoodRecognitionAPIKeyStore.logMealAPIKey) {
        self.session = session
        self.apiKey = apiKey
    }

    func recognize(imageData: Data) async throws -> [FoodRecognitionResult] {
        guard let apiKey, !apiKey.isEmpty else {
            throw ServiceError.missingAPIKey
        }

        let imageId = try await segmentImage(imageData: imageData, apiKey: apiKey)
        let response = try await fetchNutritionalInfo(imageId: imageId, apiKey: apiKey)
        return Self.makeResults(from: response)
    }

    private func segmentImage(imageData: Data, apiKey: String) async throws -> Int {
        var request = URLRequest(url: URL(string: "https://api.logmeal.com/v2/image/segmentation/complete")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = Self.multipartBody(imageData: imageData, boundary: boundary)

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(SegmentationResponse.self, from: data).imageId
    }

    private func fetchNutritionalInfo(imageId: Int, apiKey: String) async throws -> NutritionalInfoResponse {
        var request = URLRequest(url: URL(string: "https://api.logmeal.com/v2/nutrition/recipe/nutritionalInfo")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["imageId": imageId])

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(NutritionalInfoResponse.self, from: data)
    }

    static func makeResults(from response: NutritionalInfoResponse) -> [FoodRecognitionResult] {
        let protein = response.nutritionalInfo.totalNutrients["PROCNT"]?.quantity ?? 0
        let fat = response.nutritionalInfo.totalNutrients["FAT"]?.quantity ?? 0

        return [
            FoodRecognitionResult(
                foodName: response.foodName?.displayName ?? "食事",
                estimatedCalories: response.nutritionalInfo.calories,
                proteinGrams: protein,
                fatGrams: fat
            )
        ]
    }

    private static func multipartBody(imageData: Data, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"meal.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

struct SegmentationResponse: Decodable {
    let imageId: Int
}

struct NutritionalInfoResponse: Decodable {
    let foodName: FoodNameValue?
    let nutritionalInfo: NutritionalInfo

    enum CodingKeys: String, CodingKey {
        case foodName
        case nutritionalInfo = "nutritional_info"
    }

    struct NutritionalInfo: Decodable {
        let calories: Double
        let totalNutrients: [String: NutrientValue]
    }

    struct NutrientValue: Decodable {
        let label: String
        let quantity: Double
        let unit: String
    }
}

enum FoodNameValue: Decodable, Equatable {
    case single(String)
    case multiple([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .single(value)
        } else {
            self = .multiple((try? container.decode([String].self)) ?? [])
        }
    }

    var displayName: String {
        switch self {
        case .single(let value):
            return value
        case .multiple(let values):
            return values.joined(separator: "・")
        }
    }
}
