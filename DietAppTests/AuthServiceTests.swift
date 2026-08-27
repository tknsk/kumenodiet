import XCTest
import SwiftData
@testable import DietApp

@MainActor
final class AuthServiceTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var authService: AuthService!

    override func setUpWithError() throws {
        let schema = Schema([UserAccount.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        authService = AuthService(modelContext: modelContainer.mainContext)
    }

    func testSignUpThenSignInSucceeds() throws {
        _ = try authService.signUp(email: "test@example.com", password: "password123", displayName: "Test User")
        let user = try authService.signIn(email: "test@example.com", password: "password123")
        XCTAssertEqual(user.email, "test@example.com")
    }

    func testSignUpWithDuplicateEmailThrows() throws {
        _ = try authService.signUp(email: "dup@example.com", password: "password123", displayName: "A")
        XCTAssertThrowsError(try authService.signUp(email: "dup@example.com", password: "password456", displayName: "B")) { error in
            XCTAssertEqual(error as? AuthError, .emailAlreadyRegistered)
        }
    }

    func testSignInWithWrongPasswordThrows() throws {
        _ = try authService.signUp(email: "wrong@example.com", password: "password123", displayName: "A")
        XCTAssertThrowsError(try authService.signIn(email: "wrong@example.com", password: "incorrect"))
    }

    func testSignUpWithWeakPasswordThrows() {
        XCTAssertThrowsError(try authService.signUp(email: "weak@example.com", password: "123", displayName: "A")) { error in
            XCTAssertEqual(error as? AuthError, .weakPassword)
        }
    }
}
