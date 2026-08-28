import Foundation
import SwiftData
import Observation
import PhotosUI

@MainActor
@Observable
final class MealLoggingViewModel {
    private let modelContext: ModelContext
    private let user: UserAccount
    private let recognitionService: FoodRecognitionService

    var selectedPhotoItem: PhotosPickerItem?
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

    func loadSelectedPhoto() async {
        guard let selectedPhotoItem else { return }
        errorMessage = nil
        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self) {
                selectedImageData = data
                await recognize(imageData: data)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
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
        selectedPhotoItem = nil
        selectedImageData = nil
        recognitionResults = []
        errorMessage = nil
    }
}
