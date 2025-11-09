import Foundation
import SwiftUI

/// ViewModel for manager approval queue
@MainActor
class ManagerApprovalQueueViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var approvalQueue: [ApprovalQueueRequestDto] = []
    @Published var approvalHistory: [ApprovalQueueRequestDto] = []
    @Published var selectedRequest: ApprovalQueueRequestDto?
    @Published var approvalSteps: [ApprovalStepDto] = []

    @Published var isLoading: Bool = false
    @Published var isLoadingHistory: Bool = false
    @Published var isLoadingSteps: Bool = false
    @Published var isApproving: Bool = false
    @Published var isRejecting: Bool = false

    @Published var errorMessage: String?
    @Published var showApprovalSuccessAlert: Bool = false
    @Published var showRejectionSuccessAlert: Bool = false
    @Published var expandedCardId: String? = nil // Track which card is expanded
    @Published var selectedTab: Int = 0 // 0 = Queue, 1 = History

    // MARK: - Dependencies

    private let izinlerService: IzinlerService
    private let keychainManager: KeychainManager

    // MARK: - Initialization

    init(
        izinlerService: IzinlerService = .shared,
        keychainManager: KeychainManager = .shared
    ) {
        self.izinlerService = izinlerService
        self.keychainManager = keychainManager

        // Load approval queue on init
        Task {
            await loadApprovalQueue()
        }
    }

    // MARK: - Computed Properties

    /// Only pending approval requests (status = 0)
    var pendingRequests: [ApprovalQueueRequestDto] {
        approvalQueue
            .filter { $0.requestStatus == 0 }
            .sorted { $0.requestCreatedAt > $1.requestCreatedAt }
    }

    var pendingCount: Int {
        pendingRequests.count
    }

    var approvedCount: Int {
        approvalQueue.filter { $0.requestStatus == 1 }.count
    }

    var rejectedCount: Int {
        approvalQueue.filter { $0.requestStatus == 2 }.count
    }

    /// Sorted approval history with pending first, then others
    var sortedApprovalHistory: [ApprovalQueueRequestDto] {
        approvalHistory.sorted { (first: ApprovalQueueRequestDto, second: ApprovalQueueRequestDto) -> Bool in
            // Pending (0) comes first, then approved (1), then rejected (2)
            if first.requestStatus == second.requestStatus {
                // If same status, sort by date (newest first)
                return first.requestCreatedAt > second.requestCreatedAt
            }
            return first.requestStatus < second.requestStatus
        }
    }

    // MARK: - Methods

    /// Load approval queue for current manager
    func loadApprovalQueue() async {
        isLoading = true
        errorMessage = nil

        // Get current user ID from keychain
        guard let userId = keychainManager.getUserId() else {
            errorMessage = "Kullanıcı bilgisi bulunamadı"
            isLoading = false
            return
        }

        do {
            print("🔵 [ManagerApprovalQueueViewModel] Loading approval queue for user: \(userId)")

            approvalQueue = try await izinlerService.getMyApprovalQueue(personnelId: userId)

            print("✅ [ManagerApprovalQueueViewModel] Loaded \(approvalQueue.count) requests")

        } catch let networkError as NetworkError {
            errorMessage = "Onay kuyruğu yüklenirken hata oluştu: \(networkError.localizedDescription)"
            print("❌ [ManagerApprovalQueueViewModel] Failed to load queue: \(networkError)")
        } catch {
            errorMessage = "Onay kuyruğu yüklenirken bir hata oluştu. Lütfen tekrar deneyin."
            print("❌ [ManagerApprovalQueueViewModel] Failed to load queue: \(error)")
        }

        isLoading = false
    }

    /// Load approval history for current manager
    func loadApprovalHistory() async {
        isLoadingHistory = true
        errorMessage = nil

        do {
            print("🔵 [ManagerApprovalQueueViewModel] Loading approval history")

            approvalHistory = try await izinlerService.getMyApprovalHistory()

            print("✅ [ManagerApprovalQueueViewModel] Loaded \(approvalHistory.count) history records")

        } catch let networkError as NetworkError {
            errorMessage = "Geçmiş yüklenirken hata oluştu: \(networkError.localizedDescription)"
            print("❌ [ManagerApprovalQueueViewModel] Failed to load history: \(networkError)")
        } catch {
            errorMessage = "Geçmiş yüklenirken bir hata oluştu. Lütfen tekrar deneyin."
            print("❌ [ManagerApprovalQueueViewModel] Failed to load history: \(error)")
        }

        isLoadingHistory = false
    }

    /// Load approval steps for a specific request
    /// - Parameter requestId: Request ID
    func loadApprovalSteps(for requestId: String) async {
        isLoadingSteps = true

        do {
            print("🔵 [ManagerApprovalQueueViewModel] Loading approval steps for request: \(requestId)")

            approvalSteps = try await izinlerService.getApprovalSteps(requestId: requestId)

            // Sort by step order
            approvalSteps.sort { ($0.stepOrder ?? 0) < ($1.stepOrder ?? 0) }

            print("✅ [ManagerApprovalQueueViewModel] Loaded \(approvalSteps.count) approval steps")

        } catch {
            print("❌ [ManagerApprovalQueueViewModel] Failed to load approval steps: \(error)")
            // Don't set error message here as it's optional detail
        }

        isLoadingSteps = false
    }

    /// Approve a permission request
    /// - Parameters:
    ///   - requestId: Request ID to approve
    ///   - reason: Optional approval note
    func approveRequest(requestId: String, reason: String?) async {
        isApproving = true
        errorMessage = nil

        do {
            print("🔵 [ManagerApprovalQueueViewModel] Approving request: \(requestId)")

            _ = try await izinlerService.approveRequest(requestId: requestId, reason: reason)

            print("✅ [ManagerApprovalQueueViewModel] Request approved successfully")

            // Show success alert
            showApprovalSuccessAlert = true

            // Reload approval queue
            await loadApprovalQueue()

        } catch let networkError as NetworkError {
            errorMessage = "İzin talebi onaylanırken hata oluştu: \(networkError.localizedDescription)"
            print("❌ [ManagerApprovalQueueViewModel] Failed to approve: \(networkError)")
        } catch {
            errorMessage = "İzin talebi onaylanırken bir hata oluştu. Lütfen tekrar deneyin."
            print("❌ [ManagerApprovalQueueViewModel] Failed to approve: \(error)")
        }

        isApproving = false
    }

    /// Reject a permission request
    /// - Parameters:
    ///   - requestId: Request ID to reject
    ///   - reason: Rejection reason (required)
    func rejectRequest(requestId: String, reason: String) async {
        guard !reason.isEmpty else {
            errorMessage = "Red nedeni girmeniz gerekiyor"
            return
        }

        isRejecting = true
        errorMessage = nil

        do {
            print("🔵 [ManagerApprovalQueueViewModel] Rejecting request: \(requestId)")

            _ = try await izinlerService.rejectRequest(requestId: requestId, reason: reason)

            print("✅ [ManagerApprovalQueueViewModel] Request rejected successfully")

            // Show success alert
            showRejectionSuccessAlert = true

            // Reload approval queue
            await loadApprovalQueue()

        } catch let networkError as NetworkError {
            errorMessage = "İzin talebi reddedilirken hata oluştu: \(networkError.localizedDescription)"
            print("❌ [ManagerApprovalQueueViewModel] Failed to reject: \(networkError)")
        } catch {
            errorMessage = "İzin talebi reddedilirken bir hata oluştu. Lütfen tekrar deneyin."
            print("❌ [ManagerApprovalQueueViewModel] Failed to reject: \(error)")
        }

        isRejecting = false
    }

    /// Format date string from ISO8601 to Turkish display format
    /// - Parameter isoDate: ISO8601 date string
    /// - Returns: Formatted date string (dd/MM/yyyy - HH:mm)
    func formatDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate else { return "-" }

        let iso8601Formatter = ISO8601DateFormatter()
        guard let date = iso8601Formatter.date(from: isoDate) else { return isoDate }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd/MM/yyyy - HH:mm"
        displayFormatter.locale = Locale(identifier: "tr_TR")

        return displayFormatter.string(from: date)
    }

    /// Get display text for permission request status
    /// - Parameter status: Status code
    /// - Returns: Display text
    func statusDisplayText(_ status: Int?) -> String {
        guard let status = status else { return "Bilinmiyor" }

        let permissionStatus = PermissionRequestStatus(rawValue: status)
        return permissionStatus?.displayText ?? "Bilinmiyor"
    }

    /// Get color for permission request status
    /// - Parameter status: Status code
    /// - Returns: Color hex string
    func statusColor(_ status: Int?) -> String {
        guard let status = status else { return "#9E9E9E" }

        let permissionStatus = PermissionRequestStatus(rawValue: status)
        return permissionStatus?.color ?? "#9E9E9E"
    }

    /// Calculate duration in days between two dates
    /// - Parameters:
    ///   - startDate: Start date (ISO8601)
    ///   - endDate: End date (ISO8601)
    /// - Returns: Duration text
    func calculateDuration(startDate: String, endDate: String) -> String {
        let iso8601Formatter = ISO8601DateFormatter()

        guard let start = iso8601Formatter.date(from: startDate),
              let end = iso8601Formatter.date(from: endDate) else {
            return "0 gün"
        }

        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        let totalDays = abs(days) + 1

        if totalDays == 1 {
            return "1 gün"
        } else {
            return "\(totalDays) gün"
        }
    }
}
