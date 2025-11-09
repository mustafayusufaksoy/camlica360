import Foundation

/// OTP verification request DTO
struct VerifyRequestDto: Codable {
    let userId: String
    let code: String      // OTP code sent via SMS (backend expects this as "code")
    let token: String     // Temp token from login response

    enum CodingKeys: String, CodingKey {
        case userId
        case code
        case token
    }

    init(userId: String, otpCode: String, tempToken: String) {
        self.userId = userId
        self.code = otpCode
        self.token = tempToken
    }
}
