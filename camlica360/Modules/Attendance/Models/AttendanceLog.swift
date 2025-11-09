import Foundation

/// Represents an attendance log entry (check-in or check-out)
struct AttendanceLog: Codable, Identifiable, Hashable {
    let id: String
    let companyId: String
    let crmPersonnelId: String
    let workplaceLocationId: String
    let eventType: AttendanceEventType
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let accuracyInMeters: Double?
    let deviceInfo: String?
    let isManual: Bool
    let note: String?
    let isSynced: Bool
    let syncedAt: Date?
    let createdAt: Date

    // MARK: - Hashable & Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AttendanceLog, rhs: AttendanceLog) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "companyId"
        case crmPersonnelId = "crmPersonnelId"
        case workplaceLocationId = "workplaceLocationId"
        case eventType
        case timestamp
        case latitude
        case longitude
        case accuracyInMeters = "accuracyInMeters"
        case deviceInfo
        case isManual
        case note
        case isSynced
        case syncedAt
        case createdAt
    }
}

/// Request DTO for creating attendance log
struct CreateAttendanceLogRequest: Codable {
    let crmPersonnelId: String
    let workplaceLocationId: String
    let eventType: AttendanceEventType
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let accuracyInMeters: Double?
    let deviceInfo: String?
    let isManual: Bool
    let note: String?

    enum CodingKeys: String, CodingKey {
        case crmPersonnelId = "crmPersonnelId"
        case workplaceLocationId = "workplaceLocationId"
        case eventType
        case timestamp
        case latitude
        case longitude
        case accuracyInMeters = "accuracyInMeters"
        case deviceInfo
        case isManual
        case note
    }
}

/// Response DTO after creating attendance log
struct AttendanceLogResponse: Codable {
    let id: String
    let success: Bool
    let message: String?
    let serverTimestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case success
        case message
        case serverTimestamp
    }
}

/// Response for batch attendance uploads
struct BatchAttendanceLogResponse: Codable {
    let totalCount: Int
    let successCount: Int
    let failedCount: Int
    let results: [AttendanceLogResponse]
    let success: Bool

    enum CodingKeys: String, CodingKey {
        case totalCount
        case successCount
        case failedCount
        case results
        case success
    }
}
