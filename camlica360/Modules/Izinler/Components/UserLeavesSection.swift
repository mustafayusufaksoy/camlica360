import SwiftUI

/// Horizontal scrollable user leaves section
struct UserLeavesSection: View {
    let leaveData: [UserLeaveData]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Section title
            HStack {
                Text("Kullanıcı İzinler")
                    .font(AppFonts.smMedium)
                    .foregroundColor(AppColors.black)

                Spacer()
            }

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(leaveData) { item in
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            // User name
                            Text(item.userName)
                                .font(AppFonts.xsRegular)
                                .foregroundColor(AppColors.neutral700)
                                .lineLimit(1)

                            // Card
                            UserLeaveCard(
                                userName: item.userName,
                                usedDays: item.usedDays,
                                remainingDays: item.remainingDays
                            )
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.radiusMd)
    }
}

// MARK: - Preview

#Preview {
    UserLeavesSection(leaveData: [
        UserLeaveData(userName: "Kullanıcı Bilgiler", usedDays: 4, remainingDays: 10),
        UserLeaveData(userName: "Değerler/Bakiye Ları", usedDays: 20, remainingDays: 0),
        UserLeaveData(userName: "Mazeret İzni", usedDays: 6, remainingDays: 8),
        UserLeaveData(userName: "Doğum İzni", usedDays: 2, remainingDays: 20)
    ])
    .background(AppColors.background)
}
