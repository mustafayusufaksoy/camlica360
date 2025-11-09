import Foundation

/// Personnel service for fetching user profile data
class PersonnelService {
    // MARK: - Singleton

    static let shared = PersonnelService()

    // MARK: - Properties

    private let networkManager = NetworkManager.shared

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Get personnel details by ID
    /// - Parameter userId: User ID
    /// - Returns: PersonnelDetailDto
    func getPersonnelById(userId: String) async throws -> PersonnelDetailDto {
        let response: PersonnelDetailDto = try await networkManager.request(
            endpoint: .getPersonnelById(userId),
            responseType: PersonnelDetailDto.self
        )

        print("✅ [PersonnelService] Personnel details fetched for user: \(response.displayName)")
        return response
    }
}
