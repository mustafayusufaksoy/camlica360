import SwiftUI

/// Custom multi-line text area component with label
struct CustomTextArea: View {
    let label: String
    let placeholder: String
    let isRequired: Bool
    @Binding var text: String
    var errorMessage: String? = nil
    var minHeight: CGFloat = 100

    init(
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        text: Binding<String>,
        errorMessage: String? = nil,
        minHeight: CGFloat = 100
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self._text = text
        self.errorMessage = errorMessage
        self.minHeight = minHeight
    }

    // MARK: - Computed Properties

    private var borderColor: Color {
        errorMessage != nil ? Color(hex: "FB2C36") : AppColors.neutral200
    }

    private var labelColor: Color {
        AppColors.neutral950
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Label
            HStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppFonts.smMedium)
                    .foregroundColor(labelColor)

                if isRequired {
                    Text("*")
                        .font(AppFonts.smMedium)
                        .foregroundColor(Color(hex: "FB2C36"))
                }
            }

            // TextEditor with placeholder
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(AppFonts.smRegular)
                        .foregroundColor(AppColors.neutral500)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $text)
                    .font(AppFonts.smRegular)
                    .foregroundColor(AppColors.black)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .frame(minHeight: minHeight)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.radiusMd)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMd)
                    .stroke(borderColor, lineWidth: 1)
            )

            // Error message hint
            if let error = errorMessage {
                Text(error)
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral500)
                    .lineLimit(3)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        CustomTextArea(
            label: "Açıklama",
            placeholder: "Açıklama giriniz...",
            isRequired: false,
            text: .constant("")
        )

        CustomTextArea(
            label: "Açıklama",
            placeholder: "Açıklama giriniz...",
            isRequired: true,
            text: .constant("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
            errorMessage: "Bu alan zorunludur"
        )
    }
    .padding(AppSpacing.lg)
}
