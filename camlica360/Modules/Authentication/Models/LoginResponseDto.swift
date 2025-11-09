import Foundation

/// Login response DTO
struct LoginResponseDto: Codable {
    let userId: String
    let token: String           // Temp token for 2FA
    let companyCode: String?

    // Backend doesn't return this field, so we assume 2FA is always required
    var twoFactorRequired: Bool {
        return true // Always require 2FA for this backend
    }

    enum CodingKeys: String, CodingKey {
        case userId
        case token
        case companyCode
    }
}
