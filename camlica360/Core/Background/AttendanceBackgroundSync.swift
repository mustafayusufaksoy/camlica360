import BackgroundTasks
import Foundation

/// Manages background synchronization of pending attendance logs
@MainActor
final class AttendanceBackgroundSync {
    // MARK: - Singleton

    static let shared = AttendanceBackgroundSync()

    // MARK: - Constants

    private let backgroundTaskIdentifier = "com.camlica360.attendance.sync"
    private let minimumSyncInterval: TimeInterval = 900 // 15 minutes

    // MARK: - Properties

    private var lastSyncTime: Date?
    private var isSyncScheduled = false

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Register background sync tasks
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            Task { @MainActor in
                await self?.handleBackgroundSync(task: task as! BGAppRefreshTask)
            }
        }

        print("✅ [AttendanceBackgroundSync] Registered background sync task")
    }

    /// Schedule the next background sync
    func scheduleNextSync() {
        // Don't schedule if already scheduled
        guard !isSyncScheduled else {
            return
        }

        // Cancel previous scheduled task
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)

        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: minimumSyncInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
            isSyncScheduled = true
            print("✅ [AttendanceBackgroundSync] Scheduled next sync in \(Int(minimumSyncInterval))s")
        } catch {
            print("❌ [AttendanceBackgroundSync] Failed to schedule: \(error)")
        }
    }

    /// Cancel pending background sync
    func cancelSync() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        isSyncScheduled = false
        print("✅ [AttendanceBackgroundSync] Cancelled pending sync task")
    }

    // MARK: - Private Methods

    private func handleBackgroundSync(task: BGAppRefreshTask) {
        print("🔄 [AttendanceBackgroundSync] Background sync started")

        // Set expiration handler
        task.expirationHandler = {
            print("⏱️ [AttendanceBackgroundSync] Sync expired - OS terminating task")
            task.setTaskCompleted(success: false)
        }

        // Perform sync
        Task {
            do {
                // Try to sync pending logs
                let attendanceService = AttendanceService.shared
                try await attendanceService.syncPendingLogs()

                print("✅ [AttendanceBackgroundSync] Sync completed successfully")
                task.setTaskCompleted(success: true)

                // Schedule next sync
                scheduleNextSync()
            } catch {
                print("❌ [AttendanceBackgroundSync] Sync failed: \(error)")
                task.setTaskCompleted(success: false)

                // Reschedule for retry
                scheduleNextSync()
            }
        }
    }
}

// MARK: - App Delegate Integration

/// Add this to your app delegate or in the app initialization
extension AttendanceBackgroundSync {
    /// Initialize background sync (call this in app launch)
    static func initializeBackgroundSync() {
        let syncManager = AttendanceBackgroundSync.shared
        syncManager.registerBackgroundTasks()

        // Schedule initial sync 15 minutes from now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncManager.scheduleNextSync()
        }

        print("✅ Background sync initialized")
    }
}
