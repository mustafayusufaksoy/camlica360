import SwiftUI

/// ViewModel for signup view
/// Manages signup business logic and validation
@MainActor
class SignupViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var email: String = ""
    @Published var fullName: String = ""
    @Published var phone: String = ""
    @Published var companyCode: String = ""
    @Published var agreeToTerms: Bool = false

    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isSignupSuccessful: Bool = false
    @Published var successMessage: String?

    // Field-specific errors
    @Published var emailError: String?
    @Published var fullNameError: String?
    @Published var phoneError: String?

    // MARK: - Properties

    private let authService: AuthService

    // MARK: - Initialization

    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
    }

    // MARK: - Public Methods

    /// Validate signup form
    func isFormValid() -> Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
            !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
            agreeToTerms &&
            emailError == nil &&
            fullNameError == nil &&
            phoneError == nil
    }

    /// Validate individual fields
    func validateFields() {
        // Clear previous field errors
        emailError = nil
        fullNameError = nil
        phoneError = nil

        // Validate Email
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = LocalizationKeys.signupErrorEmail.localized
        } else if !isValidEmail(trimmedEmail) {
            emailError = LocalizationKeys.signupErrorEmailFormat.localized
        }

        // Validate Full Name
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            fullNameError = LocalizationKeys.signupErrorFullName.localized
        } else if trimmedName.count < 2 {
            fullNameError = LocalizationKeys.signupErrorFullNameMinLength.localized
        }

        // Validate Phone (optional, but if provided must be valid)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
        if !trimmedPhone.isEmpty {
            if !isValidPhone(trimmedPhone) {
                phoneError = LocalizationKeys.signupErrorPhoneFormat.localized
            }
        }
    }

    /// Perform signup
    func signup() async {
        // Validate all fields first
        validateFields()

        // Check if there are any errors
        if emailError != nil || fullNameError != nil || phoneError != nil {
            return
        }

        // Check if user agrees to terms
        if !agreeToTerms {
            error = LocalizationKeys.signupErrorTerms.localized
            return
        }

        // Clear general error
        error = nil

        // Set loading state
        isLoading = true

        do {
            // Create signup request with default source = "iOS"
            let request = SignupRequestDto(
                email: email.trimmingCharacters(in: .whitespaces),
                fullName: fullName.trimmingCharacters(in: .whitespaces),
                phone: phone.trimmingCharacters(in: .whitespaces).isEmpty ? nil : phone.trimmingCharacters(in: .whitespaces),
                companyCode: companyCode.trimmingCharacters(in: .whitespaces).isEmpty ? nil : companyCode.trimmingCharacters(in: .whitespaces),
                companyId: nil,
                requestedRoleId: nil,
                source: "iOS",  // Track that registration came from iOS app
                channel: nil
            )

            // Call auth service
            try await authService.signup(request: request)

            // Success
            isSignupSuccessful = true
            successMessage = LocalizationKeys.signupSuccessMessage.localized
            resetForm()

        } catch let error as NetworkError {
            // Translate backend error messages to Turkish
            let errorMessage = error.localizedDescription
            if errorMessage.contains("pending registration request") ||
               errorMessage.contains("already exists") {
                self.error = "Bu e-posta adresi ile zaten bekleyen bir kayıt talebi var."
            } else {
                self.error = errorMessage
            }
        } catch {
            self.error = "Kayıt işlemi başarısız oldu. Lütfen tekrar deneyin."
        }

        // Clear loading state
        isLoading = false
    }

    // MARK: - Private Methods

    /// Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return predicate.evaluate(with: email)
    }

    /// Validate phone format (Turkish phone: 10 digits starting with 5)
    private func isValidPhone(_ phone: String) -> Bool {
        let cleanedPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        // Turkish phone: 10 digits, starts with 5
        return cleanedPhone.count == 10 && cleanedPhone.first == "5"
    }

    /// Reset form fields
    private func resetForm() {
        email = ""
        fullName = ""
        phone = ""
        companyCode = ""
        agreeToTerms = false
    }
}
