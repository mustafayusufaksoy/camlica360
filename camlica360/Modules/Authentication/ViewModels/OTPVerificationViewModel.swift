import SwiftUI

/// ViewModel for OTP verification
@MainActor
class OTPVerificationViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var otpDigits: [String] = Array(repeating: "", count: 6)
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var timeRemaining: Int = 180 // 3 minutes
    @Published var canResend: Bool = false
    @Published var isVerified: Bool = false

    // MARK: - Properties

    private let authService: AuthService
    private var timer: Timer?

    // User data from login response
    let userId: String
    let companyCode: String

    // MARK: - Initialization

    init(userId: String, companyCode: String, authService: AuthService = AuthService.shared) {
        self.userId = userId
        self.companyCode = companyCode
        self.authService = authService
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Public Methods

    /// Get complete OTP code
    var otpCode: String {
        otpDigits.joined()
    }

    /// Check if OTP is complete
    var isOTPComplete: Bool {
        otpDigits.allSatisfy { !$0.isEmpty }
    }

    /// Verify OTP code
    func verifyOTP() async {
        guard isOTPComplete else {
            error = "Lütfen 6 haneli kodu tamamen giriniz"
            return
        }

        error = nil
        isLoading = true

        do {
            // Call backend to verify OTP
            let response = try await authService.verifyOTP(userId: userId, code: otpCode)

            // OTP verified successfully
            print("✅ OTP verified successfully")
            print("✅ Access token received")

            // Set authentication state
            AuthStateManager.shared.setAuthenticated()

            // Set verified flag for navigation
            isVerified = true

        } catch let error as NetworkError {
            // Network error - show localized message and clear OTP
            self.error = error.localizedDescription
            resetOTP()
        } catch {
            // Unknown error - show generic message and clear OTP
            self.error = "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin."
            resetOTP()
        }

        isLoading = false
    }

    /// Resend OTP code
    func resendOTP() async {
        isLoading = true
        error = nil

        do {
            // Request new OTP via email from backend
            _ = try await authService.sendOTPViaEmail(companyCode: companyCode, userId: userId)

            // Reset timer and OTP inputs
            resetTimer()
            resetOTP()
            print("✅ OTP resent successfully via email")

        } catch let error as NetworkError {
            self.error = error.localizedDescription
        } catch {
            self.error = "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin."
        }

        isLoading = false
    }

    /// Send OTP via email
    func sendOTPViaEmail() async {
        isLoading = true
        error = nil

        do {
            // Request OTP to be sent via email from backend
            _ = try await authService.sendOTPViaEmail(companyCode: companyCode, userId: userId)

            print("✅ OTP sent via email successfully")

        } catch let error as NetworkError {
            self.error = error.localizedDescription
        } catch {
            self.error = "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin."
        }

        isLoading = false
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer?.invalidate()
        timeRemaining = 180
        canResend = false

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timeRemaining -= 1
            if self?.timeRemaining ?? 0 <= 0 {
                self?.timer?.invalidate()
                self?.canResend = true
            }
        }
    }

    private func resetTimer() {
        startTimer()
    }

    private func resetOTP() {
        otpDigits = Array(repeating: "", count: 6)
    }

    /// Format time remaining
    func formattedTimeRemaining() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
