import SwiftUI
import PhotosUI

/// File upload component with drag-drop interface and file picker
struct FileUploadView: View {
    let label: String
    let isRequired: Bool
    @Binding var selectedFiles: [URL]

    @State private var showFilePicker: Bool = false

    init(
        label: String,
        isRequired: Bool = false,
        selectedFiles: Binding<[URL]>
    ) {
        self.label = label
        self.isRequired = isRequired
        self._selectedFiles = selectedFiles
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Label
            HStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppFonts.smMedium)
                    .foregroundColor(AppColors.neutral950)

                if isRequired {
                    Text("*")
                        .font(AppFonts.smMedium)
                        .foregroundColor(Color(hex: "FB2C36"))
                }
            }

            // Upload Area
            VStack(spacing: AppSpacing.md) {
                // Drag & Drop Zone
                Button(action: {
                    showFilePicker = true
                }) {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primary600)

                        VStack(spacing: 4) {
                            Text("Dosya/medya sürükle ya da yükle")
                                .font(AppFonts.smRegular)
                                .foregroundColor(AppColors.neutral700)

                            Text("Desteklenen dosya tipleri: PNG, JPEG, JPG, GIF, PNG, PDF, HEIC")
                                .font(AppFonts.xsRegular)
                                .foregroundColor(AppColors.neutral500)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }

                        Text("Gözat")
                            .font(AppFonts.smMedium)
                            .foregroundColor(AppColors.primary600)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.sm)
                            .background(AppColors.white)
                            .cornerRadius(AppSpacing.radiusSm)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusSm)
                                    .stroke(AppColors.primary600, lineWidth: 1)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xl)
                    .background(AppColors.white)
                    .cornerRadius(AppSpacing.radiusMd)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusMd)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(AppColors.neutral300)
                    )
                }

                // Selected Files List
                if !selectedFiles.isEmpty {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(selectedFiles.indices, id: \.self) { index in
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.primary600)

                                Text(selectedFiles[index].lastPathComponent)
                                    .font(AppFonts.smRegular)
                                    .foregroundColor(AppColors.neutral700)
                                    .lineLimit(1)

                                Spacer()

                                Button(action: {
                                    selectedFiles.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.neutral400)
                                }
                            }
                            .padding(AppSpacing.sm)
                            .background(AppColors.neutral50)
                            .cornerRadius(AppSpacing.radiusSm)
                        }
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.image, .pdf],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                selectedFiles.append(contentsOf: urls)
            case .failure(let error):
                print("File picker error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        FileUploadView(
            label: "Dosya/Medya Ekleme",
            isRequired: false,
            selectedFiles: .constant([])
        )

        FileUploadView(
            label: "Dosya/Medya Ekleme",
            isRequired: true,
            selectedFiles: .constant([
                URL(fileURLWithPath: "/path/to/document.pdf"),
                URL(fileURLWithPath: "/path/to/image.png")
            ])
        )
    }
    .padding(AppSpacing.lg)
    .background(AppColors.background)
}
