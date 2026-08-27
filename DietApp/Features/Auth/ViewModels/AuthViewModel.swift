import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    enum Mode {
        case signIn
        case signUp
    }

    var mode: Mode = .signIn
    var email: String = ""
    var password: String = ""
    var displayName: String = ""
    var errorMessage: String?
    var isProcessing = false

    private let authService: AuthService
    private let appState: AppState

    init(authService: AuthService, appState: AppState) {
        self.authService = authService
        self.appState = appState
    }

    func restoreSession() {
        if let user = authService.restoreLastSignedInUser() {
            appState.signIn(as: user)
        }
    }

    func submit() {
        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }

        do {
            let user: UserAccount
            switch mode {
            case .signIn:
                user = try authService.signIn(email: email, password: password)
            case .signUp:
                user = try authService.signUp(email: email, password: password, displayName: displayName)
            }
            appState.signIn(as: user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleMode() {
        mode = mode == .signIn ? .signUp : .signIn
        errorMessage = nil
    }
}
