import SwiftUI

/// Custom time picker component with label and clock icon
struct CustomTimePicker: View {
    let label: String
    let placeholder: String
    let isRequired: Bool
    @Binding var selectedTime: Date?
    var errorMessage: String? = nil

    @State private var showTimePicker: Bool = false
    @State private var tempTime: Date = Date()

    init(
        label: String,
        placeholder: String,
        isRequired: Bool = false,
        selectedTime: Binding<Date?>,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
        self._selectedTime = selectedTime
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
        if let time = selectedTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: time)
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

            // Time Display Button
            Button(action: {
                if let time = selectedTime {
                    tempTime = time
                }
                showTimePicker.toggle()
            }) {
                HStack {
                    Text(displayText)
                        .font(AppFonts.smRegular)
                        .foregroundColor(selectedTime == nil ? AppColors.neutral500 : AppColors.black)

                    Spacer()

                    Image(systemName: "clock")
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
        .sheet(isPresented: $showTimePicker) {
            VStack(spacing: AppSpacing.lg) {
                // Header
                HStack {
                    Text("Saat Seçin")
                        .font(AppFonts.lgBold)
                        .foregroundColor(AppColors.neutral950)

                    Spacer()

                    Button(action: {
                        selectedTime = tempTime
                        showTimePicker = false
                    }) {
                        Text("Tamam")
                            .font(AppFonts.smMedium)
                            .foregroundColor(AppColors.primary600)
                    }
                }

                // Time Picker
                DatePicker(
                    "",
                    selection: $tempTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: tempTime) { newValue in
                    selectedTime = newValue
                }
            }
            .padding(AppSpacing.lg)
            .presentationDetents([.height(300)])
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        CustomTimePicker(
            label: "Başlangıç Saati",
            placeholder: "Saat seçiniz",
            isRequired: true,
            selectedTime: .constant(nil)
        )

        CustomTimePicker(
            label: "Bitiş Saati",
            placeholder: "Saat seçiniz",
            isRequired: true,
            selectedTime: .constant(Date())
        )
    }
    .padding(AppSpacing.lg)
}
