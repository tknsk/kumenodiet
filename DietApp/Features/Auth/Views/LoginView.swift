import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("おかえりなさい")
                .font(.largeTitle.bold())

            VStack(spacing: 12) {
                TextField("メールアドレス", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                SecureField("パスワード", text: $viewModel.password)
                    .textContentType(.password)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.submit()
            } label: {
                if viewModel.isProcessing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("ログイン")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.dietAppAccent)
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isProcessing)

            Button("アカウントをお持ちでない方はこちら") {
                viewModel.toggleMode()
            }
            .font(.footnote)
        }
        .padding(24)
    }
}
