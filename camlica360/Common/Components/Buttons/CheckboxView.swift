import SwiftUI

/// Custom checkbox component
struct CheckboxView: View {
    let label: String
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: AppSpacing.sm) {
                // Checkbox icon
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(isChecked ? AppColors.primary950 : AppColors.neutral500)

                Text(label)
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral700)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        CheckboxView(label: "Remember me", isChecked: .constant(true))

        CheckboxView(label: "I agree to terms and conditions", isChecked: .constant(false))
    }
    .padding(AppSpacing.lg)
}
