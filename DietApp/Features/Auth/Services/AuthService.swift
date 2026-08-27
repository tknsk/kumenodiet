import Foundation
import SwiftData

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case emailAlreadyRegistered
    case weakPassword

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "メールアドレスまたはパスワードが正しくありません。"
        case .emailAlreadyRegistered:
            return "このメールアドレスは既に登録されています。"
        case .weakPassword:
            return "パスワードは8文字以上で入力してください。"
        }
    }
}

@MainActor
final class AuthService {
    private let modelContext: ModelContext
    private static let lastSignedInEmailKey = "auth.lastSignedInEmail"

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func signUp(email: String, password: String, displayName: String) throws -> UserAccount {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard password.count >= 8 else {
            throw AuthError.weakPassword
        }

        let descriptor = FetchDescriptor<UserAccount>(
            predicate: #Predicate { $0.email == normalizedEmail }
        )
        if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
            throw AuthError.emailAlreadyRegistered
        }

        let (hash, salt) = PasswordHasher.hash(password: password)
        let account = UserAccount(
            email: normalizedEmail,
            displayName: displayName,
            passwordHash: hash,
            passwordSalt: salt
        )
        modelContext.insert(account)
        try modelContext.save()
        rememberSignedInEmail(normalizedEmail)
        return account
    }

    func signIn(email: String, password: String) throws -> UserAccount {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let descriptor = FetchDescriptor<UserAccount>(
            predicate: #Predicate { $0.email == normalizedEmail }
        )
        guard let account = try modelContext.fetch(descriptor).first,
              PasswordHasher.verify(password: password, hash: account.passwordHash, salt: account.passwordSalt)
        else {
            throw AuthError.invalidCredentials
        }
        rememberSignedInEmail(normalizedEmail)
        return account
    }

    func signOut() {
        try? KeychainStore.delete(key: Self.lastSignedInEmailKey)
    }

    func restoreLastSignedInUser() -> UserAccount? {
        guard let data = try? KeychainStore.read(key: Self.lastSignedInEmailKey),
              let email = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        let descriptor = FetchDescriptor<UserAccount>(
            predicate: #Predicate { $0.email == email }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func rememberSignedInEmail(_ email: String) {
        try? KeychainStore.save(key: Self.lastSignedInEmailKey, data: Data(email.utf8))
    }
}
