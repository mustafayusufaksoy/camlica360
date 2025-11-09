import Foundation

/// Enum for attendance event types
enum AttendanceEventType: Int, Codable {
    case checkIn = 0
    case checkOut = 1

    var displayName: String {
        switch self {
        case .checkIn:
            return "attendance_check_in".localized
        case .checkOut:
            return "attendance_check_out".localized
        }
    }
}
