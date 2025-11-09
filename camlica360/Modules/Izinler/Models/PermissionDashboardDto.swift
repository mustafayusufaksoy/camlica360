import Foundation

/// Permission dashboard response DTO from backend
struct PermissionDashboardDto: Codable {
    let crmPersonnelId: String
    let year: Int
    let balanceSummaries: [PermissionBalanceSummaryDto]
    let requestStatistics: PermissionRequestStatisticsDto
    let recentRequests: [RecentPermissionRequestDto]
    let totalAvailableDays: Double
    let totalUsedDays: Double
    let totalRemainingDays: Double

    enum CodingKeys: String, CodingKey {
        case crmPersonnelId
        case year
        case balanceSummaries
        case requestStatistics
        case recentRequests
        case totalAvailableDays
        case totalUsedDays
        case totalRemainingDays
    }
}

/// Permission balance summary DTO
struct PermissionBalanceSummaryDto: Codable {
    let permissionTypeId: String
    let permissionTypeName: String
    let permissionTypeCode: String?
    let permissionTypeColor: String?
    let annualDays: Double
    let transferredDays: Double
    let availableDays: Double
    let usedDays: Double
    let remainingDays: Double
    let usagePercentage: Double
    let activeRequestsCount: Int
}

/// Permission request statistics DTO
struct PermissionRequestStatisticsDto: Codable {
    let totalRequests: Int
    let pendingRequests: Int
    let approvedRequests: Int
    let rejectedRequests: Int
    let cancelledRequests: Int
    let totalDaysRequested: Double
    let totalDaysApproved: Double
}

/// Recent permission request DTO (simplified)
struct RecentPermissionRequestDto: Codable {
    let id: String
    let permissionTypeName: String
    let startDate: String
    let endDate: String
    let desiredDays: Double
    let status: Int
    let createdAt: String
}
