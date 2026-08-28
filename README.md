# DietApp

写真から食事のカロリー・栄養素を推定し、歩数や運動の記録と合わせて日々の摂取/消費カロリーを管理するiOSアプリ。二人での利用を想定し、各自のiPhoneにアプリを入れて使う(端末間の同期は行わない)。

## 必要環境
- macOS + Xcode 15以降
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)(`brew install xcodegen`)

このリポジトリはWindows環境で作成しているため `.xcodeproj` はコミットせず、`project.yml` から生成する方式にしている。Xcode・XcodeGenでのビルド確認はまだ行えていない。

## セットアップ手順(macOS)
1. `xcodegen generate` を実行して `DietApp.xcodeproj` を生成する
2. `DietApp.xcodeproj` を Xcode で開く
3. `PRODUCT_BUNDLE_IDENTIFIER`(現在 `com.example.dietapp` / `com.example.dietapp.widget`)を自分のApple Developerアカウントに合わせて変更する
4. `DietApp` スキームを選択してビルド・実行する

## ディレクトリ構成
```
DietApp/                     # メインアプリターゲット
  App/                       # エントリーポイント、AppState、タブ構成
  Core/
    Persistence/              # SwiftData モデルコンテナ
    Security/                 # ローカル認証用のハッシュ化・Keychain
    DesignSystem/             # カラーなど共通UI定義
  Features/
    Auth/                     # メール・パスワードのローカル認証
    MealLogging/               # 写真からのカロリー・栄養素推定
    Activity/                  # 万歩計・運動記録(HealthKit)
    Weight/                    # 体重記録・BMI
    DietPlan/                  # ダイエットプラン提示
    Suggestions/                # 食事・運動の提案
    Settings/                  # 機能カスタマイズ・サインアウト
  Resources/                  # Info.plist / entitlements(xcodegenが生成)
DietAppWidget/                 # ホーム画面ウィジェット
DietAppTests/
DietAppUITests/
docs/
  REQUIREMENTS.md
```

## 実装状況
- [x] プロジェクト雛形(XcodeGen構成、Feature単位のディレクトリ分割)
- [x] Auth機能 — メール・パスワードでのローカル認証(SwiftData + Keychain、パスワードは端末外に送信しない)
- [x] Weight / BMI — 身長・体重の記録とBMI計算
- [x] DietPlan — 目標体重・期間から必要な1日のカロリー収支を計算
- [x] Activity — HealthKitから今日の歩数・消費カロリーを取得 + 手動での運動記録
- [x] MealLogging — 写真からのカロリー・栄養素推定。LogMeal / OpenAI(GPT-4o系Vision)を設定画面で切り替え可能。**利用にはユーザー自身がAPIキーを取得し、設定画面に入力する必要がある**(APIキーはリポジトリに含めず、Keychainにのみ保存)
- [ ] Suggestions(食事・運動の提案)— MealLogging/DietPlanの結果を使う想定でまだ未実装
- [ ] Widget — 画面のみのプレースホルダー。App Group経由でのデータ共有は未実装

### MealLoggingのAPIキー取得先
- LogMeal: https://logmeal.com/api/ (無料枠あり、和食の認識精度は要検証)
- OpenAI: https://platform.openai.com/api-keys (従量課金、精度重視。1枚あたり数円未満〜数円程度を想定)

## 認証の設計メモ
- データは全て端末ローカル(SwiftData)に保存し、サーバーへは送信しない
- パスワードはそのまま保存せず、ソルト付きでストレッチングしたハッシュのみを保存する
- 最後にサインインしたユーザーのメールアドレスをKeychainに保持し、次回起動時に自動復帰する
