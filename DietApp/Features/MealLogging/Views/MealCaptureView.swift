import SwiftUI

// TODO: カメラ/フォトライブラリからの写真選択とFoodRecognitionServiceの呼び出しを実装する
struct MealCaptureView: View {
    var body: some View {
        ContentUnavailableView(
            "写真の撮影・選択は準備中",
            systemImage: "camera",
            description: Text("食事の写真を撮影・選択してカロリーを推定する画面です。")
        )
    }
}
