import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct MealCaptureView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MealLoggingViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    MealCaptureContentView(viewModel: viewModel, onSaved: { dismiss() })
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("写真から記録")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .onAppear {
            if viewModel == nil, let user = appState.currentUser {
                viewModel = MealLoggingViewModel(modelContext: modelContext, user: user)
            }
        }
    }
}

private struct MealCaptureContentView: View {
    @Bindable var viewModel: MealLoggingViewModel
    let onSaved: () -> Void

    @State private var showingPicker = false
    @State private var pickerErrorMessage: String?

    var body: some View {
        Form {
            Section {
                Button {
                    showingPicker = true
                } label: {
                    Label("写真を選ぶ", systemImage: "photo")
                }
                .sheet(isPresented: $showingPicker) {
                    PhotoPickerRepresentable(
                        onImagePicked: { data in
                            pickerErrorMessage = nil
                            Task { await viewModel.setSelectedImage(data) }
                        },
                        onError: { message in
                            pickerErrorMessage = message
                        }
                    )
                    .ignoresSafeArea()
                }

                if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                }
            }

            if viewModel.isRecognizing {
                HStack {
                    Spacer()
                    ProgressView("解析中…")
                    Spacer()
                }
            }

            if let errorMessage = pickerErrorMessage ?? viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if !viewModel.recognitionResults.isEmpty {
                Section("認識結果") {
                    ForEach(Array(viewModel.recognitionResults.enumerated()), id: \.offset) { _, result in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.foodName)
                                .font(.headline)
                            Text(String(
                                format: "%.0f kcal ・ たんぱく質 %.1fg ・ 脂質 %.1fg",
                                result.estimatedCalories, result.proteinGrams, result.fatGrams
                            ))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            Button("この内容で記録する") {
                                viewModel.saveResult(result)
                                onSaved()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.dietAppAccent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

// SwiftUIのPhotosPicker + Transferableは端末によって
// "The data couldn't be read because it is missing" で失敗する既知の不具合があるため、
// より枯れたPHPickerViewController + NSItemProviderで写真データを取得する。
private struct PhotoPickerRepresentable: UIViewControllerRepresentable {
    var onImagePicked: (Data) -> Void
    var onError: (String) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, onError: onError)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onImagePicked: (Data) -> Void
        let onError: (String) -> Void

        init(onImagePicked: @escaping (Data) -> Void, onError: @escaping (String) -> Void) {
            self.onImagePicked = onImagePicked
            self.onError = onError
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [onImagePicked, onError] object, error in
                DispatchQueue.main.async {
                    if let error {
                        onError(error.localizedDescription)
                        return
                    }
                    guard let uiImage = object as? UIImage, let data = uiImage.jpegData(compressionQuality: 0.85) else {
                        onError("選択した写真を読み込めませんでした。別の写真で試してください。")
                        return
                    }
                    onImagePicked(data)
                }
            }
        }
    }
}
