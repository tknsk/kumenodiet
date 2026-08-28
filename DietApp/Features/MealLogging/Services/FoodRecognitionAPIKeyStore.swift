import Foundation

enum FoodRecognitionAPIKeyStore {
    private static let logMealKeychainKey = "food.logmeal.apiKey"
    private static let openAIKeychainKey = "food.openai.apiKey"

    static var logMealAPIKey: String? {
        get { readKey(logMealKeychainKey) }
        set { writeKey(logMealKeychainKey, value: newValue) }
    }

    static var openAIAPIKey: String? {
        get { readKey(openAIKeychainKey) }
        set { writeKey(openAIKeychainKey, value: newValue) }
    }

    private static func readKey(_ key: String) -> String? {
        (try? KeychainStore.read(key: key)).flatMap { String(data: $0, encoding: .utf8) }
    }

    private static func writeKey(_ key: String, value: String?) {
        if let value, !value.isEmpty {
            try? KeychainStore.save(key: key, data: Data(value.utf8))
        } else {
            try? KeychainStore.delete(key: key)
        }
    }
}
