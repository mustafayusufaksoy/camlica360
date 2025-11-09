import SwiftUI

/// ViewModel for login view
/// Manages login business logic and state
@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var companyCode: String = ""
    @Published var idNumber: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false

    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isLoginSuccessful: Bool = false

    // Login response data (for navigation to OTP)
    @Published var loginResponse: LoginResponseDto?
    @Published var shouldNavigateToOTP: Bool = false

    // Field-specific errors
    @Published var companyCodeError: String?
    @Published var idNumberError: String?
    @Published var passwordError: String?

    // MARK: - Properties

    private let authService: AuthService
    private let userDefaultsManager = UserDefaultsManager.shared

    // MARK: - Initialization

    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
        loadSavedCredentials()
    }

    // MARK: - Lifecycle

    /// Load saved credentials if remember me is enabled
    func loadSavedCredentials() {
        if userDefaultsManager.getRememberMe() {
            companyCode = userDefaultsManager.getCompanyCode() ?? ""
            idNumber = userDefaultsManager.getIdNumber() ?? ""
            rememberMe = true
        }
    }

    // MARK: - Public Methods

    /// Validate login form
    func isFormValid() -> Bool {
        !companyCode.trimmingCharacters(in: .whitespaces).isEmpty &&
            !idNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
            !password.isEmpty &&
            companyCodeError == nil &&
            idNumberError == nil &&
            passwordError == nil
    }

    /// Validate individual fields
    func validateFields() {
        // Clear previous field errors
        companyCodeError = nil
        idNumberError = nil
        passwordError = nil

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

        // Validate Password
        if password.isEmpty {
            passwordError = LocalizationKeys.loginErrorPassword.localized
        }
    }

    /// Perform login
    func login() async {
        // Validate all fields first
        validateFields()

        // Check if there are any errors
        if companyCodeError != nil || idNumberError != nil || passwordError != nil {
            return
        }

        // Clear general error
        error = nil

        // Set loading state
        isLoading = true

        do {
            // Call auth service
            let response = try await authService.login(
                companyCode: companyCode,
                idNumber: idNumber,
                password: password,
                rememberMe: rememberMe
            )

            // Store response for OTP screen
            loginResponse = response

            // Check if 2FA is required
            if response.twoFactorRequired {
                // Navigate to OTP screen
                shouldNavigateToOTP = true
            } else {
                // Direct login success (no 2FA)
                // Set authentication state
                AuthStateManager.shared.setAuthenticated()
                isLoginSuccessful = true
                resetPasswordField()
            }

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
        if !rememberMe {
            companyCode = ""
            idNumber = ""
        }
        password = ""
    }

    /// Reset only password field
    private func resetPasswordField() {
        password = ""
    }
}
