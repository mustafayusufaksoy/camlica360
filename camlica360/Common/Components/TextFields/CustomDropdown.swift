import SwiftUI

/// Dropdown option model with title and description
struct DropdownOption: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String?

    init(title: String, description: String? = nil) {
        self.title = title
        self.description = description
    }

    static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        lhs.title == rhs.title
    }
}

/// Custom dropdown/picker component with label
struct CustomDropdown: View {
    let label: String
    let placeholder: String
    let isRequired: Bool
    let options: [DropdownOption]
    @Binding var selectedOption: DropdownOption?
    var errorMessage: String? = nil

    @State private var isExpanded: Bool = false

    init(
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        options: [DropdownOption],
        selectedOption: Binding<DropdownOption?>,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.options = options
        self._selectedOption = selectedOption
        self.errorMessage = errorMessage
    }

    // MARK: - Computed Properties

    private var borderColor: Color {
        if errorMessage != nil {
            return Color(hex: "FB2C36")
        } else if isExpanded || selectedOption != nil {
            return AppColors.primary600
        } else {
            return AppColors.neutral200
        }
    }

    private var labelColor: Color {
        AppColors.neutral950
    }

    private var displayText: String {
        selectedOption?.title ?? placeholder
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

            // Dropdown Button
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(displayText)
                        .font(AppFonts.smRegular)
                        .foregroundColor(selectedOption == nil ? AppColors.neutral500 : AppColors.neutral950)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.neutral500)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.white)
                .cornerRadius(AppSpacing.radiusMd)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusMd)
                        .stroke(borderColor, lineWidth: 1)
                )
            }

            // Options List
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(options) { option in
                        Button(action: {
                            selectedOption = option
                            withAnimation {
                                isExpanded = false
                            }
                        }) {
                            HStack(alignment: .top, spacing: AppSpacing.sm) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.title)
                                        .font(AppFonts.smMedium)
                                        .foregroundColor(AppColors.neutral950)
                                        .multilineTextAlignment(.leading)

                                    if let description = option.description {
                                        Text(description)
                                            .font(AppFonts.xsRegular)
                                            .foregroundColor(AppColors.neutral600)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                if selectedOption == option {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.primary600)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedOption == option ? AppColors.neutral50 : AppColors.white)
                        }
                    }
                }
                .padding(.vertical, AppSpacing.lg)
                .background(AppColors.white)
                .cornerRadius(AppSpacing.radiusMd)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusMd)
                        .stroke(AppColors.neutral200, lineWidth: 1)
                )
                .transition(.opacity)
            }

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
    let sampleOptions = [
        DropdownOption(title: "Yıllık İzin", description: "Yıllık ücretli izin"),
        DropdownOption(title: "Hastalık İzni", description: "Hastalık veya sağlık ihtiyaçları nedeniyle verilen izin. Ücretli veya ücretsiz olabilir."),
        DropdownOption(title: "Doğum/Babalık İzni", description: "Bu izin, yıllık izinden düşülmez ve belirli süre ücretli olarak verilir.")
    ]

    return VStack(spacing: AppSpacing.lg) {
        CustomDropdown(
            label: "İzin Türü",
            placeholder: "İzin türü seçiniz",
            isRequired: true,
            options: sampleOptions,
            selectedOption: .constant(nil)
        )

        CustomDropdown(
            label: "İzin Türü",
            placeholder: "İzin türü seçiniz",
            isRequired: true,
            options: sampleOptions,
            selectedOption: .constant(sampleOptions[1])
        )
    }
    .padding(AppSpacing.lg)
    .background(AppColors.background)
}
