import Foundation

/// Service for managing workplace locations and geofence setup
@MainActor
class AttendanceLocationService {
    // MARK: - Singleton

    static let shared = AttendanceLocationService()

    // MARK: - Properties

    private let networkManager = NetworkManager.shared
    private var cachedLocations: [WorkplaceLocation] = []
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Fetch workplace locations for the current user's company
    /// - Returns: Array of WorkplaceLocation
    func fetchWorkplaceLocations() async throws -> [WorkplaceLocation] {
        let endpoint = Endpoint(
            path: "/hr/workplace-location/getActiveByCompany/\(getCurrentCompanyId())",
            method: .get
        )

        let locations: [WorkplaceLocation] = try await networkManager.request(
            endpoint: endpoint,
            responseType: [WorkplaceLocation].self
        )

        self.cachedLocations = locations
        return locations
    }

    /// Get cached locations (or fetch if empty)
    /// - Returns: Array of WorkplaceLocation
    func getLocations() async throws -> [WorkplaceLocation] {
        if !cachedLocations.isEmpty {
            return cachedLocations
        }
        return try await fetchWorkplaceLocations()
    }

    /// Get a specific workplace location by ID
    /// - Parameter id: Location ID
    /// - Returns: WorkplaceLocation
    func getLocationById(_ id: String) async throws -> WorkplaceLocation {
        let endpoint = Endpoint(
            path: "/hr/workplace-location/getById/\(id)",
            method: .get
        )

        return try await networkManager.request(
            endpoint: endpoint,
            responseType: WorkplaceLocation.self
        )
    }

    /// Setup geofences for all active locations
    /// - Parameter locations: Array of WorkplaceLocation to setup
    func setupGeofences(for locations: [WorkplaceLocation]) {
        let geofenceManager = GeofenceManager.shared

        // Clear existing geofences
        geofenceManager.removeAllGeofenceRegions()

        // Add new geofences
        for location in locations {
            let region = GeofenceRegion(
                id: location.id,
                location: location.coordinate,
                radiusInMeters: location.radiusInMetersDouble,
                name: location.name
            )
            _ = geofenceManager.addGeofenceRegion(region)
        }

        print("✅ [AttendanceLocationService] Setup \(locations.count) geofence regions")
    }

    /// Clear all geofences
    func clearGeofences() {
        GeofenceManager.shared.removeAllGeofenceRegions()
        print("✅ [AttendanceLocationService] Cleared all geofence regions")
    }

    /// Get the nearest workplace location to current user
    /// - Parameter currentLocation: Current user location
    /// - Returns: Nearest WorkplaceLocation or nil
    func getNearestLocation(to currentLocation: CLLocationCoordinate2D) -> WorkplaceLocation? {
        var nearestLocation: WorkplaceLocation?
        var minDistance = Double.infinity

        for location in cachedLocations {
            let distance = LocationManager.distance(from: currentLocation, to: location.coordinate)
            if distance < minDistance {
                minDistance = distance
                nearestLocation = location
            }
        }

        return nearestLocation
    }

    /// Check if location is inside any workplace geofence
    /// - Parameter coordinate: Coordinate to check
    /// - Returns: WorkplaceLocation if found, nil otherwise
    func findLocationContainingCoordinate(_ coordinate: CLLocationCoordinate2D) -> WorkplaceLocation? {
        for location in cachedLocations {
            let distance = LocationManager.distance(from: coordinate, to: location.coordinate)
            if distance <= Double(location.radiusInMeters) {
                return location
            }
        }
        return nil
    }

    // MARK: - Private Methods

    private func getCurrentCompanyId() -> String {
        // Get from UserDefaults or UserInfo
        if let userInfo = UserDefaultsManager.shared.getUserInfo() {
            return userInfo.companyId
        }
        return UserDefaultsManager.shared.getCompanyCode() ?? "unknown"
    }
}
