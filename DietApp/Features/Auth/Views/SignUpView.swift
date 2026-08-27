import SwiftUI

struct SignUpView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("はじめまして")
                .font(.largeTitle.bold())

            VStack(spacing: 12) {
                TextField("ニックネーム", text: $viewModel.displayName)
                    .textContentType(.name)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                TextField("メールアドレス", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                SecureField("パスワード(8文字以上)", text: $viewModel.password)
                    .textContentType(.newPassword)
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
                    Text("アカウント作成")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.dietAppAccent)
            .disabled(
                viewModel.displayName.isEmpty ||
                viewModel.email.isEmpty ||
                viewModel.password.isEmpty ||
                viewModel.isProcessing
            )

            Button("既にアカウントをお持ちの方はこちら") {
                viewModel.toggleMode()
            }
            .font(.footnote)
        }
        .padding(24)
    }
}
