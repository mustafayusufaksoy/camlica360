import Foundation

/// API Configuration Constants
struct APIConstants {
    // MARK: - Environment

    /// Current environment (change this to switch between dev/prod)
    enum Environment {
        case development
        case production
    }

    static let currentEnvironment: Environment = .development

    // MARK: - Base URL

    /// Base API URL for CRM Service
    static let baseURL: String = {
        switch currentEnvironment {
        case .development:
            return "http://localhost:5000/api"
        case .production:
            return "https://crm.cmlc.com.tr/api"
        }
    }()

    /// Base URL for HR Service (no /api prefix)
    static let hrBaseURL: String = {
        switch currentEnvironment {
        case .development:
            return "http://localhost:5053"
        case .production:
            return "https://crm.cmlc.com.tr"
        }
    }()

    // MARK: - Timeouts

    /// Request timeout interval in seconds
    static let requestTimeout: TimeInterval = 30

    /// Resource timeout interval in seconds
    static let resourceTimeout: TimeInterval = 60

    // MARK: - Headers

    /// Common HTTP headers
    static let headers: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    // MARK: - Response Codes

    /// HTTP Success code
    static let successCode = 200

    /// HTTP Unauthorized code
    static let unauthorizedCode = 401

    /// HTTP Forbidden code
    static let forbiddenCode = 403

    /// HTTP Not Found code
    static let notFoundCode = 404

    /// HTTP Server Error code
    static let serverErrorCode = 500
}
