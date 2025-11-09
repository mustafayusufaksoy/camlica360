import Foundation
import CoreLocation

/// Represents a workplace location for attendance tracking
struct WorkplaceLocation: Codable, Identifiable, Hashable {
    let id: String
    let companyId: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let radiusInMeters: Int
    let isActive: Bool
    let notes: String?
    let assignedEmployeeCount: Int
    let createdAt: Date
    let updatedAt: Date?

    // MARK: - Computed Properties

    /// Get coordinates as CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Get radius as CLLocationDistance
    var radiusInMetersDouble: CLLocationDistance {
        CLLocationDistance(radiusInMeters)
    }

    // MARK: - Hashable & Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: WorkplaceLocation, rhs: WorkplaceLocation) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "companyId"
        case name
        case address
        case latitude
        case longitude
        case radiusInMeters = "radiusInMeters"
        case isActive
        case notes
        case assignedEmployeeCount
        case createdAt
        case updatedAt
    }
}
