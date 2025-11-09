import SwiftUI

/// Approval status card component
struct ApprovalStatusCard: View {
    let statusData: [ApprovalStatusData]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Section title
            HStack {
                Text("İzin Onay Durumu")
                    .font(AppFonts.smMedium)
                    .foregroundColor(AppColors.black)

                Spacer()
            }

            // Status items
            VStack(spacing: AppSpacing.md) {
                ForEach(statusData) { item in
                    ApprovalStatusRow(data: item)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.radiusMd)
    }
}

// MARK: - Approval Status Row

private struct ApprovalStatusRow: View {
    let data: ApprovalStatusData

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            // Title and value
            HStack {
                Text(data.title)
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral700)

                Spacer()

                Text("\(data.count.formatted())")
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral700)

                Text("\(data.percentage)%")
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral600)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.neutral200)
                        .frame(height: 16)

                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(data.color)
                        .frame(width: geometry.size.width * CGFloat(data.percentage) / 100, height: 16)
                }
            }
            .frame(height: 16)
        }
    }
}

// MARK: - Preview

#Preview {
    ApprovalStatusCard(statusData: [
        ApprovalStatusData(title: "Onaylanan", count: 10450, percentage: 80, color: Color(hex: "00C853")),
        ApprovalStatusData(title: "Bekleyen", count: 10450, percentage: 60, color: Color(hex: "FFB300")),
        ApprovalStatusData(title: "Reddedilen", count: 8450, percentage: 10, color: Color(hex: "E53935"))
    ])
    .padding()
    .background(AppColors.background)
}
