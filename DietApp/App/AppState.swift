import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var currentUser: UserAccount?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func signIn(as user: UserAccount) {
        currentUser = user
    }

    func signOut() {
        currentUser = nil
    }
}
