import Foundation

/// User information DTO
struct UserDto: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String?
    let companyCode: String
    let companyId: String?
    let isCompanyRepresentative: Bool
    let firstLoginResetPassword: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case companyCode
        case companyId
        case isCompanyRepresentative
        case firstLoginResetPassword
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
