import SwiftUI

/// Signup view for user registration
struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    @FocusState private var focusedField: FocusField?
    @Environment(\.dismiss) var dismiss

    enum FocusField {
        case email
        case fullName
        case phone
        case companyCode
    }

    var body: some View {
        ZStack {
            if viewModel.isSignupSuccessful {
                // Success screen with confetti
                successScreen
            } else {
                // Normal signup form
                signupFormScreen
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: viewModel.isSignupSuccessful ? AnyView(EmptyView()) : AnyView(backButton))
    }

    // MARK: - Signup Form Screen

    private var signupFormScreen: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header with logo and back button
                    headerSection

                    // Signup content
                    VStack(spacing: AppSpacing.xxl) {
                        // Welcome text
                        welcomeSection

                        // Form fields
                        VStack(spacing: AppSpacing.lg) {
                            // Email Field
                            CustomTextField(
                                label: LocalizationKeys.signupEmail.localized,
                                placeholder: LocalizationKeys.signupEmailPlaceholder.localized,
                                isRequired: true,
                                text: $viewModel.email,
                                keyboardType: .emailAddress,
                                errorMessage: viewModel.emailError
                            )
                            .focused($focusedField, equals: .email)
                            .onChange(of: viewModel.email) { _, _ in
                                viewModel.validateFields()
                            }

                            // Full Name Field
                            CustomTextField(
                                label: LocalizationKeys.signupFullName.localized,
                                placeholder: LocalizationKeys.signupFullNamePlaceholder.localized,
                                isRequired: true,
                                text: $viewModel.fullName,
                                errorMessage: viewModel.fullNameError
                            )
                            .focused($focusedField, equals: .fullName)
                            .onChange(of: viewModel.fullName) { _, _ in
                                viewModel.validateFields()
                            }

                            // Phone Field (Optional)
                            CustomTextField(
                                label: LocalizationKeys.signupPhone.localized,
                                placeholder: LocalizationKeys.signupPhonePlaceholder.localized,
                                isRequired: false,
                                text: $viewModel.phone,
                                keyboardType: .phonePad,
                                errorMessage: viewModel.phoneError
                            )
                            .focused($focusedField, equals: .phone)
                            .onChange(of: viewModel.phone) { _, _ in
                                viewModel.validateFields()
                            }

                            // Company Code field removed - not needed for self-registration
                        }

                        // Terms and Conditions Checkbox
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            CheckboxView(
                                label: LocalizationKeys.signupTermsAgreement.localized,
                                isChecked: $viewModel.agreeToTerms
                            )

                            Text(LocalizationKeys.signupTermsDescription.localized)
                                .font(AppFonts.xsRegular)
                                .foregroundColor(AppColors.neutral600)
                        }

                        // Signup Button
                        PrimaryButton(
                            title: LocalizationKeys.signupButton.localized,
                            action: {
                                Task {
                                    await viewModel.signup()
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

                        // Success message removed - now shown in full screen

                        // Login Link
                        HStack(spacing: AppSpacing.xs) {
                            Text(LocalizationKeys.signupHaveAccount.localized)
                                .font(AppFonts.smRegular)
                                .foregroundColor(AppColors.neutral600)

                            NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true)) {
                                Text(LocalizationKeys.signupLoginLink.localized)
                                    .font(AppFonts.smMedium)
                                    .foregroundColor(AppColors.primary950)
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
    }

    // MARK: - Success Screen

    private var successScreen: some View {
        ZStack {
            // Background color (same as SplashScreen)
            AppColors.primary950
                .ignoresSafeArea()

            // Confetti effect
            ConfettiView()

            // Content
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: AppSpacing.lg) {
                    // Success badge
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primary950)

                        Text("Kayıt Oluşturuldu!")
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.primary950)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(.white.opacity(0.95))
                    .cornerRadius(AppSpacing.radiusSm)

                    // Main message
                    VStack(spacing: AppSpacing.sm) {
                        Text("Tebrikler \(viewModel.fullName.components(separatedBy: " ").first ?? "")!")
                            .font(AppFonts.extraLarge(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Başlamaya hazırsınız!")
                            .font(AppFonts.large(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }

                    // Subtitle
                    Text("Hesabınızı oluşturdunuz. En kısa zamanda \nsizinle iletişime geçilecektir.")
                        .font(AppFonts.smRegular)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.top, AppSpacing.sm)
                }

                Spacer()

                // Action button
                Button(action: {
                    dismiss()
                }) {
                    Text("Giriş Sayfasına Dön")
                        .font(AppFonts.mdMedium)
                        .foregroundColor(AppColors.primary950)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
    }

    // MARK: - Subviews

    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary950)
            }
        }
    }

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
            Text(LocalizationKeys.signupWelcome.localized)
                .font(AppFonts.extraLarge(size: 24, weight: .medium))
                .foregroundColor(AppColors.black)

            Text(LocalizationKeys.signupSubtitle.localized)
                .font(AppFonts.smRegular)
                .foregroundColor(AppColors.neutral600)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(LocalizationKeys.signupTermsText.localized)
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
        SignupView()
    }
}
