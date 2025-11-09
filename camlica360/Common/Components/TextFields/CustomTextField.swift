import SwiftUI

/// Custom text field component with label and validation support
struct CustomTextField: View {
    let label: String
    let placeholder: String
    let isRequired: Bool
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    var errorMessage: String? = nil

    @State private var isPasswordVisible: Bool = false

    init(
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.errorMessage = errorMessage
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

            // Input Field
            if isSecure {
                HStack(spacing: AppSpacing.sm) {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                            .font(AppFonts.smRegular)
                            .foregroundColor(AppColors.black)
                            .keyboardType(keyboardType)
                    } else {
                        SecureField(placeholder, text: $text)
                            .font(AppFonts.smRegular)
                            .foregroundColor(AppColors.black)
                            .keyboardType(keyboardType)
                    }

                    // Eye icon button
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(AppColors.neutral500)
                            .font(.system(size: AppSpacing.iconSize))
                    }
                }
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
            } else {
                TextField(placeholder, text: $text)
                    .font(AppFonts.smRegular)
                    .foregroundColor(AppColors.black)
                    .keyboardType(keyboardType)
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
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        // Normal state
        CustomTextField(
            label: "Company Code",
            placeholder: "Enter company code",
            isRequired: true,
            text: .constant("")
        )

        // Error state
        CustomTextField(
            label: "Company Code",
            placeholder: "Enter company code",
            isRequired: true,
            text: .constant(""),
            errorMessage: "Eksik ya da hatalı bir şirket kod girdiniz."
        )

        // Secure with error
        CustomTextField(
            label: "Password",
            placeholder: "Enter password",
            isRequired: true,
            text: .constant(""),
            isSecure: true,
            errorMessage: "Eksik ya da hatalı bir şifre girdiniz."
        )
    }
    .padding(AppSpacing.lg)
}
