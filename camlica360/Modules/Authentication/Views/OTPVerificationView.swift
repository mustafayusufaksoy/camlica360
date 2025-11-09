import SwiftUI

/// OTP verification modal view
struct OTPVerificationView: View {
    @StateObject private var viewModel: OTPVerificationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var focusedField: Int = 0
    @Binding var showResetPassword: Bool

    // Hidden field for SMS autofill
    @State private var otpCodeForAutofill: String = ""
    @FocusState private var isAutofillFieldFocused: Bool

    // MARK: - Initialization

    init(userId: String, companyCode: String, showResetPassword: Binding<Bool>) {
        self._showResetPassword = showResetPassword
        self._viewModel = StateObject(wrappedValue: OTPVerificationViewModel(
            userId: userId,
            companyCode: companyCode
        ))
    }

    var body: some View {
        ZStack {
            AppColors.white
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xxl) {
                // Header with back button
                HStack {
                    BackButton()

                    Spacer()

                    Image("crm-siyah-logo-login")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
                .padding(AppSpacing.lg)
                .border(AppColors.neutral200, width: 1)

                Spacer()

                VStack(spacing: AppSpacing.lg) {
                    // Title & Subtitle
                    VStack(spacing: AppSpacing.sm) {
                        Text(LocalizationKeys.otpVerificationTitle.localized)
                            .font(AppFonts.extraLarge(size: 18, weight: .bold))
                            .foregroundColor(AppColors.black)

                        VStack(spacing: AppSpacing.sm) {
                            Text(LocalizationKeys.otpVerificationSubtitle.localized)
                                .font(AppFonts.xsRegular)
                                .foregroundColor(AppColors.neutral700)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Hidden TextField for SMS autofill
                    ZStack {
                        TextField("", text: $otpCodeForAutofill)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .focused($isAutofillFieldFocused)
                            .frame(height: 0)
                            .opacity(0)
                            .onChange(of: otpCodeForAutofill) { _, newValue in
                                // When SMS code is autofilled, distribute digits
                                if newValue.count == 6 {
                                    let digits = Array(newValue)
                                    for (index, digit) in digits.enumerated() {
                                        viewModel.otpDigits[index] = String(digit)
                                    }
                                    // Hide keyboard after autofill
                                    isAutofillFieldFocused = false
                                }
                            }
                    }

                    // OTP Input Fields
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            OTPInputField(
                                value: $viewModel.otpDigits[index],
                                shouldBeFocused: focusedField == index,
                                onMovedToNext: {
                                    // Move to next field if not last
                                    if index < 5 {
                                        focusedField = index + 1
                                    }
                                },
                                onMovedToPrevious: {
                                    // Move to previous field if not first
                                    if index > 0 {
                                        focusedField = index - 1
                                    }
                                }
                            )
                        }
                    }
                    .onChange(of: viewModel.otpDigits) { _, _ in
                        // Auto-verify when all 6 digits are entered
                        guard viewModel.isOTPComplete && !viewModel.isLoading else { return }

                        Task {
                            await viewModel.verifyOTP()

                            if viewModel.error == nil {
                                // Success - set flag to show reset password view
                                await MainActor.run {
                                    showResetPassword = true
                                }
                                // Close modal after 1 second
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                dismiss()
                            } else {
                                // Error - reset focus to first field
                                await MainActor.run {
                                    focusedField = 0
                                }
                            }
                        }
                    }

                    // Timer and Paste Button
                    HStack(spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.sm) {
                            Text("Kod süresi:")
                                .font(AppFonts.xsMedium)
                                .foregroundColor(AppColors.neutral700)

                            Text(viewModel.formattedTimeRemaining())
                                .font(AppFonts.xsMedium)
                                .foregroundColor(AppColors.primary950)
                        }

                        Spacer()

                        // Paste button
                        Button(action: {
                            if let clipboard = UIPasteboard.general.string,
                               clipboard.count == 6,
                               clipboard.allSatisfy({ $0.isNumber }) {
                                let digits = Array(clipboard)
                                for (index, digit) in digits.enumerated() {
                                    viewModel.otpDigits[index] = String(digit)
                                }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 12))
                                Text("Yapıştır")
                                    .font(AppFonts.xsMedium)
                            }
                            .foregroundColor(AppColors.primary950)
                        }
                    }

                    // Verify Button
                    PrimaryButton(
                        title: LocalizationKeys.otpVerificationButton.localized,
                        action: {
                            Task {
                                await viewModel.verifyOTP()
                                // If verification successful, close modal after 1 second
                                if viewModel.error == nil {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        dismiss()
                                    }
                                } else {
                                    // Reset focus to first field on error
                                    focusedField = 0
                                }
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isOTPComplete && !viewModel.isLoading
                    )
                    .frame(maxWidth: .infinity)

                    // Error message
                    if let error = viewModel.error {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(Color(hex: "FB2C36"))

                            Text(error)
                                .font(AppFonts.xsRegular)
                                .foregroundColor(Color(hex: "FB2C36"))

                            Spacer()
                        }
                        .padding(AppSpacing.md)
                        .background(Color(hex: "FB2C36").opacity(0.1))
                        .cornerRadius(AppSpacing.radiusMd)
                    }

                    // Action Links
                    VStack(spacing: AppSpacing.md) {
                        Button(action: {
                            Task {
                                await viewModel.resendOTP()
                            }
                        }) {
                            Text(LocalizationKeys.otpResendCode.localized)
                                .font(AppFonts.xsMedium)
                                .foregroundColor(AppColors.black)
                                .underline()
                        }
                        .disabled(!viewModel.canResend || viewModel.isLoading)
                        .opacity(viewModel.canResend ? 1.0 : 0.5)

                        HStack(spacing: AppSpacing.sm) {
                            Text(LocalizationKeys.otpNoSMS.localized)
                                .font(AppFonts.xsRegular)
                                .foregroundColor(AppColors.neutral700)

                            Button(action: {
                                Task {
                                    await viewModel.sendOTPViaEmail()
                                }
                            }) {
                                Text(LocalizationKeys.otpSendEmail.localized)
                                    .font(AppFonts.xsMedium)
                                    .foregroundColor(AppColors.primary950)
                                    .underline()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(AppSpacing.lg)

                Spacer()
            }
        }
        .onAppear {
            // Focus the hidden autofill field when view appears
            // This allows iOS to detect and suggest the OTP code from SMS
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAutofillFieldFocused = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OTPVerificationView(
        userId: "preview-user-id",
        companyCode: "preview-company",
        showResetPassword: .constant(false)
    )
}
