import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class WeightViewModel {
    private let modelContext: ModelContext
    private let user: UserAccount

    var records: [WeightRecord] = []
    var newWeightText: String = ""
    var heightInputText: String = ""
    var errorMessage: String?

    init(modelContext: ModelContext, user: UserAccount) {
        self.modelContext = modelContext
        self.user = user
        if let height = user.heightCentimeters {
            heightInputText = String(height)
        }
        load()
    }

    var heightCentimeters: Double? {
        user.heightCentimeters
    }

    var latestWeightKilograms: Double? {
        records.first?.weightKilograms
    }

    var bmi: Double? {
        guard let weight = latestWeightKilograms, let heightCentimeters, heightCentimeters > 0 else {
            return nil
        }
        let heightMeters = heightCentimeters / 100
        return weight / (heightMeters * heightMeters)
    }

    func load() {
        let ownerEmail = user.email
        let descriptor = FetchDescriptor<WeightRecord>(
            predicate: #Predicate<WeightRecord> { $0.ownerEmail == ownerEmail },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        records = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addTodayWeight() {
        errorMessage = nil
        guard let weight = Double(newWeightText), weight > 0 else {
            errorMessage = "体重は数値で入力してください。"
            return
        }
        let record = WeightRecord(date: .now, weightKilograms: weight, ownerEmail: user.email)
        modelContext.insert(record)
        try? modelContext.save()
        newWeightText = ""
        load()
    }

    func saveHeight() {
        errorMessage = nil
        guard let height = Double(heightInputText), height > 0 else {
            errorMessage = "身長は数値で入力してください。"
            return
        }
        user.heightCentimeters = height
        try? modelContext.save()
    }
}
