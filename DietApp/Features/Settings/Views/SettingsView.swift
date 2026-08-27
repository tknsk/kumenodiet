import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

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
