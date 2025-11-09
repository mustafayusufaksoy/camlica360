import Foundation

/// User information extracted from JWT token
struct UserInfo: Codable {
    let userId: String
    let fullName: String?
    let email: String?
    let companyCode: String?
    let companyId: String?
    let avatarUrl: String?
    let logoUrl: String?
    let isCompanyRepresentative: Bool

    enum CodingKeys: String, CodingKey {
        case userId
        case fullName
        case email
        case companyCode
        case companyId
        case avatarUrl
        case logoUrl
        case isCompanyRepresentative
    }

    init(
        userId: String,
        fullName: String? = nil,
        email: String? = nil,
        companyCode: String? = nil,
        companyId: String? = nil,
        avatarUrl: String? = nil,
        logoUrl: String? = nil,
        isCompanyRepresentative: Bool = false
    ) {
        self.userId = userId
        self.fullName = fullName
        self.email = email
        self.companyCode = companyCode
        self.companyId = companyId
        self.avatarUrl = avatarUrl
        self.logoUrl = logoUrl
        self.isCompanyRepresentative = isCompanyRepresentative
    }

    /// Extract user info from JWT token
    /// - Parameter token: JWT access token
    /// - Returns: UserInfo or nil if parsing fails
    static func from(token: String) -> UserInfo? {
        let jwtHelper = JWTHelper.shared

        guard let userId = jwtHelper.getUserId(from: token) else {
            print("❌ [UserInfo] Could not extract userId from token")
            return nil
        }

        let fullName = jwtHelper.getFullName(from: token)
        let companyCode = jwtHelper.getCompanyCode(from: token)
        let avatarUrl = jwtHelper.getAvatarUrl(from: token)
        let logoUrl = jwtHelper.getLogoUrl(from: token)
        let isCompanyRep = jwtHelper.isCompanyRepresentative(from: token)

        return UserInfo(
            userId: userId,
            fullName: fullName,
            companyCode: companyCode,
            avatarUrl: avatarUrl,
            logoUrl: logoUrl,
            isCompanyRepresentative: isCompanyRep
        )
    }

    /// Get display name for the user
    var displayName: String {
        return fullName ?? "Kullanıcı"
    }

    /// Get initials for avatar placeholder
    var initials: String {
        guard let fullName = fullName else {
            return "?"
        }

        let components = fullName.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}
