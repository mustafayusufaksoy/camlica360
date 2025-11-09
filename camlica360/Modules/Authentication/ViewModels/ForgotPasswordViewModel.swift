import SwiftUI

/// ViewModel for forgot password view
/// Manages password reset business logic and state
@MainActor
class ForgotPasswordViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var companyCode: String = ""
    @Published var idNumber: String = ""

    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isSuccess: Bool = false
    @Published var successMessage: String?
    @Published var showOTPVerification: Bool = false

    // Field-specific errors
    @Published var companyCodeError: String?
    @Published var idNumberError: String?

    // MARK: - Properties

    private let authService: AuthService

    // MARK: - Initialization

    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
    }

    // MARK: - Public Methods

    /// Validate form
    func isFormValid() -> Bool {
        !companyCode.trimmingCharacters(in: .whitespaces).isEmpty &&
            !idNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
            companyCodeError == nil &&
            idNumberError == nil
    }

    /// Validate individual fields
    func validateFields() {
        // Clear previous field errors
        companyCodeError = nil
        idNumberError = nil

        // Validate Company Code
        let trimmedCode = companyCode.trimmingCharacters(in: .whitespaces)
        if trimmedCode.isEmpty {
            companyCodeError = LocalizationKeys.loginErrorCompanyCode.localized
        }

        // Validate ID Number
        if idNumber.isEmpty {
            idNumberError = LocalizationKeys.loginErrorIdNumber.localized
        } else if idNumber.count != 11 || !idNumber.allSatisfy({ $0.isNumber }) {
            idNumberError = LocalizationKeys.loginErrorIdNumber.localized
        }
    }

    /// Send password reset code
    func sendResetCode() async {
        // Validate all fields first
        validateFields()

        // Check if there are any errors
        if companyCodeError != nil || idNumberError != nil {
            return
        }

        // Clear previous states
        error = nil
        isSuccess = false
        successMessage = nil

        // Set loading state
        isLoading = true

        do {
            // Call auth service to request password reset
            _ = try await authService.requestPasswordReset(
                companyCode: companyCode,
                idNumber: idNumber
            )

            // Show reset password screen
            showOTPVerification = true

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
        companyCode = ""
        idNumber = ""
    }
}
