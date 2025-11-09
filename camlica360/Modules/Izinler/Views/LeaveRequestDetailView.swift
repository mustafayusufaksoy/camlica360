import SwiftUI

/// View for displaying leave request details
struct LeaveRequestDetailView: View {
    let request: LeaveRequest
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("İzin Detayı")
                        .font(AppFonts.lgBold)
                        .foregroundColor(AppColors.neutral950)

                    Spacer()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
                .background(AppColors.white)

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        // Status Badge
                        Text(request.status.title)
                            .font(AppFonts.smMedium)
                            .foregroundColor(request.status.color)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.sm)
                            .background(request.status.backgroundColor)
                            .cornerRadius(20)

                        // Info Card
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            // Leave Type
                            ModernDetailRow(
                                label: "İzin Türü",
                                value: request.leaveType
                            )

                            Divider()

                            // Start Date
                            ModernDetailRow(
                                label: "Başlangıç Tarihi",
                                value: request.startDate
                            )

                            Divider()

                            // End Date
                            ModernDetailRow(
                                label: "Bitiş Tarihi",
                                value: request.endDate
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.lg)
                        .background(AppColors.white)
                        .cornerRadius(AppSpacing.radiusMd)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

                        // Description Card
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Açıklama")
                                .font(AppFonts.smMedium)
                                .foregroundColor(AppColors.neutral950)

                            Text(request.description)
                                .font(AppFonts.smRegular)
                                .foregroundColor(AppColors.neutral600)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.lg)
                        .background(AppColors.white)
                        .cornerRadius(AppSpacing.radiusMd)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

                        // Files/Media Section
                        if !request.attachments.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("Dosya/Medya")
                                    .font(AppFonts.smMedium)
                                    .foregroundColor(AppColors.neutral950)

                                HStack(alignment: .top, spacing: AppSpacing.md) {
                                    ForEach(request.attachments, id: \.self) { attachment in
                                        VStack(spacing: AppSpacing.xs) {
                                            // PDF Icon only
                                            Image(systemName: "doc.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(Color(hex: "FB2C36"))

                                            Text(attachment)
                                                .font(AppFonts.xsRegular)
                                                .foregroundColor(AppColors.neutral600)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                        }
                                        .frame(width: 80)
                                    }

                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(AppSpacing.lg)
                            .background(AppColors.white)
                            .cornerRadius(AppSpacing.radiusMd)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                    }
                    .padding(AppSpacing.lg)
                }
                .background(AppColors.background)
            }

            // Close Button (floating)
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.neutral500)
                    .frame(width: 32, height: 32)
                    .background(AppColors.neutral100)
                    .clipShape(Circle())
            }
            .padding(AppSpacing.lg)
        }
    }
}

// MARK: - Modern Detail Row Component

struct ModernDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFonts.xsRegular)
                .foregroundColor(AppColors.neutral600)

            Text(value)
                .font(AppFonts.smMedium)
                .foregroundColor(AppColors.neutral950)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    LeaveRequestDetailView(
        request: LeaveRequest(
            leaveType: "Yıllık İzin",
            duration: "2 gün",
            startDate: "28/07/2025 - 09:00",
            endDate: "28/07/2025 - 18:00",
            description: "Lorem ipsum dolor sit amet consectetur adipiscing elit ut aliquam purus sit amet luctus venenatis lectus magna fringilla urna porttitor.",
            status: .approved,
            attachments: ["document.pdf"]
        )
    )
}
