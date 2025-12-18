import CoreLocation
import Foundation

/// Represents a geofence region
struct GeofenceRegion {
    let id: String
    let location: CLLocationCoordinate2D
    let radiusInMeters: CLLocationDistance
    let name: String

    /// Create a CLCircularRegion from this GeofenceRegion
    func toCircularRegion() -> CLCircularRegion {
        let region = CLCircularRegion(
            center: location,
            radius: radiusInMeters,
            identifier: id
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
}

/// Protocol for geofence events
protocol GeofenceDelegate: AnyObject {
    func didEnterRegion(_ regionId: String, regionName: String)
    func didExitRegion(_ regionId: String, regionName: String)
    func geofenceDidFailWithError(_ error: LocationError)
}

/// Manages geofencing for workplace locations
@MainActor
class GeofenceManager: NSObject, ObservableObject {
    // MARK: - Singleton

    static let shared = GeofenceManager()

    // MARK: - Published Properties

    @Published var monitoredRegions: [String: GeofenceRegion] = [:]
    @Published var lastError: LocationError?

    // MARK: - Properties

    private let locationManager = CLLocationManager()
    weak var delegate: GeofenceDelegate?

    // Maximum regions that can be monitored simultaneously (iOS limit)
    private let maxMonitoredRegions = 20

    // MARK: - Initialization

    private override init() {
        super.init()
        setupGeofenceManager()
    }

    // MARK: - Setup

    private func setupGeofenceManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Public Methods

    /// Add a geofence region to monitor
    /// - Parameter region: The GeofenceRegion to monitor
    /// - Returns: true if successfully added, false if limit reached
    func addGeofenceRegion(_ region: GeofenceRegion) -> Bool {
        // Check if we've reached the monitoring limit
        guard monitoredRegions.count < maxMonitoredRegions else {
            print("⚠️ [GeofenceManager] Cannot add more regions. Max limit (\(maxMonitoredRegions)) reached.")
            return false
        }

        // Check if region already exists
        guard monitoredRegions[region.id] == nil else {
            print("ℹ️ [GeofenceManager] Region '\(region.id)' already monitored")
            return true
        }

        let circularRegion = region.toCircularRegion()
        locationManager.startMonitoring(for: circularRegion)
        monitoredRegions[region.id] = region

        print("✅ [GeofenceManager] Started monitoring region: \(region.name) (radius: \(Int(region.radiusInMeters))m)")
        return true
    }

    /// Remove a geofence region from monitoring
    /// - Parameter regionId: The ID of the region to stop monitoring
    func removeGeofenceRegion(_ regionId: String) {
        guard let region = monitoredRegions[regionId] else {
            print("⚠️ [GeofenceManager] Region '\(regionId)' not found")
            return
        }

        // Find the monitored region by ID
        if let monitoredRegion = locationManager.monitoredRegions.first(where: { $0.identifier == regionId }) {
            locationManager.stopMonitoring(for: monitoredRegion)
        }

        monitoredRegions.removeValue(forKey: regionId)
        print("✅ [GeofenceManager] Stopped monitoring region: \(region.name)")
    }

    /// Remove all geofence regions
    func removeAllGeofenceRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredRegions.removeAll()
        print("✅ [GeofenceManager] Removed all monitored regions")
    }

    /// Update an existing geofence region
    /// - Parameter region: The updated GeofenceRegion
    func updateGeofenceRegion(_ region: GeofenceRegion) {
        removeGeofenceRegion(region.id)
        addGeofenceRegion(region)
    }

    /// Get all currently monitored regions
    /// - Returns: Array of GeofenceRegion
    func getAllMonitoredRegions() -> [GeofenceRegion] {
        return Array(monitoredRegions.values)
    }

    /// Check if a coordinate is within a geofence region
    /// - Parameters:
    ///   - coordinate: The coordinate to check
    ///   - regionId: The region ID to check against
    /// - Returns: true if coordinate is within the region
    func isLocationInRegion(_ coordinate: CLLocationCoordinate2D, regionId: String) -> Bool {
        guard let region = monitoredRegions[regionId] else {
            return false
        }

        let distance = LocationManager.distance(from: region.location, to: coordinate)
        return distance <= region.radiusInMeters
    }

    /// Get which regions contain the given coordinate
    /// - Parameter coordinate: The coordinate to check
    /// - Returns: Array of region IDs that contain this coordinate
    func getRegionsContainingLocation(_ coordinate: CLLocationCoordinate2D) -> [String] {
        return monitoredRegions
            .filter { isLocationInRegion(coordinate, regionId: $0.key) }
            .map { $0.key }
    }

    /// Request location permissions needed for geofencing
    func requestGeofencePermission() {
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Private Methods

    private func logRegionStatus() {
        print("📍 [GeofenceManager] Monitored regions count: \(monitoredRegions.count)/\(maxMonitoredRegions)")
        for (_, region) in monitoredRegions {
            print("   - \(region.name) (ID: \(region.id), Radius: \(Int(region.radiusInMeters))m)")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension GeofenceManager: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        Task { @MainActor in
            guard let monitoredRegion = self.monitoredRegions[region.identifier] else {
                return
            }

            print("✅ [GeofenceManager] User entered region: \(monitoredRegion.name)")
            self.delegate?.didEnterRegion(region.identifier, regionName: monitoredRegion.name)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didExitRegion region: CLRegion
    ) {
        Task { @MainActor in
            guard let monitoredRegion = self.monitoredRegions[region.identifier] else {
                return
            }

            print("✅ [GeofenceManager] User exited region: \(monitoredRegion.name)")
            self.delegate?.didExitRegion(region.identifier, regionName: monitoredRegion.name)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        let locationError = LocationError.unknown(error)

        Task { @MainActor in
            self.lastError = locationError
            self.delegate?.geofenceDidFailWithError(locationError)
            print("❌ [GeofenceManager] Error: \(error.localizedDescription)")
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        monitoringDidFailFor region: CLRegion?,
        withError error: Error
    ) {
        guard let region = region else {
            print("❌ [GeofenceManager] Monitoring failed with unknown region: \(error.localizedDescription)")
            return
        }

        print("❌ [GeofenceManager] Monitoring failed for region '\(region.identifier)': \(error.localizedDescription)")

        Task { @MainActor in
            self.removeGeofenceRegion(region.identifier)
            self.lastError = LocationError.unknown(error)
            self.delegate?.geofenceDidFailWithError(self.lastError!)
        }
    }
}
