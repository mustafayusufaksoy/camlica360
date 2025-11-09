import SwiftUI

/// Custom date picker component with label and calendar icon
struct CustomDatePicker: View {
    let label: String
    let placeholder: String
    let isRequired: Bool
    @Binding var selectedDate: Date?
    var errorMessage: String? = nil

    @State private var showDatePicker: Bool = false
    @State private var tempDate: Date = Date()

    init(
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        selectedDate: Binding<Date?>,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self._selectedDate = selectedDate
        self.errorMessage = errorMessage
    }

    // MARK: - Computed Properties

    private var borderColor: Color {
        errorMessage != nil ? Color(hex: "FB2C36") : AppColors.neutral200
    }

    private var labelColor: Color {
        AppColors.neutral950
    }

    private var displayText: String {
        if let date = selectedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
        return placeholder
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

            // Date Display Button
            Button(action: {
                if let date = selectedDate {
                    tempDate = date
                }
                showDatePicker.toggle()
            }) {
                HStack {
                    Text(displayText)
                        .font(AppFonts.smRegular)
                        .foregroundColor(selectedDate == nil ? AppColors.neutral500 : AppColors.black)

                    Spacer()

                    Image(systemName: "calendar")
                        .font(.system(size: 16))
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

            // Error message hint
            if let error = errorMessage {
                Text(error)
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral500)
                    .lineLimit(3)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            VStack(spacing: AppSpacing.lg) {
                // Header
                HStack {
                    Text("Tarih Seçin")
                        .font(AppFonts.lgBold)
                        .foregroundColor(AppColors.neutral950)

                    Spacer()

                    Button(action: {
                        showDatePicker = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.neutral400)
                    }
                }

                // Date Picker
                DatePicker(
                    "",
                    selection: Binding(
                        get: { tempDate },
                        set: { newValue in
                            tempDate = newValue
                            selectedDate = newValue
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showDatePicker = false
                            }
                        }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
            }
            .padding(AppSpacing.lg)
            .presentationDetents([.height(450)])
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        CustomDatePicker(
            label: "Başlangıç Tarihi",
            placeholder: "Tarih seçiniz",
            isRequired: true,
            selectedDate: .constant(nil)
        )

        CustomDatePicker(
            label: "Bitiş Tarihi",
            placeholder: "Tarih seçiniz",
            isRequired: true,
            selectedDate: .constant(Date())
        )
    }
    .padding(AppSpacing.lg)
}
