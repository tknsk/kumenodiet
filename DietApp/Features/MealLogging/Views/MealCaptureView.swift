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

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pickerErrorMessage: String?

    var body: some View {
        Form {
            Section {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("写真を選ぶ", systemImage: "photo")
                }
                .onChange(of: selectedPhotoItem) {
                    Task { await loadSelectedPhoto() }
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

    private func loadSelectedPhoto() async {
        pickerErrorMessage = nil
        guard let selectedPhotoItem else { return }
        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self) {
                await viewModel.setSelectedImage(data)
            }
        } catch {
            pickerErrorMessage = error.localizedDescription
        }
    }
}
