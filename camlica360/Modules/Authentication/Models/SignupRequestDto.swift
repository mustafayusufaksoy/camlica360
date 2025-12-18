import Foundation

/// Signup request DTO for self-registration
/// Matches backend CreateSelfRegistrationRequestDto
struct SignupRequestDto: Codable {
    let email: String
    let fullName: String?
    let phone: String?
    let companyCode: String?
    let companyId: String?          // Optional: If user knows company ID
    let requestedRoleId: String?    // Optional: Requested role
    let source: String?             // Optional: Registration source (e.g., "iOS", "Web")
    let channel: String?            // Optional: Marketing channel

    init(
        email: String,
        fullName: String? = nil,
        phone: String? = nil,
        companyCode: String? = nil,
        companyId: String? = nil,
        requestedRoleId: String? = nil,
        source: String? = "iOS",  // Default to iOS
        channel: String? = nil
    ) {
        self.email = email
        self.fullName = fullName
        self.phone = phone
        self.companyCode = companyCode
        self.companyId = companyId
        self.requestedRoleId = requestedRoleId
        self.source = source
        self.channel = channel
    }

    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "fullName"
        case phone
        case companyCode = "companyCode"
        case companyId = "companyId"
        case requestedRoleId = "requestedRoleId"
        case source
        case channel
    }
}
