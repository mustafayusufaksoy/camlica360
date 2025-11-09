import SwiftUI

/// Reusable back button component
struct BackButton: View {
    @Environment(\.dismiss) var dismiss

    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            if let action = action {
                action()
            } else {
                dismiss()
            }
        }) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text(LocalizationKeys.back.localized)
            }
            .foregroundColor(AppColors.primary950)
        }
    }
}

// MARK: - Preview

#Preview {
    BackButton()
        .padding()
}
