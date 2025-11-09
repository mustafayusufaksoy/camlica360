import Foundation

/// Generic API result wrapper from backend
/// Matches backend's Result<T> structure
struct ApiResult<T: Codable>: Codable {
    let data: T?
    let success: Bool
    let message: String?
    let code: Int

    enum CodingKeys: String, CodingKey {
        case data
        case success
        case message
        case code
    }
}
