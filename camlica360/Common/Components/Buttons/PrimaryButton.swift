import SwiftUI

/// Primary action button component
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(AppColors.white)
            } else {
                Text(title)
                    .font(AppFonts.mdMedium)
                    .foregroundColor(AppColors.white)
            }
        }
        .frame(height: AppSpacing.buttonHeight)
        .frame(maxWidth: .infinity)
        .background(isEnabled ? AppColors.primary950 : AppColors.lightGray)
        .cornerRadius(AppSpacing.radiusMd)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

/// Secondary action button component
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.mdMedium)
                .foregroundColor(AppColors.primary950)
        }
        .frame(height: AppSpacing.buttonHeight)
        .frame(maxWidth: .infinity)
        .background(AppColors.white)
        .border(AppColors.lightGray, width: 1)
        .cornerRadius(AppSpacing.radiusMd)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton(title: "Login", action: {})

        PrimaryButton(title: "Loading...", action: {}, isLoading: true)

        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)

        SecondaryButton(title: "Cancel", action: {})
    }
    .padding(AppSpacing.lg)
}
