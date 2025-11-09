import Foundation

/// Reset password request DTO
struct ResetPasswordRequestDto: Codable {
    let code: String    // Company code
    let tcNo: String    // TC ID number

    enum CodingKeys: String, CodingKey {
        case code
        case tcNo
    }
}
