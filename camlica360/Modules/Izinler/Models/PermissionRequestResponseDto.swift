import Foundation

/// Permission request response DTO from backend (full version)
struct PermissionRequestsDto: Codable {
    let id: String
    let personnelId: String
    let permissionTypeId: String
    let startDate: String
    let endDate: String
    let desiredDays: Int
    let description: String?
    let attachmentPath: String?
    let status: Int // 0=Pending, 1=Approved, 2=Rejected, 3=Cancelled
    let createdAt: String
    let updatedAt: String
    let createdBy: String
    let updatedBy: String
    let permissionTypeName: String
    let personnelName: String?
    let personnelNumber: String?

    // Personnel Details from CRM Service
    let personnelFullName: String?
    let personnelTcNumber: String?
    let personnelBirthDate: String?
    let departmentName: String?
    let positionName: String?
    let dealerName: String?
    let fullPersonnelNumber: String?
    let employmentStartDate: String?

    // Leave Balance
    let remainingLeaveDays: Int?
}

/// Permission request response DTO from backend (simplified version for dashboard)
struct PermissionRequestResponseDto: Codable {
    let id: String
    let personnelId: String?
    let permissionTypeId: String?
    let permissionTypeName: String?
    let startDate: String
    let endDate: String
    let status: Int
    let duration: Double?
    let reason: String?
    let createdAt: String?
    let updatedAt: String?
}

/// Permission request status enum
enum PermissionRequestStatus: Int, Codable {
    case pending = 0
    case approved = 1
    case rejected = 2
    case cancelled = 3

    var title: String {
        switch self {
        case .pending: return "Beklemede"
        case .approved: return "Onaylandı"
        case .rejected: return "Reddedildi"
        case .cancelled: return "İptal Edildi"
        }
    }

    var displayText: String {
        return title
    }

    var color: String {
        switch self {
        case .pending: return "#FFA500"    // Orange
        case .approved: return "#4CAF50"   // Green
        case .rejected: return "#F44336"   // Red
        case .cancelled: return "#9E9E9E"  // Gray
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .approved: return "checkmark.circle"
        case .rejected: return "xmark.circle"
        case .cancelled: return "slash.circle"
        }
    }
}
