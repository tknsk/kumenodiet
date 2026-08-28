import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class MealLoggingViewModel {
    private let modelContext: ModelContext
    private let user: UserAccount
    private let recognitionService: FoodRecognitionService

    var selectedImageData: Data?
    var recognitionResults: [FoodRecognitionResult] = []
    var isRecognizing = false
    var errorMessage: String?

    init(
        modelContext: ModelContext,
        user: UserAccount,
        recognitionService: FoodRecognitionService = FoodRecognitionServiceFactory.makeService()
    ) {
        self.modelContext = modelContext
        self.user = user
        self.recognitionService = recognitionService
    }

    func setSelectedImage(_ data: Data) async {
        selectedImageData = data
        await recognize(imageData: data)
    }

    func recognize(imageData: Data) async {
        errorMessage = nil
        recognitionResults = []
        isRecognizing = true
        defer { isRecognizing = false }
        do {
            recognitionResults = try await recognitionService.recognize(imageData: imageData)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveResult(_ result: FoodRecognitionResult) {
        let photoFileName = selectedImageData.flatMap { MealPhotoStore.save(imageData: $0) }
        let entry = MealEntry(
            name: result.foodName,
            calories: result.estimatedCalories,
            proteinGrams: result.proteinGrams,
            fatGrams: result.fatGrams,
            photoFileName: photoFileName,
            ownerEmail: user.email
        )
        modelContext.insert(entry)
        try? modelContext.save()
        reset()
    }

    func reset() {
        selectedImageData = nil
        recognitionResults = []
        errorMessage = nil
    }
}
