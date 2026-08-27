import Foundation
import CryptoKit

enum PasswordHasher {
    private static let iterations = 100_000
    private static let saltLength = 16

    static func hash(password: String) -> (hash: Data, salt: Data) {
        let salt = randomSalt()
        let hash = stretch(password: password, salt: salt)
        return (hash, salt)
    }

    static func verify(password: String, hash: Data, salt: Data) -> Bool {
        stretch(password: password, salt: salt) == hash
    }

    private static func randomSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: saltLength)
        _ = SecRandomCopyBytes(kSecRandomDefault, saltLength, &bytes)
        return Data(bytes)
    }

    // PBKDF2相当のHMAC-SHA256反復ストレッチング。サーバーを持たないローカル認証のための簡易実装。
    private static func stretch(password: String, salt: Data) -> Data {
        let key = SymmetricKey(data: Data(password.utf8))
        var digest = Data(HMAC<SHA256>.authenticationCode(for: salt, using: key))
        for _ in 1..<iterations {
            digest = Data(HMAC<SHA256>.authenticationCode(for: digest, using: key))
        }
        return digest
    }
}
