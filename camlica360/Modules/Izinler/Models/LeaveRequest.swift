import Foundation
import SwiftUI

/// Leave request model for table
struct LeaveRequest: Identifiable {
    let id = UUID()
    let leaveType: String
    let duration: String
    let startDate: String
    let endDate: String
    let description: String
    let status: LeaveStatus
    let attachments: [String]

    enum LeaveStatus {
        case pending
        case approved
        case rejected
        case normal

        var title: String {
            switch self {
            case .pending: return "Beklemede"
            case .approved: return "Onaylandı"
            case .rejected: return "Reddedildi"
            case .normal: return "Normal"
            }
        }

        var color: Color {
            switch self {
            case .pending: return Color(hex: "FFB300")
            case .approved: return Color(hex: "00C853")
            case .rejected: return Color(hex: "E53935")
            case .normal: return AppColors.primary600
            }
        }

        var backgroundColor: Color {
            switch self {
            case .pending: return Color(hex: "FFF9E6")
            case .approved: return Color(hex: "E8F5E9")
            case .rejected: return Color(hex: "FFEBEE")
            case .normal: return Color(hex: "EDE7F6")
            }
        }
    }
}
