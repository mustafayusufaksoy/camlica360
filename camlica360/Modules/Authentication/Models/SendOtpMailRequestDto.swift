import Foundation

/// Send OTP via email request DTO
struct SendOtpMailRequestDto: Codable {
    let companyCode: String
    let userId: String

    enum CodingKeys: String, CodingKey {
        case companyCode
        case userId
    }

    init(companyCode: String, userId: String) {
        self.companyCode = companyCode
        self.userId = userId
    }
}
