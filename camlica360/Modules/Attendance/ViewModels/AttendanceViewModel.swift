import Foundation
import CoreLocation
import SwiftUI

/// ViewModel for the main attendance check-in/check-out screen
@MainActor
class AttendanceViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationStatus: String = "location_services_disabled".localized
    @Published var isLocationAvailable = false

    @Published var currentWorkplaceLocation: WorkplaceLocation?
    @Published var isInsideGeofence = false

    @Published var todaysLogs: [AttendanceLog] = []
    @Published var lastEventType: AttendanceEventType?

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    @Published var pendingLogsCount = 0
    @Published var showPendingLogsAlert = false

    // MARK: - Properties

    private let locationManager = LocationManager.shared
    private let geofenceManager = GeofenceManager.shared
    private let attendanceService = AttendanceService.shared
    private let locationService = AttendanceLocationService.shared

    private var refreshTimer: Timer?

    // MARK: - Initialization

    init() {
        setupLocationDelegates()
        setupGeofenceDelegates()
        loadInitialData()
    }

    // MARK: - Public Methods

    /// Initialize location tracking
    func startAttendanceTracking() async {
        // Request location permissions
        locationManager.requestLocationPermission(alwaysAllow: true)

        // Load workplace locations and setup geofences
        await setupGeofences()

        // Start location updates
        locationManager.startLocationUpdates()

        // Start periodic refresh
        startPeriodicRefresh()

        // Load today's logs
        await loadTodaysLogs()

        // Check pending logs
        checkPendingLogs()
    }

    /// Stop attendance tracking
    func stopAttendanceTracking() {
        locationManager.stopLocationUpdates()
        geofenceManager.removeAllGeofenceRegions()
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    /// Manual check-in
    func manualCheckIn() async {
        await recordAttendance(eventType: .checkIn, isManual: true)
    }

    /// Manual check-out
    func manualCheckOut() async {
        await recordAttendance(eventType: .checkOut, isManual: true)
    }

    /// Sync pending logs
    func syncPendingLogs() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await attendanceService.syncPendingLogs()
            checkPendingLogs()
            await loadTodaysLogs()
            print("✅ [AttendanceViewModel] Pending logs synced successfully")
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    /// Refresh today's logs
    func refreshTodaysLogs() async {
        await loadTodaysLogs()
    }

    // MARK: - Private Methods

    private func setupLocationDelegates() {
        locationManager.delegate = self
    }

    private func setupGeofenceDelegates() {
        geofenceManager.delegate = self
    }

    private func loadInitialData() {
        Task {
            await setupGeofences()
            await loadTodaysLogs()
            checkPendingLogs()
        }
    }

    private func setupGeofences() async {
        do {
            let locations = try await locationService.getLocations()
            locationService.setupGeofences(for: locations)
            print("✅ [AttendanceViewModel] Geofences setup completed")
        } catch {
            showError(message: "Failed to load workplace locations: \(error.localizedDescription)")
        }
    }

    private func recordAttendance(eventType: AttendanceEventType, isManual: Bool) async {
        guard let location = currentLocation else {
            showError(message: "location_not_available".localized)
            return
        }

        guard let workplace = currentWorkplaceLocation else {
            showError(message: "not_in_workplace".localized)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await attendanceService.logAttendanceEvent(
                eventType: eventType,
                workplaceLocationId: workplace.id,
                coordinate: location,
                isManual: isManual,
                note: nil
            )

            lastEventType = eventType
            await loadTodaysLogs()

            let message = eventType == .checkIn ?
                "check_in_successful".localized :
                "check_out_successful".localized
            print("✅ \(message)")

        } catch let error as NetworkError where error.isOfflineError {
            // Offline is OK - it's saved locally
            lastEventType = eventType
            await loadTodaysLogs()
            showError(message: "offline_log_saved".localized)
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    private func loadTodaysLogs() async {
        do {
            todaysLogs = try await attendanceService.getTodaysLogs()
            print("📋 [AttendanceViewModel] Loaded \(todaysLogs.count) logs for today")
        } catch {
            print("❌ [AttendanceViewModel] Failed to load today's logs: \(error)")
        }
    }

    private func checkPendingLogs() {
        let pending = attendanceService.getPendingLogs()
        pendingLogsCount = pending.count
        print("🔄 [AttendanceViewModel] Pending logs count: \(pendingLogsCount)")
    }

    private func startPeriodicRefresh() {
        // Refresh logs every 30 seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.loadTodaysLogs()
                self?.checkPendingLogs()
            }
        }
    }

    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }

    deinit {
        refreshTimer?.invalidate()
    }
}

// MARK: - LocationDelegate

extension AttendanceViewModel: LocationDelegate {
    nonisolated func didUpdateLocation(_ location: CLLocationCoordinate2D) {
        Task { @MainActor [weak self] in
            self?.currentLocation = location

            // Check if we're inside any workplace geofence
            let geofenceManager = self?.geofenceManager
            let locationService = self?.locationService

            if let inside = locationService?.findLocationContainingCoordinate(location) {
                self?.currentWorkplaceLocation = inside
                self?.isInsideGeofence = true
            } else {
                self?.isInsideGeofence = false
            }
        }
    }

    nonisolated func didFailWithError(_ error: LocationError) {
        Task { @MainActor [weak self] in
            self?.showError(message: error.errorDescription ?? "Unknown location error")
        }
    }

    nonisolated func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        Task { @MainActor [weak self] in
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self?.isLocationAvailable = true
                self?.locationStatus = "location_enabled".localized
            case .denied, .restricted:
                self?.isLocationAvailable = false
                self?.locationStatus = "location_disabled".localized
            case .notDetermined:
                self?.locationStatus = "location_permission_not_determined".localized
            @unknown default:
                self?.locationStatus = "location_unknown_status".localized
            }
        }
    }
}

// MARK: - GeofenceDelegate

extension AttendanceViewModel: GeofenceDelegate {
    nonisolated func didEnterRegion(_ regionId: String, regionName: String) {
        print("✅ Entered region: \(regionName)")
        Task { @MainActor [weak self] in
            self?.currentWorkplaceLocation = await self?.locationService.getLocationById(regionId) ?? nil
            self?.isInsideGeofence = true
        }
    }

    nonisolated func didExitRegion(_ regionId: String, regionName: String) {
        print("❌ Exited region: \(regionName)")
        Task { @MainActor [weak self] in
            self?.isInsideGeofence = false
            self?.currentWorkplaceLocation = nil
        }
    }

    nonisolated func didFailWithError(_ error: LocationError) {
        Task { @MainActor [weak self] in
            self?.showError(message: error.errorDescription ?? "Geofence error")
        }
    }
}

// MARK: - Helper Extension

extension NetworkError {
    var isOfflineError: Bool {
        switch self {
        case .noInternetConnection, .timeout:
            return true
        default:
            return false
        }
    }
}
