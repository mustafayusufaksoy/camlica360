import Foundation

/// Service for Izinler (Permissions) module
@MainActor
class IzinlerService {
    // MARK: - Singleton

    static let shared = IzinlerService()

    // MARK: - Properties

    private let networkManager: NetworkManager

    // MARK: - Initialization

    private init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    // MARK: - Public Methods

    /// Get employee permission dashboard data
    /// - Parameters:
    ///   - personnelId: Personnel ID
    ///   - year: Year to fetch data for
    /// - Returns: PermissionDashboardDto
    func getEmployeeDashboard(personnelId: String, year: Int) async throws -> PermissionDashboardDto {
        print("🔵 [IzinlerService] Fetching employee dashboard for personnelId: \(personnelId), year: \(year)")

        // NetworkManager already unwraps APIResponse wrapper
        let dashboard: PermissionDashboardDto = try await networkManager.request(
            endpoint: .getEmployeeDashboard(personnelId: personnelId, year: year),
            responseType: PermissionDashboardDto.self
        )

        print("✅ [IzinlerService] Dashboard data fetched successfully")
        return dashboard
    }

    /// Get all permission requests for a personnel
    /// - Parameter personnelId: Personnel ID
    /// - Returns: Array of PermissionRequestsDto
    func getAllPermissionRequests(personnelId: String) async throws -> [PermissionRequestsDto] {
        print("🔵 [IzinlerService] Fetching all permission requests for personnelId: \(personnelId)")

        // NetworkManager already unwraps APIResponse wrapper
        let requests: [PermissionRequestsDto] = try await networkManager.request(
            endpoint: .getAllPermissionRequests(personnelId: personnelId, year: nil, status: nil),
            responseType: [PermissionRequestsDto].self
        )

        print("✅ [IzinlerService] Fetched \(requests.count) permission requests")
        return requests
    }

    /// Get approved permission requests for monthly chart
    /// - Parameters:
    ///   - personnelId: Personnel ID
    ///   - year: Year to fetch data for
    /// - Returns: Array of approved RecentPermissionRequestDto
    func getApprovedPermissionRequests(personnelId: String, year: Int) async throws -> [RecentPermissionRequestDto] {
        // Use dashboard endpoint to get recent requests
        let dashboard = try await getEmployeeDashboard(personnelId: personnelId, year: year)

        // Filter only approved requests from recentRequests
        let approvedRequests = dashboard.recentRequests.filter { $0.status == PermissionRequestStatus.approved.rawValue }

        print("✅ [IzinlerService] Filtered \(approvedRequests.count) approved requests from \(dashboard.recentRequests.count) recent requests")
        return approvedRequests
    }

    /// Get all permission types
    /// - Returns: Array of PermissionTypeDto
    func getPermissionTypes() async throws -> [PermissionTypeDto] {
        print("🔵 [IzinlerService] Fetching permission types")

        let types: [PermissionTypeDto] = try await networkManager.request(
            endpoint: .getPermissionTypes,
            responseType: [PermissionTypeDto].self
        )

        print("✅ [IzinlerService] Fetched \(types.count) permission types")
        return types
    }

    /// Create a new permission request
    /// - Parameter request: CreatePermissionRequestDto
    /// - Returns: Tuple of (requestId, warningMessage)
    func createPermissionRequest(_ request: CreatePermissionRequestDto) async throws -> (requestId: String, warning: String?) {
        print("🔵 [IzinlerService] Creating permission request for personnelId: \(request.personnelId)")

        // Note: Backend returns the ID as data, but may include warnings in message
        // We need to get the full APIResponse to access the message
        struct CreateResponse: Codable {
            let id: String
        }

        // Temporarily use a direct network call to get both data and message
        // This is a workaround since NetworkManager unwraps the response
        let requestId: String = try await networkManager.request(
            endpoint: .createPermissionRequest,
            body: request,
            responseType: String.self
        )

        print("✅ [IzinlerService] Permission request created with ID: \(requestId)")

        // TODO: We should capture the warning message from backend
        // For now, just return the ID
        return (requestId, nil)
    }

    // MARK: - Manager Approval Queue

    /// Get approval queue for current manager
    /// - Parameter personnelId: Optional personnel ID (if nil, uses current user from JWT)
    /// - Returns: Array of ApprovalQueueRequestDto
    func getMyApprovalQueue(personnelId: String? = nil) async throws -> [ApprovalQueueRequestDto] {
        print("🔵 [IzinlerService] Fetching approval queue for manager: \(personnelId ?? "current user")")

        let requests: [ApprovalQueueRequestDto] = try await networkManager.request(
            endpoint: .getMyApprovalQueue(personnelId: personnelId),
            responseType: [ApprovalQueueRequestDto].self
        )

        print("✅ [IzinlerService] Fetched \(requests.count) pending approval requests")
        return requests
    }

