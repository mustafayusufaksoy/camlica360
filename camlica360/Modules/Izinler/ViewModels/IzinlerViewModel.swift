import Foundation
import SwiftUI

// MARK: - Models

struct ApprovalStatusData: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let percentage: Int
    let color: Color
}

struct UserLeaveData: Identifiable {
    let id = UUID()
    let userName: String
    let usedDays: Int
    let remainingDays: Int
}

/// ViewModel for Izinler module
@MainActor
class IzinlerViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var chartData: [MonthlyData] = []
    @Published var approvalStatusData: [ApprovalStatusData] = []
    @Published var userLeaveData: [UserLeaveData] = []
    @Published var leaveRequests: [LeaveRequest] = []

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

        // Load data
        Task {
            await loadAllData()
        }
    }

    // MARK: - Methods

    /// Load all dashboard data
    func loadAllData() async {
        await loadDashboardData()
    }

    /// Load dashboard data (includes chart, balances, and statistics)
    private func loadDashboardData() async {
        // Get current user ID
        guard let userId = keychainManager.getUserId() else {
            error = "Kullanıcı bilgisi bulunamadı"
            print("❌ [IzinlerViewModel] User ID not found in Keychain")
            return
        }

        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())

        isLoading = true
        error = nil

        do {
            print("🔵 [IzinlerViewModel] Loading dashboard data for user: \(userId), year: \(currentYear)")

            // Fetch dashboard data (includes everything)
            let dashboard = try await izinlerService.getEmployeeDashboard(
                personnelId: userId,
                year: currentYear
            )

            print("✅ [IzinlerViewModel] Dashboard data fetched successfully")

            // 1. Prepare chart data from approved requests
            let approvedRequests = dashboard.recentRequests.filter {
                $0.status == PermissionRequestStatus.approved.rawValue
            }
            chartData = groupRequestsByMonth(approvedRequests)
            print("✅ [IzinlerViewModel] Chart data prepared with \(chartData.count) months")

            // 2. Prepare user leave data from balance summaries
            userLeaveData = dashboard.balanceSummaries.map { balance in
                UserLeaveData(
                    userName: balance.permissionTypeName,
                    usedDays: Int(balance.usedDays),
                    remainingDays: Int(balance.remainingDays)
                )
            }
            print("✅ [IzinlerViewModel] Loaded \(userLeaveData.count) leave balances")

            // 3. Prepare approval status data from statistics
            approvalStatusData = [
                ApprovalStatusData(
                    title: "Onaylanan",
                    count: dashboard.requestStatistics.approvedRequests,
                    percentage: calculatePercentage(
                        dashboard.requestStatistics.approvedRequests,
                        total: dashboard.requestStatistics.totalRequests
                    ),
                    color: Color(hex: "00C853")
                ),
                ApprovalStatusData(
                    title: "Bekleyen",
                    count: dashboard.requestStatistics.pendingRequests,
                    percentage: calculatePercentage(
                        dashboard.requestStatistics.pendingRequests,
                        total: dashboard.requestStatistics.totalRequests
                    ),
                    color: Color(hex: "FFB300")
                ),
                ApprovalStatusData(
                    title: "Reddedilen",
                    count: dashboard.requestStatistics.rejectedRequests,
                    percentage: calculatePercentage(
                        dashboard.requestStatistics.rejectedRequests,
                        total: dashboard.requestStatistics.totalRequests
                    ),
                    color: Color(hex: "E53935")
                )
            ]
            print("✅ [IzinlerViewModel] Loaded approval statistics")

            // 4. Load all permission requests for the table
            await loadLeaveRequests(userId: userId)

        } catch let networkError as NetworkError {
            error = networkError.localizedDescription
            print("❌ [IzinlerViewModel] Failed to load dashboard data: \(networkError.localizedDescription)")
        } catch {
            self.error = "Dashboard verileri yüklenirken bir hata oluştu"
            print("❌ [IzinlerViewModel] Failed to load dashboard data: \(error)")
        }

        isLoading = false
    }

    /// Calculate percentage
    private func calculatePercentage(_ value: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(value) / Double(total)) * 100)
    }

    /// Group permission requests by month and calculate total days used per month
    private func groupRequestsByMonth(_ requests: [RecentPermissionRequestDto]) -> [MonthlyData] {
        let calendar = Calendar.current
        let dateFormatter = ISO8601DateFormatter()

        // Initialize 12 months with 0 days
        var monthlyDays: [Int: Double] = [:]
        for month in 1...12 {
            monthlyDays[month] = 0
        }

        // Process each request
        for request in requests {
            guard let startDate = dateFormatter.date(from: request.startDate),
                  let endDate = dateFormatter.date(from: request.endDate) else {
                print("⚠️ [IzinlerViewModel] Invalid date format for request: \(request.id)")
                continue
            }

            // Calculate days for each month in the date range
            let daysInRange = calculateDaysPerMonth(from: startDate, to: endDate, calendar: calendar)

            // Add to monthly totals
            for (month, days) in daysInRange {
                monthlyDays[month, default: 0] += days
            }
        }

        // Convert to MonthlyData array
        let monthNames = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]

        return monthNames.enumerated().map { index, name in
            let monthNumber = index + 1
            let value = monthlyDays[monthNumber] ?? 0
            return MonthlyData(month: name, value: value)
        }
    }

    /// Calculate how many days fall in each month for a date range
    private func calculateDaysPerMonth(from startDate: Date, to endDate: Date, calendar: Calendar) -> [Int: Double] {
        var result: [Int: Double] = [:]

        var currentDate = startDate

        while currentDate <= endDate {
            let month = calendar.component(.month, from: currentDate)

            // Count this day
            result[month, default: 0] += 1

            // Move to next day
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return result
    }

    /// Load leave requests from API
    private func loadLeaveRequests(userId: String) async {
        do {
            print("🔵 [IzinlerViewModel] Loading leave requests for user: \(userId)")

            // Fetch all permission requests
            let requests = try await izinlerService.getAllPermissionRequests(personnelId: userId)

            // Map backend DTO to LeaveRequest model
            leaveRequests = requests.map { dto in
                mapToLeaveRequest(dto)
            }

            print("✅ [IzinlerViewModel] Loaded \(leaveRequests.count) leave requests")

        } catch {
            print("❌ [IzinlerViewModel] Failed to load leave requests: \(error)")
            // Keep empty array on error
            leaveRequests = []
        }
    }

    /// Map PermissionRequestsDto to LeaveRequest
    private func mapToLeaveRequest(_ dto: PermissionRequestsDto) -> LeaveRequest {
        // Format dates
        let dateFormatter = ISO8601DateFormatter()
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd/MM/yyyy - HH:mm"
        displayFormatter.locale = Locale(identifier: "tr_TR")

        let startDateFormatted: String
        let endDateFormatted: String

        if let startDate = dateFormatter.date(from: dto.startDate) {
            startDateFormatted = displayFormatter.string(from: startDate)
        } else {
            startDateFormatted = dto.startDate
        }

        if let endDate = dateFormatter.date(from: dto.endDate) {
            endDateFormatted = displayFormatter.string(from: endDate)
        } else {
            endDateFormatted = dto.endDate
        }

        // Map status
        let status: LeaveRequest.LeaveStatus
        switch dto.status {
        case 0: status = .pending
        case 1: status = .approved
        case 2: status = .rejected
        default: status = .normal
        }

        // Parse attachments from path
        let attachments: [String]
        if let path = dto.attachmentPath, !path.isEmpty {
            // Extract filename from path
            let filename = (path as NSString).lastPathComponent
            attachments = [filename]
        } else {
            attachments = []
        }

        return LeaveRequest(
            leaveType: dto.permissionTypeName,
            duration: "\(dto.desiredDays) gün",
            startDate: startDateFormatted,
            endDate: endDateFormatted,
            description: dto.description ?? "",
            status: status,
            attachments: attachments
        )
    }
}
