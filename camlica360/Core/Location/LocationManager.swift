import CoreLocation
import Foundation

/// Error types for location operations
enum LocationError: LocalizedError {
    case deniedPermission
    case restrictedPermission
    case notDetermined
    case locationServicesDisabled
    case invalidLocation
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .deniedPermission:
            return "location_permission_denied".localized
        case .restrictedPermission:
            return "location_permission_restricted".localized
        case .notDetermined:
            return "location_permission_not_determined".localized
        case .locationServicesDisabled:
            return "location_services_disabled".localized
        case .invalidLocation:
            return "location_invalid".localized
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

/// Protocol for location updates
protocol LocationDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocationCoordinate2D)
    func didFailWithError(_ error: LocationError)
    func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus)
}

/// Manages device location and provides location updates
@MainActor
class LocationManager: NSObject, ObservableObject {
    // MARK: - Singleton

    static let shared = LocationManager()

    // MARK: - Published Properties

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationAvailable = false
    @Published var lastError: LocationError?

    // MARK: - Properties

    private let locationManager = CLLocationManager()
    weak var delegate: LocationDelegate?

    // MARK: - Initialization

    private override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Setup

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        // Check current authorization status
        updateAuthorizationStatus()
    }

    // MARK: - Public Methods

    /// Request location permissions
    /// - Parameter alwaysAllow: If true, requests "Always" permission; otherwise "WhenInUse"
    func requestLocationPermission(alwaysAllow: Bool = false) {
        switch authorizationStatus {
        case .notDetermined:
            if alwaysAllow {
                locationManager.requestAlwaysAndWhenInUseAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        case .denied, .restricted:
            lastError = authorizationStatus == .denied ? .deniedPermission : .restrictedPermission
            delegate?.didFailWithError(lastError!)
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        @unknown default:
            lastError = .unknown(NSError(domain: "LocationManager", code: -1))
        }
    }

    /// Start receiving location updates
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            lastError = .locationServicesDisabled
            delegate?.didFailWithError(lastError!)
            isLocationAvailable = false
            return
        }

        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            lastError = .deniedPermission
            delegate?.didFailWithError(lastError!)
            isLocationAvailable = false
            return
        }

        locationManager.startUpdatingLocation()
        isLocationAvailable = true
    }

    /// Stop receiving location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationAvailable = false
    }

    /// Get current location (if available)
    /// - Returns: Current CLLocationCoordinate2D or nil
    func getLastKnownLocation() -> CLLocationCoordinate2D? {
        return currentLocation
    }

    /// Calculate distance between two coordinates
    /// - Parameters:
    ///   - from: Starting coordinate
    ///   - to: Ending coordinate
    /// - Returns: Distance in meters
    static func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let endLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return startLocation.distance(from: endLocation)
    }

    // MARK: - Private Methods

    private func updateAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        let coordinate = location.coordinate

        Task { @MainActor in
            self.currentLocation = coordinate
            self.delegate?.didUpdateLocation(coordinate)
            print("📍 [LocationManager] Location updated: \(coordinate.latitude), \(coordinate.longitude)")
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        let locationError = LocationError.unknown(error)

        Task { @MainActor in
            self.lastError = locationError
            self.delegate?.didFailWithError(locationError)
            print("❌ [LocationManager] Error: \(error.localizedDescription)")
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        Task { @MainActor in
            self.authorizationStatus = status
            self.delegate?.didChangeAuthorizationStatus(status)

            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                print("✅ [LocationManager] Location permission granted")
                self.startLocationUpdates()
            case .denied:
                print("❌ [LocationManager] Location permission denied")
                self.stopLocationUpdates()
            case .restricted:
                print("⚠️ [LocationManager] Location permission restricted")
                self.stopLocationUpdates()
            case .notDetermined:
                print("ℹ️ [LocationManager] Location permission not determined")
            @unknown default:
                break
            }
        }
    }
}