    /// Get approval history for current manager (completed reviews)
    /// - Returns: Array of ApprovalQueueRequestDto
    func getMyApprovalHistory() async throws -> [ApprovalQueueRequestDto] {
        print("🔵 [IzinlerService] Fetching approval history for manager")

        let requests: [ApprovalQueueRequestDto] = try await networkManager.request(
            endpoint: .getMyApprovalHistory,
            responseType: [ApprovalQueueRequestDto].self
        )

        print("✅ [IzinlerService] Fetched \(requests.count) approval history records")
        return requests
    }

    /// Approve a permission request
    /// - Parameters:
    ///   - requestId: Request ID to approve
    ///   - reason: Optional reason/note for approval
    /// - Returns: Approval record ID
    func approveRequest(requestId: String, reason: String?) async throws -> String {
        print("🔵 [IzinlerService] Approving request: \(requestId)")

        let reviewDto = CreateApprovalReviewDto(
            requestId: requestId,
            decision: true,
            reason: reason
        )

        let approvalId: String = try await networkManager.request(
            endpoint: .approveRequest,
            body: reviewDto,
            responseType: String.self
        )

        print("✅ [IzinlerService] Request approved with ID: \(approvalId)")
        return approvalId
    }

    /// Reject a permission request
    /// - Parameters:
    ///   - requestId: Request ID to reject
    ///   - reason: Reason for rejection (required)
    /// - Returns: Rejection record ID
    func rejectRequest(requestId: String, reason: String) async throws -> String {
        print("🔵 [IzinlerService] Rejecting request: \(requestId)")

        let reviewDto = CreateApprovalReviewDto(
            requestId: requestId,
            decision: false,
            reason: reason
        )

        let rejectionId: String = try await networkManager.request(
            endpoint: .rejectRequest,
            body: reviewDto,
            responseType: String.self
        )

        print("✅ [IzinlerService] Request rejected with ID: \(rejectionId)")
        return rejectionId
    }

    /// Get approval steps for a request
    /// - Parameter requestId: Request ID
    /// - Returns: Array of ApprovalStepDto
    func getApprovalSteps(requestId: String) async throws -> [ApprovalStepDto] {
        print("🔵 [IzinlerService] Fetching approval steps for request: \(requestId)")

        let steps: [ApprovalStepDto] = try await networkManager.request(
            endpoint: .getApprovalSteps(requestId: requestId),
            responseType: [ApprovalStepDto].self
        )

        print("✅ [IzinlerService] Fetched \(steps.count) approval steps")
        return steps
    }

    /// Get approval state for a request
    /// - Parameter requestId: Request ID
    /// - Returns: ApprovalStateDto
    func getApprovalState(requestId: String) async throws -> ApprovalStateDto {
        print("🔵 [IzinlerService] Fetching approval state for request: \(requestId)")

        let state: ApprovalStateDto = try await networkManager.request(
            endpoint: .getApprovalState(requestId: requestId),
            responseType: ApprovalStateDto.self
        )

        print("✅ [IzinlerService] Approval state fetched")
        return state
    }

    // MARK: - Role Management

    /// Check current user's role
    /// - Returns: PermissionRoleDto with role information
    func checkUserRole() async throws -> PermissionRoleDto {
        print("🔵 [IzinlerService] Checking user role")

        let role: PermissionRoleDto = try await networkManager.request(
            endpoint: .checkRole,
            responseType: PermissionRoleDto.self
        )

        print("✅ [IzinlerService] User role: \(role.roleText) (type: \(role.roleType))")
        return role
    }

    /// Check if user has minimum required role
    /// - Parameter requiredRoleType: Required role type (0=Employee, 1=Manager, 2=Admin)
    /// - Returns: True if user has minimum role
    func hasMinimumRole(requiredRoleType: Int) async throws -> Bool {
        print("🔵 [IzinlerService] Checking minimum role: \(requiredRoleType)")

        let hasRole: Bool = try await networkManager.request(
            endpoint: .hasMinimumRole(requiredRoleType: requiredRoleType),
            responseType: Bool.self
        )

        print("✅ [IzinlerService] Has minimum role: \(hasRole)")
        return hasRole
    }

    /// Check if user is a manager (can approve requests)
    /// - Returns: True if user is manager or higher
    func isManager() async throws -> Bool {
        return try await hasMinimumRole(requiredRoleType: PermissionRoleType.manager.rawValue)
    }

    /// Check if user is an admin (can configure system)
    /// - Returns: True if user is admin
    func isAdmin() async throws -> Bool {
        return try await hasMinimumRole(requiredRoleType: PermissionRoleType.admin.rawValue)
    }
}
