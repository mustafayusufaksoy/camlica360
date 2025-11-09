import Foundation

/// Login request DTO
struct LoginRequestDto: Codable {
    let code: String        // Company code
    let tcNo: String        // TC ID number
    let password: String

    enum CodingKeys: String, CodingKey {
        case code
        case tcNo
        case password
    }
}
