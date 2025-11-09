import Foundation

/// DTO for creating a new permission request
struct CreatePermissionRequestDto: Codable {
    let personnelId: String
    let permissionTypeId: String
    let startDate: String // ISO8601 format
    let endDate: String // ISO8601 format
    let desiredDays: Int
    let description: String?
    let attachmentPath: String?
    let status: Int // 0 = Pending (default)

    enum CodingKeys: String, CodingKey {
        case personnelId
        case permissionTypeId
        case startDate
        case endDate
        case desiredDays
        case description
        case attachmentPath
        case status
    }
}

/// Permission type DTO from backend
struct PermissionTypeDto: Codable, Identifiable {
    let id: String
    let name: String
    let code: String?
    let description: String?
    let isActive: Bool?
    let defaultDays: Int?
    let color: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
        case description
        case isActive
        case defaultDays
        case color
    }
}
