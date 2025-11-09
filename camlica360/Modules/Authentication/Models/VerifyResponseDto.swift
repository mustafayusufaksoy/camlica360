import Foundation

/// OTP verification response DTO
struct VerifyResponseDto: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken
    }
}
