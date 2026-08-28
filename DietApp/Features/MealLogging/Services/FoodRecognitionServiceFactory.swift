import Foundation

enum FoodRecognitionProvider: String, CaseIterable, Identifiable {
    case logMeal
    case openAI

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .logMeal: return "LogMeal"
        case .openAI: return "OpenAI"
        }
    }
}

enum FoodRecognitionServiceFactory {
    private static let providerDefaultsKey = "food.recognition.provider"

    static var selectedProvider: FoodRecognitionProvider {
        get {
            guard let raw = UserDefaults.standard.string(forKey: providerDefaultsKey) else {
                return .logMeal
            }
            return FoodRecognitionProvider(rawValue: raw) ?? .logMeal
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: providerDefaultsKey)
        }
    }

    static func makeService() -> FoodRecognitionService {
        switch selectedProvider {
        case .logMeal:
            return LogMealFoodRecognitionService()
        case .openAI:
            return OpenAIFoodRecognitionService()
        }
    }
}
