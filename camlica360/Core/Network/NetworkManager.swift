import Foundation

/// Generic API Response wrapper
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let code: Int
    let data: T?
}

/// Network Manager for handling HTTP requests
class NetworkManager: NSObject {
    // MARK: - Singleton

    static let shared = NetworkManager()

    // MARK: - Properties

    private let session: URLSession
    private var accessToken: String?
    private var companyCode: String?

    // MARK: - Initialization

    private override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConstants.requestTimeout
        configuration.timeoutIntervalForResource = APIConstants.resourceTimeout

        // Create session with delegate for SSL bypass (development only)
        let delegate = SSLBypassDelegate()
        self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)

        super.init()
    }

    // MARK: - Token Management

    /// Set access token for authenticated requests
    func setAccessToken(_ token: String?) {
        self.accessToken = token
    }

    /// Get current access token
    func getAccessToken() -> String? {
        return accessToken
    }

    /// Set company code for requests
    func setCompanyCode(_ code: String?) {
        self.companyCode = code
    }

    /// Get current company code
    func getCompanyCode() -> String? {
        return companyCode
    }

    // MARK: - Request Methods

    /// Generic request method
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - body: Request body (Encodable)
    ///   - responseType: Expected response type
    /// - Returns: Decoded response
    func request<Request: Encodable, Response: Decodable>(
        endpoint: Endpoint,
        body: Request? = nil,
        responseType: Response.Type
    ) async throws -> Response {
        // Build URL
        guard let url = buildURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Add headers
        request.allHTTPHeaderFields = APIConstants.headers

        // Add authorization header if token exists
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add company code header if exists
        if let code = companyCode {
            request.setValue(code, forHTTPHeaderField: "X-Company-Code")
        }

        // Add body if exists
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError
            }
        }

        // Log request
        logRequest(request, body: body)

        // Perform request
        do {
            let (data, response) = try await session.data(for: request)

            // Log response
            logResponse(response, data: data)

            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "NetworkManager", code: -1))
            }

            // Handle status codes
            try handleStatusCode(httpResponse.statusCode, data: data)

            // Parse backend response wrapper
            let apiResponse = try JSONDecoder().decode(APIResponse<Response>.self, from: data)

            // Check success flag
            guard apiResponse.success, let responseData = apiResponse.data else {
                let message = apiResponse.message ?? "Unknown error"
                throw NetworkError.serverError(apiResponse.code, message)
            }

            return responseData

        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            if error.code == .timedOut {
                throw NetworkError.timeout
            } else if error.code == .notConnectedToInternet {
                throw NetworkError.noInternetConnection
            }
            throw NetworkError.unknown(error)
        } catch {
            if let decodingError = error as? DecodingError {
                print("❌ Decoding Error: \(decodingError)")
                throw NetworkError.decodingError(decodingError)
            }
            throw NetworkError.unknown(error)
        }
    }

    /// Simple request without body
    func request<Response: Decodable>(
        endpoint: Endpoint,
        responseType: Response.Type
    ) async throws -> Response {
        return try await request(endpoint: endpoint, body: Optional<String>.none, responseType: responseType)
    }

    // MARK: - Private Helpers

    private func buildURL(for endpoint: Endpoint) -> URL? {
        // Use hrBaseURL for HR service endpoints, baseURL for others
        let baseURL = endpoint.path.hasPrefix("/hr") ? APIConstants.hrBaseURL : APIConstants.baseURL
        let urlString = baseURL + endpoint.path
        return URL(string: urlString)
    }

    private func handleStatusCode(_ statusCode: Int, data: Data) throws {
        switch statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            let message = parseErrorMessage(from: data) ?? "Server error"
            throw NetworkError.serverError(statusCode, message)
        default:
            let message = parseErrorMessage(from: data) ?? "Unknown error"
            throw NetworkError.serverError(statusCode, message)
        }
    }

    private func parseErrorMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String {
            return message
        }
        return nil
    }

    // MARK: - Logging

    private func logRequest<T: Encodable>(_ request: URLRequest, body: T?) {
        print("🌐 [NetworkManager] Request:")
        print("   URL: \(request.url?.absoluteString ?? "nil")")
        print("   Method: \(request.httpMethod ?? "nil")")
        print("   Headers: \(request.allHTTPHeaderFields ?? [:])")

        if let body = body {
            if let jsonData = try? JSONEncoder().encode(body),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("   Body: \(jsonString)")
            }
        }
    }

    private func logResponse(_ response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 [NetworkManager] Response:")
            print("   Status Code: \(httpResponse.statusCode)")

            if let jsonString = String(data: data, encoding: .utf8) {
                print("   Data: \(jsonString)")
            }
        }
    }
}

// MARK: - SSL Bypass Delegate (Development Only)

/// URLSessionDelegate to bypass SSL certificate validation for localhost development
/// ⚠️ WARNING: This should ONLY be used in development environment!
private class SSLBypassDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Only bypass SSL for localhost in development
        #if DEBUG
        if challenge.protectionSpace.host.contains("localhost") || challenge.protectionSpace.host.contains("127.0.0.1") {
            print("⚠️ [NetworkManager] Bypassing SSL validation for localhost (Development mode)")
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
            return
        }
        #endif

        // For production or non-localhost, use default handling
        completionHandler(.performDefaultHandling, nil)
    }
}
