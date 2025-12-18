import SwiftUI

/// Login view for user authentication
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: FocusField?
    @State private var showResetPassword = false

    enum FocusField {
        case companyCode
        case idNumber
        case password
    }

    var body: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header with logo
                    headerSection

                    // Login content
                    VStack(spacing: AppSpacing.xxl) {
                        // Welcome text
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

                            // Password Field
                            CustomTextField(
                                label: LocalizationKeys.loginPassword.localized,
                                placeholder: LocalizationKeys.loginPasswordPlaceholder.localized,
                                isRequired: true,
                                text: $viewModel.password,
                                isSecure: true,
                                errorMessage: viewModel.passwordError
                            )
                            .focused($focusedField, equals: .password)
                            .onChange(of: viewModel.password) { _, _ in
                                viewModel.validateFields()
                            }
                        }

                        // Remember me and Forgot password
                        HStack {
                            CheckboxView(
                                label: LocalizationKeys.loginRememberMe.localized,
                                isChecked: $viewModel.rememberMe
                            )

                            Spacer()

                            NavigationLink(destination: ForgotPasswordView().navigationBarBackButtonHidden(true)) {
                                Text(LocalizationKeys.loginForgotPassword.localized)
                                    .font(AppFonts.xsMedium)
                                    .foregroundColor(AppColors.primary950)
                            }
                        }

                        // Login Button
                        PrimaryButton(
                            title: LocalizationKeys.loginButton.localized,
                            action: {
                                Task {
                                    await viewModel.login()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isEnabled: viewModel.isFormValid() && !viewModel.isLoading
                        )

                        // Signup Link
                        HStack(spacing: AppSpacing.xs) {
                            Text("Hesapların yok mu?")
                                .font(AppFonts.smRegular)
                                .foregroundColor(AppColors.neutral600)

                            NavigationLink(destination: SignupView().navigationBarBackButtonHidden(true)) {
                                Text("Kaydol")
                                    .font(AppFonts.smMedium)
                                    .foregroundColor(AppColors.primary950)
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

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
                        if viewModel.isLoginSuccessful {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.success)

                                Text("Giriş başarılı!")
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

                    // Footer with terms
                    footerSection
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.lg)
                }
            }
            .onTapGesture {
                // Dismiss keyboard when tapping anywhere
                focusedField = nil
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $viewModel.shouldNavigateToOTP) {
            if let loginResponse = viewModel.loginResponse {
                OTPVerificationView(
                    userId: loginResponse.userId,
                    companyCode: loginResponse.companyCode ?? "",
                    showResetPassword: $showResetPassword
                )
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image("crm-siyah-logo-login")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 38)

                Spacer()
            }
            .padding(AppSpacing.lg)
            .border(AppColors.lightGray, width: 1)

            Divider()
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(LocalizationKeys.loginWelcome.localized)
                .font(AppFonts.extraLarge(size: 24, weight: .medium))
                .foregroundColor(AppColors.black)

            Text(LocalizationKeys.loginSubtitle.localized)
                .font(AppFonts.smRegular)
                .foregroundColor(AppColors.neutral600)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(LocalizationKeys.loginTermsText.localized)
                .font(AppFonts.xsRegular)
                .foregroundColor(AppColors.neutral600)
                .lineLimit(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LoginView()
    }
}
