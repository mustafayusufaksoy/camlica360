import Foundation

/// API Endpoints
enum Endpoint {
    // Authentication
    case login
    case verify
    case sendOtpMail
    case resetPassword
    case resetPasswordConfirm
    case changePassword
    case signup

    // Personnel
    case getPersonnelById(String)

    // Permissions
    case getEmployeeDashboard(personnelId: String, year: Int)
    case getAllPermissionRequests(personnelId: String?, year: Int?, status: Int?)
    case createPermissionRequest
    case getPermissionTypes

    // Approval Queue (Manager)
    case getMyApprovalQueue(personnelId: String?)
    case getMyApprovalHistory
    case approveRequest
    case rejectRequest
    case getApprovalSteps(requestId: String)
    case getApprovalState(requestId: String)

    // Role Management
    case checkRole
    case hasMinimumRole(requiredRoleType: Int)

    var path: String {
        switch self {
        case .login:
            return "/Auth/login"
        case .verify:
            return "/Auth/verify"
        case .sendOtpMail:
            return "/Auth/sendOtpMail"
        case .resetPassword:
            return "/Auth/resetPassword"
        case .resetPasswordConfirm:
            return "/Auth/resetPasswordConfirm"
        case .changePassword:
            return "/Auth/changePassword"
        case .signup:
            return "/SelfRegistrationRequest/createSelfRegistrationRequest"
        case .getPersonnelById(let id):
            return "/CrmPersonnel/getCrmPersonnelById?id=\(id)"
        case .getEmployeeDashboard(let personnelId, let year):
            return "/hr/Permission/dashboard/employee/\(personnelId)?year=\(year)"
        case .getAllPermissionRequests(let personnelId, let year, let status):
            // Backend only supports crmPersonnelId parameter (no year/status)
            var path = "/hr/Permission/requests/getAll"

            if let personnelId = personnelId {
                path += "?crmPersonnelId=\(personnelId)"
            }
            // Note: year and status parameters are not supported by backend
            // Use dashboard endpoint instead for filtered queries

            return path
        case .createPermissionRequest:
            return "/hr/Permission/requests/create"
        case .getPermissionTypes:
            return "/hr/Permission/types/getAll"
        case .getMyApprovalQueue(let personnelId):
            var path = "/hr/Permission/approvals/my-queue"
            if let personnelId = personnelId {
                path += "?personnelId=\(personnelId)"
            }
            return path
        case .getMyApprovalHistory:
            return "/hr/Permission/approvals/my-history"
        case .approveRequest:
            return "/hr/Permission/approvals/approve"
        case .rejectRequest:
            return "/hr/Permission/approvals/reject"
        case .getApprovalSteps(let requestId):
            return "/hr/Permission/approvalSteps/getByRequest/\(requestId)"
        case .getApprovalState(let requestId):
            return "/hr/Permission/approvalState/getByRequest/\(requestId)"
        case .checkRole:
            return "/hr/Permission/check-role"
        case .hasMinimumRole(let requiredRoleType):
            return "/hr/Permission/check-role/has-minimum/\(requiredRoleType)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .verify, .sendOtpMail, .resetPassword, .resetPasswordConfirm, .changePassword, .signup, .createPermissionRequest,
             .approveRequest, .rejectRequest:
            return .post
        case .getPersonnelById, .getEmployeeDashboard, .getAllPermissionRequests, .getPermissionTypes,
             .getMyApprovalQueue, .getMyApprovalHistory, .getApprovalSteps, .getApprovalState,
             .checkRole, .hasMinimumRole:
            return .get
        }
    }
}

/// HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
