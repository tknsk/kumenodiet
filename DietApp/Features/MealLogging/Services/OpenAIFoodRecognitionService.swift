import Foundation

// OpenAI Chat Completions API (vision入力) を使った食品認識・栄養推定。
// 画像1枚をBase64で渡し、構造化JSONで料理ごとのカロリー・栄養素を返させる。
final class OpenAIFoodRecognitionService: FoodRecognitionService {
    enum ServiceError: LocalizedError {
        case missingAPIKey
        case httpError(statusCode: Int, body: String)
        case invalidResponse(body: String)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "OpenAIのAPIキーが設定されていません。設定画面で入力してください。"
            case .httpError(let statusCode, let body):
                return "OpenAIからエラーが返されました(status: \(statusCode))。\(body)"
            case .invalidResponse(let body):
                return "OpenAIからの応答を解析できませんでした。応答内容: \(body)"
            }
        }
    }

    private let session: URLSession
    private let apiKey: String?
    private let model: String

    init(
        session: URLSession = .shared,
        apiKey: String? = FoodRecognitionAPIKeyStore.openAIAPIKey,
        model: String = "gpt-4o-mini"
    ) {
        self.session = session
        self.apiKey = apiKey
        self.model = model
    }

    func recognize(imageData: Data) async throws -> [FoodRecognitionResult] {
        guard let apiKey, !apiKey.isEmpty else {
            throw ServiceError.missingAPIKey
        }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            ChatRequest(model: model, imageBase64: imageData.base64EncodedString())
        )

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw ServiceError.httpError(statusCode: httpResponse.statusCode, body: Self.bodyPreview(data))
        }

        guard let chatResponse = try? JSONDecoder().decode(ChatResponse.self, from: data) else {
            throw ServiceError.invalidResponse(body: Self.bodyPreview(data))
        }

        guard
            let content = chatResponse.choices.first?.message.content,
            let contentData = content.data(using: .utf8),
            let analysis = try? JSONDecoder().decode(FoodAnalysis.self, from: contentData)
        else {
            throw ServiceError.invalidResponse(body: Self.bodyPreview(data))
        }

        return Self.makeResults(from: analysis)
    }

    private static func bodyPreview(_ data: Data) -> String {
        guard let text = String(data: data, encoding: .utf8), !text.isEmpty else {
            return "(空、または解析できない応答)"
        }
        return String(text.prefix(300))
    }

    static func makeResults(from analysis: FoodAnalysis) -> [FoodRecognitionResult] {
        analysis.items.map {
            FoodRecognitionResult(
                foodName: $0.foodName,
                estimatedCalories: $0.calories,
                proteinGrams: $0.proteinGrams,
                fatGrams: $0.fatGrams
            )
        }
    }
}

struct ChatRequest: Encodable {
    let model: String
    let imageBase64: String

    private static let prompt = """
    この写真に写っている食事を分析してください。写っている料理・食品ごとに、名前、推定カロリー(kcal)、たんぱく質(g)、脂質(g)を推定してください。\
    以下のJSON形式のみで回答してください。他の説明文は含めないでください。
    {"items": [{"foodName": "string", "calories": number, "proteinGrams": number, "fatGrams": number}]}
    """

    enum CodingKeys: String, CodingKey {
        case model, messages
        case responseFormat = "response_format"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode([ChatMessage(imageBase64: imageBase64)], forKey: .messages)
        try container.encode(ResponseFormat(), forKey: .responseFormat)
    }

    private struct ResponseFormat: Encodable {
        let type = "json_object"
    }

    private struct ChatMessage: Encodable {
        let role = "user"
        let content: [ContentPart]

        init(imageBase64: String) {
            content = [
                .text(ChatRequest.prompt),
                .imageURL("data:image/jpeg;base64,\(imageBase64)")
            ]
        }
    }

    private enum ContentPart: Encodable {
        case text(String)
        case imageURL(String)

        enum CodingKeys: String, CodingKey {
            case type, text
            case imageURL = "image_url"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .imageURL(let url):
                try container.encode("image_url", forKey: .type)
                try container.encode(["url": url], forKey: .imageURL)
            }
        }
    }
}

struct ChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String
    }
}

struct FoodAnalysis: Decodable {
    let items: [Item]

    struct Item: Decodable {
        let foodName: String
        let calories: Double
        let proteinGrams: Double
        let fatGrams: Double

        enum CodingKeys: String, CodingKey {
            case foodName, calories, proteinGrams, fatGrams
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            foodName = (try? container.decode(String.self, forKey: .foodName)) ?? "食事"
            calories = (try? container.decode(Double.self, forKey: .calories)) ?? 0
            proteinGrams = (try? container.decode(Double.self, forKey: .proteinGrams)) ?? 0
            fatGrams = (try? container.decode(Double.self, forKey: .fatGrams)) ?? 0
        }
    }
}
