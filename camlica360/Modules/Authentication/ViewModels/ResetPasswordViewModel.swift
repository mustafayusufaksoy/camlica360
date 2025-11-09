import SwiftUI

/// ViewModel for reset password view
/// Manages password reset business logic and validation
@MainActor
class ResetPasswordViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var otp: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""

    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isSuccess: Bool = false
    @Published var successMessage: String?

    // Field-specific errors
    @Published var otpError: String?
    @Published var newPasswordError: String?
    @Published var confirmPasswordError: String?

    // MARK: - Properties

    private let authService: AuthService
    let companyCode: String
    let idNumber: String

    // MARK: - Initialization

    init(companyCode: String, idNumber: String, authService: AuthService = AuthService.shared) {
        self.companyCode = companyCode
        self.idNumber = idNumber
        self.authService = authService
    }

    // MARK: - Public Methods

    /// Check if form is valid
    func isFormValid() -> Bool {
        !otp.trimmingCharacters(in: .whitespaces).isEmpty &&
            !newPassword.trimmingCharacters(in: .whitespaces).isEmpty &&
            !confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty &&
            otpError == nil &&
            newPasswordError == nil &&
            confirmPasswordError == nil
    }

    /// Validate individual fields
    func validateFields() {
        // Clear previous field errors
        otpError = nil
        newPasswordError = nil
        confirmPasswordError = nil

        // Validate OTP
        if otp.isEmpty {
            otpError = "Doğrulama kodu boş olamaz"
        } else if otp.count != 6 || !otp.allSatisfy({ $0.isNumber }) {
            otpError = "Doğrulama kodu 6 haneli olmalıdır"
        }

        // Validate New Password
        let trimmedNewPassword = newPassword.trimmingCharacters(in: .whitespaces)
        if trimmedNewPassword.isEmpty {
            newPasswordError = LocalizationKeys.loginErrorPassword.localized
        } else if trimmedNewPassword.count < 6 {
            newPasswordError = LocalizationKeys.resetPasswordErrorMinLength.localized
        }

        // Validate Confirm Password
        if confirmPassword.isEmpty {
            confirmPasswordError = LocalizationKeys.loginErrorPassword.localized
        } else if newPassword != confirmPassword {
            confirmPasswordError = LocalizationKeys.resetPasswordErrorMismatch.localized
        }
    }

    /// Reset password
    func resetPassword() async {
        // Validate all fields first
        validateFields()

        // Check if there are any errors
        if otpError != nil || newPasswordError != nil || confirmPasswordError != nil {
            return
        }

        // Clear previous states
        error = nil
        isSuccess = false
        successMessage = nil

        // Set loading state
        isLoading = true

        do {
            // Call backend to confirm password reset
            _ = try await authService.resetPasswordConfirm(
                companyCode: companyCode,
                idNumber: idNumber,
                otp: otp,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )

            // Success
            isSuccess = true
            successMessage = LocalizationKeys.resetPasswordSuccess.localized
            print("✅ Password reset successful")
            resetForm()

        } catch let error as NetworkError {
            self.error = error.localizedDescription
        } catch {
            self.error = "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin."
        }

        // Clear loading state
        isLoading = false
    }

    // MARK: - Private Methods

    /// Reset form fields
    private func resetForm() {
        otp = ""
        newPassword = ""
        confirmPassword = ""
    }
}
