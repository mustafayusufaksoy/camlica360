import SwiftUI

/// Profile button component showing user avatar or initials
struct ProfileButton: View {
    let userInfo: UserInfo?
    let action: () -> Void

    private var initials: String {
        userInfo?.initials ?? "?"
    }

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(AppColors.primary950.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Group {
                        if let avatarUrl = userInfo?.avatarUrl, !avatarUrl.isEmpty {
                            // TODO: Load avatar image from URL
                            // For now, show initials
                            Text(initials)
                                .font(AppFonts.custom(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.primary950)
                        } else {
                            Text(initials)
                                .font(AppFonts.custom(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.primary950)
                        }
                    }
                )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.lg) {
        // With user info
        ProfileButton(
            userInfo: UserInfo(
                userId: "123",
                fullName: "Satış Danışmanı"
            ),
            action: { print("Profile tapped") }
        )

        // Without user info
        ProfileButton(
            userInfo: nil,
            action: { print("Profile tapped") }
        )
    }
    .padding()
}
