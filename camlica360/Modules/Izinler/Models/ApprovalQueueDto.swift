import Foundation

/// DTO for approval queue item (from /hr/Permission/approvals/my-queue)
/// Backend returns approval step + request details combined
struct ApprovalQueueRequestDto: Codable, Identifiable {
    // MARK: - Identifiable (using approvalStepId as unique ID)

    var id: String { approvalStepId }

    // MARK: - Approval Step Info

    let approvalStepId: String
    let stepId: String
    let stepOrder: Int
    let stepName: String
    let stepDeadline: String?

    // MARK: - Permission Request Info

    let permissionRequestId: String
    let personnelId: String
    let personnelName: String
    let personnelNumber: String?
    let departmentName: String?
    let permissionTypeId: String
    let permissionTypeName: String
    let startDate: String // ISO8601
    let endDate: String // ISO8601
    let desiredDays: Int
    let description: String?
    let attachmentPath: String?

    // MARK: - Request Status

    let requestStatus: Int // 0=Pending, 1=Approved, 2=Rejected, 3=Cancelled
    let requestCreatedAt: String

    // MARK: - Workflow Info

    let flowName: String?
    let currentStepOrder: Int?
    let totalSteps: Int?

    // MARK: - Approval Action (if taken)

    let approvalStatus: Int? // null if not yet acted upon
    let actionNote: String?
    let actionAt: String?

    enum CodingKeys: String, CodingKey {
        case approvalStepId
        case stepId
        case stepOrder
        case stepName
        case stepDeadline
        case permissionRequestId
        case personnelId
        case personnelName
        case personnelNumber
        case departmentName
        case permissionTypeId
        case permissionTypeName
        case startDate
        case endDate
        case desiredDays
        case description
        case attachmentPath
        case requestStatus
        case requestCreatedAt
        case flowName
        case currentStepOrder
        case totalSteps
        case approvalStatus
        case actionNote
        case actionAt
    }
}

/// DTO for creating approval/rejection (POST /hr/Permission/approvals/approve or reject)
struct CreateApprovalReviewDto: Codable {
    let requestId: String
    let decision: Bool // true = approve, false = reject
    let reason: String? // Optional review note

    enum CodingKeys: String, CodingKey {
        case requestId
        case decision
        case reason
    }
}

/// DTO for approval steps (from /hr/Permission/approvalSteps/getByRequest/{id})
struct ApprovalStepDto: Codable, Identifiable {
    let id: String
    let permissionRequestId: String
    let stepId: String
    let assignedTo: String // Personnel ID of approver
    let status: Int // 0=Waiting, 1=Approved, 2=Rejected, 3=Skipped
    let actionBy: String?
    let actionNote: String?
    let actionAt: String? // ISO8601
    let dueAt: String? // ISO8601
    let createdAt: String
    let createdBy: String
    let updatedAt: String?
    let updatedBy: String?
    let stepName: String
    let assignedToName: String
    let stepOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case permissionRequestId
        case stepId
        case assignedTo
        case status
        case actionBy
        case actionNote
        case actionAt
        case dueAt
        case createdAt
        case createdBy
        case updatedAt
        case updatedBy
        case stepName
        case assignedToName
        case stepOrder
    }
}

/// DTO for approval state (from /hr/Permission/approvalState/getByRequest/{id})
struct ApprovalStateDto: Codable {
    let id: String
    let permissionRequestId: String
    let currentStepId: String?
    let currentStatus: Int // Overall status
    let startedAt: String?
    let completedAt: String?
    let createdAt: String
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case permissionRequestId
        case currentStepId
        case currentStatus
        case startedAt
        case completedAt
        case createdAt
        case updatedAt
    }
}

/// Status enum for approval steps
enum ApprovalStepStatus: Int {
    case waiting = 0
    case approved = 1
    case rejected = 2
    case skipped = 3

    var displayText: String {
        switch self {
        case .waiting: return "Bekliyor"
        case .approved: return "Onaylandı"
        case .rejected: return "Reddedildi"
        case .skipped: return "Atlandı"
        }
    }

    var color: String {
        switch self {
        case .waiting: return "#FFA500" // Orange
        case .approved: return "#4CAF50" // Green
        case .rejected: return "#F44336" // Red
        case .skipped: return "#9E9E9E" // Gray
        }
    }
}
