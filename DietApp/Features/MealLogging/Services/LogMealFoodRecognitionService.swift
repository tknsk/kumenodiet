import Foundation

// LogMeal API v2 (https://docs.logmeal.com/) を使った食品認識・栄養推定。
// 1) /v2/image/segmentation/complete で画像から imageId と料理候補を取得
// 2) /v2/nutrition/recipe/nutritionalInfo で imageId から栄養情報を取得
final class LogMealFoodRecognitionService: FoodRecognitionService {
    enum ServiceError: LocalizedError {
        case missingAPIKey
        case httpError(statusCode: Int, body: String)
        case decodingFailed(body: String)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "LogMealのAPIキーが設定されていません。設定画面で入力してください。"
            case .httpError(let statusCode, let body):
                return "LogMealからエラーが返されました(status: \(statusCode))。\(body)"
            case .decodingFailed(let body):
                return "LogMealからの応答を解析できませんでした。応答内容: \(body)"
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

        let (data, response) = try await session.data(for: request)
        try Self.checkHTTPStatus(response: response, data: data)
        return try Self.decode(SegmentationResponse.self, from: data).imageId
    }

    private func fetchNutritionalInfo(imageId: Int, apiKey: String) async throws -> NutritionalInfoResponse {
        var request = URLRequest(url: URL(string: "https://api.logmeal.com/v2/nutrition/recipe/nutritionalInfo")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["imageId": imageId])

        let (data, response) = try await session.data(for: request)
        try Self.checkHTTPStatus(response: response, data: data)
        return try Self.decode(NutritionalInfoResponse.self, from: data)
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

    private static func checkHTTPStatus(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.httpError(statusCode: httpResponse.statusCode, body: bodyPreview(data))
        }
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw ServiceError.decodingFailed(body: bodyPreview(data))
        }
    }

    private static func bodyPreview(_ data: Data) -> String {
        guard let text = String(data: data, encoding: .utf8), !text.isEmpty else {
            return "(空、または解析できない応答)"
        }
        return String(text.prefix(300))
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

        enum CodingKeys: String, CodingKey {
            case calories, totalNutrients
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            calories = (try? container.decode(Double.self, forKey: .calories)) ?? 0
            totalNutrients = (try? container.decode([String: NutrientValue].self, forKey: .totalNutrients)) ?? [:]
        }
    }

    struct NutrientValue: Decodable {
        let label: String
        let quantity: Double
        let unit: String

        enum CodingKeys: String, CodingKey {
            case label, quantity, unit
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            label = (try? container.decode(String.self, forKey: .label)) ?? ""
            quantity = (try? container.decode(Double.self, forKey: .quantity)) ?? 0
            unit = (try? container.decode(String.self, forKey: .unit)) ?? ""
        }
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
