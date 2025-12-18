import Foundation

/// Authentication service for handling login, logout and auth state
class AuthService {
    // MARK: - Singleton

    static let shared = AuthService()

    // MARK: - Properties

    private let networkManager = NetworkManager.shared
    private let keychainManager = KeychainManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods

    /// Register user with email, name and optional phone/company code
    /// - Parameters:
    ///   - request: SignupRequestDto containing registration data
    /// - Returns: Success response
    func signup(request: SignupRequestDto) async throws {
        // Make API call
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await networkManager.request(
            endpoint: .signup,
            body: request,
            responseType: EmptyResponse.self
        )

        print("✅ [AuthService] Signup request successful for email: \(request.email)")
    }

    /// Perform login with company code, ID and password
    /// - Parameters:
    ///   - companyCode: Company code
    ///   - idNumber: TC ID number
    ///   - password: User password
    ///   - rememberMe: Whether to remember the user
    /// - Returns: LoginResponseDto containing userId and tempToken
    func login(
        companyCode: String,
        idNumber: String,
        password: String,
        rememberMe: Bool
    ) async throws -> LoginResponseDto {
        // Create request DTO
        let request = LoginRequestDto(
            code: companyCode,
            tcNo: idNumber,
            password: password
        )

        // Make API call
        let response: LoginResponseDto = try await networkManager.request(
            endpoint: .login,
            body: request,
            responseType: LoginResponseDto.self
        )

        // Check if 2FA is required
        if response.requiresTwoFactor {
            // 2FA enabled - save temp token for OTP verification
            _ = keychainManager.saveTempToken(response.token)
            _ = keychainManager.saveUserId(response.userId)
            print("🔐 [AuthService] 2FA required - temp token saved")
        } else {
            // 2FA disabled - token is the final access token
            _ = keychainManager.saveAccessToken(response.token)
            _ = keychainManager.saveUserId(response.userId)
            networkManager.setAccessToken(response.token)
            print("✅ [AuthService] 2FA disabled - access token saved directly")
        }

        // Save company code
        if let companyCode = response.companyCode {
            _ = keychainManager.saveCompanyCode(companyCode)
            // Set company code in network manager for subsequent requests
            networkManager.setCompanyCode(companyCode)
        }

        // Extract user info from token (has fullName)
        if let userInfo = UserInfo.from(token: response.token) {
            userDefaultsManager.saveUserInfo(userInfo)
            print("✅ [AuthService] User info extracted from token: \(userInfo.displayName)")
        }

        // Save credentials if remember me is enabled
        if rememberMe {
            userDefaultsManager.saveRememberMe(true)
            userDefaultsManager.saveCompanyCode(companyCode)
            userDefaultsManager.saveIdNumber(idNumber)
        } else {
            userDefaultsManager.clearCredentials()
        }

        return response
    }

    /// Verify OTP code
    /// - Parameters:
    ///   - userId: User ID from login response
    ///   - code: 6-digit OTP code
    /// - Returns: VerifyResponseDto containing accessToken and user info
    func verifyOTP(userId: String, code: String) async throws -> VerifyResponseDto {
        // Get temp token from keychain
        guard let tempToken = keychainManager.getTempToken() else {
            throw NetworkError.unauthorized
        }

        // Create request DTO
        let request = VerifyRequestDto(
            userId: userId,
            otpCode: code,
            tempToken: tempToken
        )

        // Make API call
        let response: VerifyResponseDto = try await networkManager.request(
            endpoint: .verify,
            body: request,
            responseType: VerifyResponseDto.self
        )

        // Save access token
        _ = keychainManager.saveAccessToken(response.accessToken)

        // Set token in network manager for authenticated requests
        networkManager.setAccessToken(response.accessToken)

        // Note: User info was already extracted from temp token during login
        // Access token doesn't contain fullName, so we don't override it here

        // Clear temp token
        _ = keychainManager.deleteTempToken()

        return response
    }

    /// Send OTP via email
    /// - Parameters:
    ///   - companyCode: Company code
    ///   - userId: User ID
    /// - Returns: Success boolean
    func sendOTPViaEmail(companyCode: String, userId: String) async throws -> Bool {
        // Create request DTO
        let request = SendOtpMailRequestDto(
            companyCode: companyCode,
            userId: userId
        )

        // Make API call - uses empty response type since endpoint returns no data
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await networkManager.request(
            endpoint: .sendOtpMail,
            body: request,
            responseType: EmptyResponse.self
        )

        return true
    }

    /// Request password reset code
    /// - Parameters:
    ///   - companyCode: Company code
    ///   - idNumber: TC ID number
    /// - Returns: Success boolean
    func requestPasswordReset(
        companyCode: String,
        idNumber: String
    ) async throws -> Bool {
        // Create request DTO
        let request = ResetPasswordRequestDto(
            code: companyCode,
            tcNo: idNumber
        )

        // Make API call
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await networkManager.request(
            endpoint: .resetPassword,
            body: request,
            responseType: EmptyResponse.self
        )

        return true
    }

    /// Confirm password reset with OTP and new password
    /// - Parameters:
    ///   - companyCode: Company code
    ///   - idNumber: TC ID number
    ///   - otp: OTP code
    ///   - newPassword: New password
    ///   - confirmPassword: Confirm new password
    /// - Returns: Success boolean
    func resetPasswordConfirm(
        companyCode: String,
        idNumber: String,
        otp: String,
        newPassword: String,
        confirmPassword: String
    ) async throws -> Bool {
        // Create request DTO
        let request = ResetPasswordConfirmRequestDto(
            code: companyCode,
            tcNo: idNumber,
            otp: otp,
            newPassword: newPassword,
            confirmNewPassword: confirmPassword
        )

        // Make API call
        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await networkManager.request(
            endpoint: .resetPasswordConfirm,
            body: request,
            responseType: EmptyResponse.self
        )

        return true
    }

    /// Logout user
    func logout() throws {
        // Clear all tokens
        _ = keychainManager.clearAll()

        // Clear user defaults if remember me is not enabled
        if !userDefaultsManager.getRememberMe() {
            userDefaultsManager.clearAll()
        }

        // Clear network manager token and company code
        networkManager.setAccessToken(nil)
        networkManager.setCompanyCode(nil)

        print("✅ User logged out successfully")
    }

    /// Check if user is authenticated
    /// - Returns: Boolean indicating if user is authenticated
    func isAuthenticated() -> Bool {
        // Check if access token exists in keychain
        return keychainManager.getAccessToken() != nil
    }

    /// Restore session (load token from keychain)
    func restoreSession() -> Bool {
        guard let token = keychainManager.getAccessToken() else {
            return false
        }

        // Set token in network manager
        networkManager.setAccessToken(token)

        // Restore company code if available
        if let companyCode = keychainManager.getCompanyCode() {
            networkManager.setCompanyCode(companyCode)
        }

        return true
    }
}
