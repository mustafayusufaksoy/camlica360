import SwiftUI

/// Forgot password view for password reset
struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @FocusState private var focusedField: FocusField?

    enum FocusField {
        case companyCode
        case idNumber
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
                                // Company Code Field
                                CustomTextField(
                                    label: LocalizationKeys.loginCompanyCode.localized,
                                    placeholder: LocalizationKeys.loginCompanyCodePlaceholder.localized,
                                    isRequired: true,
                                    text: $viewModel.companyCode,
                                    errorMessage: viewModel.companyCodeError
                                )
                                .focused($focusedField, equals: .companyCode)
                                .onChange(of: viewModel.companyCode) { _, _ in
                                    viewModel.validateFields()
                                }

                                // ID Number Field
                                CustomTextField(
                                    label: LocalizationKeys.loginIdNumber.localized,
                                    placeholder: LocalizationKeys.loginIdNumberPlaceholder.localized,
                                    isRequired: true,
                                    text: $viewModel.idNumber,
                                    keyboardType: .numberPad,
                                    errorMessage: viewModel.idNumberError
                                )
                                .focused($focusedField, equals: .idNumber)
                                .onChange(of: viewModel.idNumber) { _, _ in
                                    viewModel.validateFields()
                                }
                            }

                            // Send Reset Code Button
                            PrimaryButton(
                                title: LocalizationKeys.forgotPasswordButton.localized,
                                action: {
                                    Task {
                                        await viewModel.sendResetCode()
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
        .navigationDestination(isPresented: $viewModel.showOTPVerification) {
            ResetPasswordView(
                companyCode: viewModel.companyCode,
                idNumber: viewModel.idNumber
            )
            .navigationBarBackButtonHidden(true)
        }
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
            Text(LocalizationKeys.forgotPasswordTitle.localized)
                .font(AppFonts.extraLarge(size: 24, weight: .medium))
                .foregroundColor(AppColors.black)

            Text(LocalizationKeys.forgotPasswordSubtitle.localized)
                .font(AppFonts.smRegular)
                .foregroundColor(AppColors.neutral600)
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(LocalizationKeys.forgotPasswordFooter.localized)
                .font(AppFonts.xsRegular)
                .foregroundColor(AppColors.neutral600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
