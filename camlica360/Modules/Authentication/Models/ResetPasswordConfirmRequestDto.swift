import Foundation

/// Reset password confirmation request DTO
struct ResetPasswordConfirmRequestDto: Codable {
    let code: String            // Company code
    let tcNo: String            // TC ID number
    let otp: String             // OTP code
    let newPassword: String
    let confirmNewPassword: String

    enum CodingKeys: String, CodingKey {
        case code
        case tcNo
        case otp
        case newPassword
        case confirmNewPassword
    }
}
