import Foundation

/// ViewModel for attendance history and reporting
@MainActor
class AttendanceHistoryViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var logs: [AttendanceLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    @Published var selectedDateRange: DateRange = .today
    @Published var dailySummaries: [DailySummary] = []

    // MARK: - Properties

    private let attendanceService = AttendanceService.shared

    // MARK: - Initialization

    init() {
        loadLogs()
    }

    // MARK: - Public Methods

    /// Load logs for selected date range
    func loadLogs() {
        Task {
            await loadLogsForDateRange(selectedDateRange)
        }
    }

    /// Change date range and reload logs
    /// - Parameter dateRange: New date range
    func selectDateRange(_ dateRange: DateRange) {
        selectedDateRange = dateRange
        loadLogs()
    }

    // MARK: - Private Methods

    private func loadLogsForDateRange(_ dateRange: DateRange) async {
        isLoading = true
        defer { isLoading = false }

        let (startDate, endDate) = dateRange.dateRange

        do {
            logs = try await attendanceService.getAttendanceLogs(from: startDate, to: endDate)
            generateDailySummaries()
            print("✅ [AttendanceHistoryViewModel] Loaded \(logs.count) logs")
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    private func generateDailySummaries() {
        let grouped = Dictionary(grouping: logs) { log in
            Calendar.current.startOfDay(for: log.timestamp)
        }

        dailySummaries = grouped.sorted { $0.key > $1.key }.map { date, logsForDate in
            let checkIns = logsForDate.filter { $0.eventType == .checkIn }
            let checkOuts = logsForDate.filter { $0.eventType == .checkOut }

            let firstCheckIn = checkIns.min { $0.timestamp < $1.timestamp }?.timestamp
            let lastCheckOut = checkOuts.max { $0.timestamp < $1.timestamp }?.timestamp

            var workingHours: TimeInterval = 0
            if let checkIn = firstCheckIn, let checkOut = lastCheckOut {
                workingHours = checkOut.timeIntervalSince(checkIn)
            }

            return DailySummary(
                date: date,
                checkInCount: checkIns.count,
                checkOutCount: checkOuts.count,
                firstCheckIn: firstCheckIn,
                lastCheckOut: lastCheckOut,
                totalWorkingHours: workingHours,
                logs: logsForDate.sorted { $0.timestamp < $1.timestamp }
            )
        }
    }

    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}

// MARK: - Date Range Enum

enum DateRange: String, CaseIterable {
    case today = "today"
    case yesterday = "yesterday"
    case thisWeek = "this_week"
    case lastWeek = "last_week"
    case thisMonth = "this_month"
    case lastMonth = "last_month"

    var displayName: String {
        return "date_range_\(rawValue)".localized
    }

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return (startOfDay, endOfDay)

        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            let startOfDay = calendar.startOfDay(for: yesterday)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return (startOfDay, endOfDay)

        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
            return (startOfWeek, endOfWeek)

        case .lastWeek:
            let startOfThisWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let startOfLastWeek = calendar.date(byAdding: .day, value: -7, to: startOfThisWeek)!
            let endOfLastWeek = startOfThisWeek
            return (startOfLastWeek, endOfLastWeek)

        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return (startOfMonth, endOfMonth)

        case .lastMonth:
            let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth)!
            return (startOfLastMonth, startOfThisMonth)
        }
    }
}

// MARK: - Daily Summary

struct DailySummary: Identifiable {
    let id = UUID()
    let date: Date
    let checkInCount: Int
    let checkOutCount: Int
    let firstCheckIn: Date?
    let lastCheckOut: Date?
    let totalWorkingHours: TimeInterval
    let logs: [AttendanceLog]

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    var workingHoursString: String {
        let hours = Int(totalWorkingHours / 3600)
        let minutes = Int((totalWorkingHours.truncatingRemainder(dividingBy: 3600)) / 60)
        return String(format: "%02d:%02d", hours, minutes)
    }

    var statusString: String {
        if checkInCount == 0 {
            return "not_checked_in".localized
        }
        if checkOutCount == 0 {
            return "checked_in".localized
        }
        return "checked_out".localized
    }
}
