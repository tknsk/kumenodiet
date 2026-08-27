import SwiftUI
import SwiftData

struct AuthRootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AuthViewModel?

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else if let viewModel {
                ZStack {
                    Color.dietAppBackground.ignoresSafeArea()
                    switch viewModel.mode {
                    case .signIn:
                        LoginView(viewModel: viewModel)
                    case .signUp:
                        SignUpView(viewModel: viewModel)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                let service = AuthService(modelContext: modelContext)
                let vm = AuthViewModel(authService: service, appState: appState)
                vm.restoreSession()
                viewModel = vm
            }
        }
    }
}
