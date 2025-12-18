import Foundation

/// Login response DTO
struct LoginResponseDto: Codable {
    let userId: String
    let token: String           // Temp token for 2FA or access token (if 2FA disabled)
    let companyCode: String?
    let requiresTwoFactor: Bool // Backend determines if 2FA is required

    // Computed property for backwards compatibility
    var twoFactorRequired: Bool {
        return requiresTwoFactor
    }

    enum CodingKeys: String, CodingKey {
        case userId
        case token
        case companyCode
        case requiresTwoFactor
    }
}
