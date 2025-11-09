import SwiftUI

/// Reset password view for setting new password
struct ResetPasswordView: View {
    @StateObject private var viewModel: ResetPasswordViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FocusField?

    enum FocusField {
        case otp
        case newPassword
        case confirmPassword
    }

    // MARK: - Initialization

    init(companyCode: String, idNumber: String) {
        self._viewModel = StateObject(wrappedValue: ResetPasswordViewModel(
            companyCode: companyCode,
            idNumber: idNumber
        ))
    }

    var body: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with logo and back button
                headerSection

                ScrollView {
                    VStack(spacing: 0) {
                        // Content
                        VStack(spacing: AppSpacing.xxl) {
                            // Welcome section
                            welcomeSection

                            // Form fields
                            VStack(spacing: AppSpacing.lg) {
                                // OTP Code Field
                                CustomTextField(
                                    label: "Doğrulama Kodu",
                                    placeholder: "6 haneli kodu giriniz",
                                    isRequired: true,
                                    text: $viewModel.otp,
                                    keyboardType: .numberPad,
                                    errorMessage: viewModel.otpError
                                )
                                .focused($focusedField, equals: .otp)
                                .onChange(of: viewModel.otp) { _, newValue in
                                    // Limit to 6 digits
                                    if newValue.count > 6 {
                                        viewModel.otp = String(newValue.prefix(6))
                                    }
                                    viewModel.validateFields()
                                }

                                // New Password Field
                                CustomTextField(
                                    label: LocalizationKeys.resetPasswordNewPassword.localized,
                                    placeholder: LocalizationKeys.resetPasswordNewPasswordPlaceholder.localized,
                                    isRequired: true,
                                    text: $viewModel.newPassword,
                                    isSecure: true,
                                    errorMessage: viewModel.newPasswordError
                                )
                                .focused($focusedField, equals: .newPassword)
                                .onChange(of: viewModel.newPassword) { _, _ in
                                    viewModel.validateFields()
                                }

                                // Confirm Password Field
                                CustomTextField(
                                    label: LocalizationKeys.resetPasswordConfirmPassword.localized,
                                    placeholder: LocalizationKeys.resetPasswordConfirmPasswordPlaceholder.localized,
                                    isRequired: true,
                                    text: $viewModel.confirmPassword,
                                    isSecure: true,
                                    errorMessage: viewModel.confirmPasswordError
                                )
                                .focused($focusedField, equals: .confirmPassword)
                                .onChange(of: viewModel.confirmPassword) { _, _ in
                                    viewModel.validateFields()
                                }
                            }

                            // Update Button
                            PrimaryButton(
                                title: LocalizationKeys.resetPasswordButton.localized,
                                action: {
                                    Task {
                                        await viewModel.resetPassword()
                                        if viewModel.isSuccess {
                                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                                            dismiss()
                                        }
                                    }
                                },
                                isLoading: viewModel.isLoading,
                                isEnabled: viewModel.isFormValid() && !viewModel.isLoading
                            )

                            // Error message
                            if let error = viewModel.error {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(Color(hex: "FB2C36"))

                                    Text(error)
                                        .font(AppFonts.smRegular)
                                        .foregroundColor(Color(hex: "FB2C36"))

                                    Spacer()
                                }
                                .padding(AppSpacing.lg)
                                .background(Color(hex: "FB2C36").opacity(0.1))
                                .cornerRadius(AppSpacing.radiusMd)
                            }

                            // Success message
                            if viewModel.isSuccess, let message = viewModel.successMessage {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.success)

                                    Text(message)
                                        .font(AppFonts.smRegular)
                                        .foregroundColor(AppColors.success)

                                    Spacer()
                                }
                                .padding(AppSpacing.lg)
                                .background(AppColors.success.opacity(0.1))
                                .cornerRadius(AppSpacing.radiusMd)
                            }
                        }
                        .padding(AppSpacing.lg)

                        Spacer()

                        // Footer
                        footerSection
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.lg)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BackButton()

                Spacer()

                Image("crm-siyah-logo-login")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 38)
            }
            .padding(AppSpacing.lg)
            .border(AppColors.lightGray, width: 1)

            Divider()
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(LocalizationKeys.resetPasswordTitle.localized)
                .font(AppFonts.extraLarge(size: 24, weight: .medium))
                .foregroundColor(AppColors.black)

            Text(LocalizationKeys.resetPasswordSubtitle.localized)
                .font(AppFonts.smRegular)
                .foregroundColor(AppColors.neutral600)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(LocalizationKeys.resetPasswordFooter.localized)
                .font(AppFonts.xsRegular)
                .foregroundColor(AppColors.neutral600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ResetPasswordView(
            companyCode: "preview-company",
            idNumber: "12345678901"
        )
    }
}
