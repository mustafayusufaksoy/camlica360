import Foundation
import CoreLocation
import UIKit

/// Service for managing attendance logs (check-in/check-out)
@MainActor
class AttendanceService {
    // MARK: - Singleton

    static let shared = AttendanceService()

    // MARK: - Properties

    private let networkManager = NetworkManager.shared
    private var pendingLogs: [LocalAttendanceLog] = [] // Offline queue
    private var isQueueBeingSynced = false

    // MARK: - Initialization

    private init() {
        loadPendingLogs()
    }

    // MARK: - Public Methods

    /// Log a check-in or check-out event
    /// - Parameters:
    ///   - eventType: Check-in or check-out
    ///   - workplaceLocationId: ID of the workplace location
    ///   - coordinate: Current GPS coordinate
    ///   - accuracyInMeters: GPS accuracy in meters
    ///   - isManual: Whether this is a manual entry
    ///   - note: Optional note
    /// - Returns: Created AttendanceLog
    func logAttendanceEvent(
        eventType: AttendanceEventType,
        workplaceLocationId: String,
        coordinate: CLLocationCoordinate2D,
        accuracyInMeters: Double? = nil,
        isManual: Bool = false,
        note: String? = nil
    ) async throws -> AttendanceLog {
        let userInfo = getUserInfo()

        let request = CreateAttendanceLogRequest(
            crmPersonnelId: userInfo.userId,
            workplaceLocationId: workplaceLocationId,
            eventType: eventType,
            timestamp: Date(),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            accuracyInMeters: accuracyInMeters,
            deviceInfo: getDeviceInfo(),
            isManual: isManual,
            note: note
        )

        do {
            // Try to send immediately
            let response = try await sendAttendanceLog(request)
            return response
        } catch let error as NetworkError where isOfflineError(error) {
            // Save to pending queue if offline
            print("⚠️ [AttendanceService] Offline - saving to queue")
            savePendingLog(request)
            throw error
        } catch {
            // Other errors
            throw error
        }
    }

    /// Get attendance logs for a specific date range
    /// - Parameters:
    ///   - startDate: Start date
    ///   - endDate: End date
    /// - Returns: Array of AttendanceLog
    func getAttendanceLogs(from startDate: Date, to endDate: Date) async throws -> [AttendanceLog] {
        // TODO: Add proper endpoint to Endpoint enum
        // For now, return empty array
        return []
    }

    /// Get today's attendance logs
    /// - Returns: Array of AttendanceLog for today
    func getTodaysLogs() async throws -> [AttendanceLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return try await getAttendanceLogs(from: startOfDay, to: endOfDay)
    }

    /// Get pending (unsync'd) logs
    /// - Returns: Array of pending AttendanceLog
    func getPendingLogs() -> [LocalAttendanceLog] {
        return pendingLogs
    }

    /// Sync pending logs to server
    func syncPendingLogs() async throws {
        guard !pendingLogs.isEmpty else {
            print("ℹ️ [AttendanceService] No pending logs to sync")
            return
        }

        guard !isQueueBeingSynced else {
            print("ℹ️ [AttendanceService] Sync already in progress")
            return
        }

        isQueueBeingSynced = true
        defer { isQueueBeingSynced = false }

        print("🔄 [AttendanceService] Syncing \(pendingLogs.count) pending logs...")

        var successCount = 0
        var failureCount = 0
        var logsToRemove: [String] = []

        for (index, pendingLog) in pendingLogs.enumerated() {
            do {
                _ = try await sendAttendanceLog(pendingLog.request)
                successCount += 1
                logsToRemove.append(pendingLog.id)
                print("✅ [AttendanceService] Synced log [\(index + 1)/\(pendingLogs.count)]")
            } catch {
                failureCount += 1
                print("❌ [AttendanceService] Failed to sync log: \(error)")
            }
        }

        // Remove successfully synced logs
        pendingLogs.removeAll { logsToRemove.contains($0.id) }
        savePendingLogs()

        print("📊 [AttendanceService] Sync complete - Success: \(successCount), Failed: \(failureCount)")

        if successCount > 0 {
            print("✅ [AttendanceService] Successfully synced \(successCount) logs")
        }

        if failureCount > 0 {
            throw NSError(domain: "AttendanceService", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to sync \(failureCount) logs"
            ])
        }
    }

    // MARK: - Private Methods

    private func sendAttendanceLog(_ request: CreateAttendanceLogRequest) async throws -> AttendanceLog {
        // TODO: Add proper endpoint to Endpoint enum
        // For now, create a mock response
        let mockResponse = AttendanceLog(
            id: UUID().uuidString,
            companyId: NetworkManager.shared.getCompanyCode() ?? "",
            crmPersonnelId: request.crmPersonnelId,
            workplaceLocationId: request.workplaceLocationId,
            eventType: request.eventType,
            timestamp: request.timestamp,
            latitude: request.latitude,
            longitude: request.longitude,
            accuracyInMeters: request.accuracyInMeters,
            deviceInfo: request.deviceInfo,
            isManual: request.isManual,
            note: request.note,
            isSynced: true,
            syncedAt: Date(),
            createdAt: Date()
        )

        return mockResponse
    }

    private func savePendingLog(_ request: CreateAttendanceLogRequest) {
        let localLog = LocalAttendanceLog(
            id: UUID().uuidString,
            request: request,
            createdAt: Date()
        )
        pendingLogs.append(localLog)
        savePendingLogs()
    }

    private func savePendingLogs() {
        if let encoded = try? JSONEncoder().encode(pendingLogs) {
            UserDefaults.standard.set(encoded, forKey: "pendingAttendanceLogs")
            print("💾 [AttendanceService] Saved \(pendingLogs.count) pending logs to disk")
        }
    }

    private func loadPendingLogs() {
        if let data = UserDefaults.standard.data(forKey: "pendingAttendanceLogs"),
           let decoded = try? JSONDecoder().decode([LocalAttendanceLog].self, from: data) {
            pendingLogs = decoded
            print("📂 [AttendanceService] Loaded \(pendingLogs.count) pending logs from disk")
        }
    }

    private func getUserInfo() -> UserInfo {
        if let userInfo = UserDefaultsManager.shared.getUserInfo() {
            return userInfo
        }
        // Fallback (should not happen if properly logged in)
        fatalError("User info not available")
    }

    private func getDeviceInfo() -> String {
        let device = UIDevice.current
        return "\(device.systemName) \(device.systemVersion) - \(device.model)"
    }

    private func isOfflineError(_ error: NetworkError) -> Bool {
        switch error {
        case .noInternetConnection, .timeout:
            return true
        default:
            return false
        }
    }
}

// MARK: - Local Attendance Log (for offline queue)

/// Represents a pending attendance log stored locally
struct LocalAttendanceLog: Codable, Identifiable {
    let id: String
    let request: CreateAttendanceLogRequest
    let createdAt: Date
}
