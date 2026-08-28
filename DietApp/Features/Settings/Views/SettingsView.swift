import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var provider: FoodRecognitionProvider = FoodRecognitionServiceFactory.selectedProvider
    @State private var logMealAPIKey: String = FoodRecognitionAPIKeyStore.logMealAPIKey ?? ""
    @State private var openAIAPIKey: String = FoodRecognitionAPIKeyStore.openAIAPIKey ?? ""

    var body: some View {
        NavigationStack {
            List {
                Section("アカウント") {
                    if let user = appState.currentUser {
                        LabeledContent("ニックネーム", value: user.displayName)
                        LabeledContent("メールアドレス", value: user.email)
                    }
                    Button("サインアウト", role: .destructive) {
                        appState.signOut()
                    }
                }

                Section {
                    Picker("認識に使うAPI", selection: $provider) {
                        ForEach(FoodRecognitionProvider.allCases) { provider in
                            Text(provider.displayName).tag(provider)
                        }
                    }
                    .onChange(of: provider) {
                        FoodRecognitionServiceFactory.selectedProvider = provider
                    }

                    SecureField("LogMeal APIキー", text: $logMealAPIKey)
                        .onChange(of: logMealAPIKey) {
                            FoodRecognitionAPIKeyStore.logMealAPIKey = logMealAPIKey
                        }

                    SecureField("OpenAI APIキー", text: $openAIAPIKey)
                        .onChange(of: openAIAPIKey) {
                            FoodRecognitionAPIKeyStore.openAIAPIKey = openAIAPIKey
                        }
                } header: {
                    Text("写真からのカロリー推定")
                } footer: {
                    Text("選んだAPIのキーが未入力の場合、写真からの推定はエラーになります。両方のキーを設定していつでも切り替えられます。")
                }

                Section("機能カスタマイズ") {
                    Text("欲しい機能の要望に応じて、ここに設定項目を追加していきます。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("設定")
        }
    }
}
