import SwiftUI

/// View for creating a new leave request
struct CreateLeaveRequestView: View {
    @StateObject private var viewModel = CreateLeaveRequestViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.neutral700)
                }

                Spacer()

                Text("İzin Talep Oluştur")
                    .font(AppFonts.lgBold)
                    .foregroundColor(AppColors.neutral950)

                Spacer()

                // Spacer to balance the layout
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.white)

            Divider()

            // Form Content
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Leave Type Dropdown
                    CustomDropdown(
                        label: "İzin Türü",
                        placeholder: "İzin türü seçiniz",
                        isRequired: true,
                        options: viewModel.leaveTypeOptions,
                        selectedOption: $viewModel.leaveType,
                        errorMessage: viewModel.leaveTypeError
                    )

                    // Start Date
                    CustomDatePicker(
                        label: "Başlangıç Tarihi",
                        placeholder: "Tarih seçiniz",
                        isRequired: true,
                        selectedDate: $viewModel.startDate,
                        errorMessage: viewModel.startDateError
                    )

                    // Start Time
                    CustomTimePicker(
                        label: "Başlangıç Saati",
                        placeholder: "Saat seçiniz",
                        isRequired: true,
                        selectedTime: $viewModel.startTime,
                        errorMessage: viewModel.startTimeError
                    )

                    // End Date
                    CustomDatePicker(
                        label: "Bitiş Tarihi",
                        placeholder: "Tarih seçiniz",
                        isRequired: true,
                        selectedDate: $viewModel.endDate,
                        errorMessage: viewModel.endDateError
                    )

                    // End Time
                    CustomTimePicker(
                        label: "Bitiş Saati",
                        placeholder: "Saat seçiniz",
                        isRequired: true,
                        selectedTime: $viewModel.endTime,
                        errorMessage: viewModel.endTimeError
                    )

                    // Description
                    CustomTextArea(
                        label: "Açıklama",
                        placeholder: "Açıklama giriniz...",
                        isRequired: false,
                        text: $viewModel.description,
                        minHeight: 100
                    )

                    // File Upload
                    FileUploadView(
                        label: "Dosya/Medya Ekleme",
                        isRequired: false,
                        selectedFiles: $viewModel.selectedFiles
                    )

                    // Error/Warning Message
                    if let errorMessage = viewModel.errorMessage {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "FB2C36"))

                                Text("Dikkat!")
                                    .font(AppFonts.smMedium)
                                    .foregroundColor(Color(hex: "FB2C36"))
                            }

                            Text(errorMessage)
                                .font(AppFonts.xsRegular)
                                .foregroundColor(Color(hex: "FB2C36"))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "FB2C36").opacity(0.1))
                        .cornerRadius(AppSpacing.radiusSm)
                    }

                    // Duration Info
                    if viewModel.startDate != nil && viewModel.endDate != nil {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Toplam:")
                                    .font(AppFonts.smMedium)
                                    .foregroundColor(AppColors.neutral950)

                                Text("Girdiğiniz tarihe göre toplam gün")
                                    .font(AppFonts.xsRegular)
                                    .foregroundColor(AppColors.neutral600)
                            }

                            Spacer()

                            Text(viewModel.totalDuration)
                                .font(AppFonts.smMedium)
                                .foregroundColor(AppColors.neutral950)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.white)
                        .cornerRadius(AppSpacing.radiusSm)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.radiusSm)
                                .stroke(AppColors.neutral200, lineWidth: 1)
                        )
                    }

                    // Submit Button
                    PrimaryButton(
                        title: "Gönder",
                        action: {
                            Task {
                                await viewModel.submitLeaveRequest()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isEnabled: !viewModel.isLoading
                    )
                    .padding(.top, AppSpacing.md)
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
        }
        .alert("Başarılı", isPresented: $viewModel.showSuccessAlert) {
            Button("Tamam", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("İzin talebiniz başarıyla oluşturuldu.")
        }
    }
}

// MARK: - Preview

#Preview {
    CreateLeaveRequestView()
}
