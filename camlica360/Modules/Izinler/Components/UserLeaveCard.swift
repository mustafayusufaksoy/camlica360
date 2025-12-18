import SwiftUI

/// User leave card for horizontal scroll
struct UserLeaveCard: View {
    let userName: String
    let usedDays: Int
    let remainingDays: Int

    private var totalDays: Int {
        usedDays + remainingDays
    }

    private var progress: Double {
        guard totalDays > 0 else { return 0 }
        let calculated = Double(usedDays) / Double(totalDays)
        // Guard against NaN and infinity
        guard !calculated.isNaN && !calculated.isInfinite else { return 0 }
        // Clamp between 0 and 1
        return min(max(calculated, 0), 1)
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Circular progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(AppColors.neutral200, lineWidth: 6)
                    .frame(width: 50, height: 50)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color(hex: "00C853"),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
            }

            // Days info
            HStack(spacing: AppSpacing.sm) {
                // Used days
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(usedDays)")
                            .font(AppFonts.smMedium)
                            .foregroundColor(AppColors.black)
                        Text("gün")
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral600)
                    }

                    Text("Kullanılan")
                        .font(AppFonts.xsRegular)
                        .foregroundColor(AppColors.neutral600)
                }

                // Remaining days
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(remainingDays)")
                            .font(AppFonts.smMedium)
                            .foregroundColor(AppColors.black)
                        Text("gün")
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral600)
                    }

                    Text("Kalan")
                        .font(AppFonts.xsRegular)
                        .foregroundColor(AppColors.neutral600)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.radiusMd)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: AppSpacing.md) {
        UserLeaveCard(userName: "Kullanıcı Bilgiler", usedDays: 4, remainingDays: 10)
        UserLeaveCard(userName: "Değerler/Bakiye Ları", usedDays: 20, remainingDays: 0)
        UserLeaveCard(userName: "Mazeret İzni", usedDays: 6, remainingDays: 8)
    }
    .padding()
    .background(AppColors.background)
}
