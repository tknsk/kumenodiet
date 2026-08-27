import Foundation
import SwiftData

@Model
final class UserAccount {
    @Attribute(.unique) var email: String
    var displayName: String
    var passwordHash: Data
    var passwordSalt: Data
    var createdAt: Date

    var heightCentimeters: Double?
    var targetWeightKilograms: Double?
    var targetDate: Date?

    init(
        email: String,
        displayName: String,
        passwordHash: Data,
        passwordSalt: Data,
        createdAt: Date = .now
    ) {
        self.email = email
        self.displayName = displayName
        self.passwordHash = passwordHash
        self.passwordSalt = passwordSalt
        self.createdAt = createdAt
    }
}
