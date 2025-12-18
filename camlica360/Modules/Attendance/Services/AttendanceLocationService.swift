import Foundation
import CoreLocation

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
        // TODO: Add proper endpoint to Endpoint enum
        // For now, using a workaround with manual path
        let companyId = getCurrentCompanyId()

        // Mock response - replace with actual API call when endpoint is available
        // let locations: [WorkplaceLocation] = try await networkManager.request(...)

        // Return empty array for now
        let locations: [WorkplaceLocation] = []

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
        // TODO: Add proper endpoint to Endpoint enum
        // For now, check cached locations
        if let location = cachedLocations.first(where: { $0.id == id }) {
            return location
        }

        throw NetworkError.notFound
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
        if let userInfo = UserDefaultsManager.shared.getUserInfo(),
           let companyId = userInfo.companyId {
            return companyId
        }
        return UserDefaultsManager.shared.getCompanyCode() ?? "unknown"
    }
}
