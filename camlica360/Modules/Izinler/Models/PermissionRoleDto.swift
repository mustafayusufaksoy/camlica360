import Foundation

/// Permission role DTO from backend
struct PermissionRoleDto: Codable {
    let personnelId: String
    let roleType: Int // 0=Employee, 1=Manager, 2=Admin
    let roleText: String
    let canApprove: Bool
    let canConfigure: Bool
    let maxApprovableDays: Int?
    let permissionTypeIds: [String]
    let departmentIds: [String]
    let isFromDatabase: Bool
    let roleSource: String // "JWT", "Database", "Fallback"

    enum CodingKeys: String, CodingKey {
        case personnelId
        case roleType
        case roleText
        case canApprove
        case canConfigure
        case maxApprovableDays
        case permissionTypeIds
        case departmentIds
        case isFromDatabase
        case roleSource
    }
}

/// Permission role type enum
enum PermissionRoleType: Int, Codable {
    case employee = 0
    case manager = 1
    case admin = 2

    var displayText: String {
        switch self {
        case .employee: return "Çalışan"
        case .manager: return "Yönetici"
        case .admin: return "Sistem Yöneticisi"
        }
    }

    var icon: String {
        switch self {
        case .employee: return "person"
        case .manager: return "person.2"
        case .admin: return "crown"
        }
    }

    var color: String {
        switch self {
        case .employee: return "#6B7280" // Gray
        case .manager: return "#3B82F6" // Blue
        case .admin: return "#8B5CF6" // Purple
        }
    }
}

/// Helper extension for role checks
extension PermissionRoleDto {
    var roleTypeEnum: PermissionRoleType? {
        return PermissionRoleType(rawValue: roleType)
    }

    var isEmployee: Bool {
        return roleType == PermissionRoleType.employee.rawValue
    }

    var isManager: Bool {
        return roleType >= PermissionRoleType.manager.rawValue
    }

    var isAdmin: Bool {
        return roleType >= PermissionRoleType.admin.rawValue
    }
}
