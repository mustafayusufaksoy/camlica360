import Foundation

/// JWT Token Helper for decoding access tokens
class JWTHelper {
    // MARK: - Singleton

    static let shared = JWTHelper()

    private init() {}

    // MARK: - Public Methods

    /// Decode JWT token and extract claims
    /// - Parameter token: JWT token string
    /// - Returns: Dictionary of claims or nil if decoding fails
    func decodeToken(_ token: String) -> [String: Any]? {
        let segments = token.components(separatedBy: ".")

        guard segments.count > 1 else {
            print("❌ [JWTHelper] Invalid token format")
            return nil
        }

        // JWT structure: header.payload.signature
        // We need the payload (index 1)
        let payloadSegment = segments[1]

        guard let decodedData = base64UrlDecode(payloadSegment) else {
            print("❌ [JWTHelper] Failed to decode base64")
            return nil
        }

        do {
            let json = try JSONSerialization.jsonObject(with: decodedData, options: [])
            guard let claims = json as? [String: Any] else {
                print("❌ [JWTHelper] Invalid JSON structure")
                return nil
            }

            // Debug logging (disabled for production)
            // Uncomment below lines for debugging:
            // print("✅ [JWTHelper] Token decoded successfully")
            // print("🔍 [JWTHelper] All claims in token:")
            // for (key, value) in claims {
            //     print("   - \(key): \(value)")
            // }
            return claims
        } catch {
            print("❌ [JWTHelper] JSON parsing error: \(error)")
            return nil
        }
    }

    /// Check if token is expired
    /// - Parameter token: JWT token string
    /// - Returns: True if expired, false otherwise
    func isTokenExpired(_ token: String) -> Bool {
        guard let claims = decodeToken(token),
              let exp = claims["exp"] as? TimeInterval else {
            return true
        }

        let expirationDate = Date(timeIntervalSince1970: exp)
        return expirationDate < Date()
    }

    /// Get user ID from token
    /// - Parameter token: JWT token string
    /// - Returns: User ID or nil
    func getUserId(from token: String) -> String? {
        guard let claims = decodeToken(token) else {
            return nil
        }

        // Try different claim names based on backend response
        // Priority: nameid (short) -> nameid (full URI) -> userId -> sub

        // 1. Try short claim name first (temp token uses this)
        if let nameid = claims["nameid"] as? String {
            return nameid
        }

        // 2. Try full URI (access token uses this)
        if let nameid = claims["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"] as? String {
            return nameid
        }

        // 3. Try userId field
        if let userId = claims["userId"] as? String {
            return userId
        }

        // 4. Last resort: sub (only if not encrypted)
        if let sub = claims["sub"] as? String, sub.count < 128 {
            return sub
        }

        return nil
    }

    /// Get user full name from token
    /// - Parameter token: JWT token string
    /// - Returns: Full name or nil
    func getFullName(from token: String) -> String? {
        guard let claims = decodeToken(token) else {
            return nil
        }

        // Try different claim names
        // Priority: unique_name (short) -> full URI -> fullName

        // 1. Try short claim name first (temp token uses this)
        if let fullName = claims["unique_name"] as? String {
            return fullName
        }

        // 2. Try full URI (access token might use this)
        if let fullName = claims["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"] as? String {
            return fullName
        }

        // 3. Try fullName field
        if let fullName = claims["fullName"] as? String {
            return fullName
        }

        return nil
    }

    /// Get company code from token
    /// - Parameter token: JWT token string
    /// - Returns: Company code or nil
    func getCompanyCode(from token: String) -> String? {
        guard let claims = decodeToken(token) else {
            return nil
        }

        return claims["companyCode"] as? String
    }

    /// Get avatar URL from token
    /// - Parameter token: JWT token string
    /// - Returns: Avatar URL or nil
    func getAvatarUrl(from token: String) -> String? {
        guard let claims = decodeToken(token) else {
            return nil
        }

        return claims["avatarUrl"] as? String
    }

    /// Get logo URL from token
    /// - Parameter token: JWT token string
    /// - Returns: Logo URL or nil
    func getLogoUrl(from token: String) -> String? {
        guard let claims = decodeToken(token) else {
            return nil
        }

        return claims["logoUrl"] as? String
    }

    /// Check if user is company representative
    /// - Parameter token: JWT token string
    /// - Returns: True if company representative
    func isCompanyRepresentative(from token: String) -> Bool {
        guard let claims = decodeToken(token) else {
            return false
        }

        if let isRep = claims["isCompanyRepresentative"] as? String {
            return isRep.lowercased() == "true"
        }

        if let isRep = claims["isCompanyRepresentative"] as? Bool {
            return isRep
        }

        return false
    }

    // MARK: - Private Methods

    /// Decode base64url encoded string
    /// - Parameter base64UrlString: Base64url encoded string
    /// - Returns: Decoded data or nil
    private func base64UrlDecode(_ base64UrlString: String) -> Data? {
        var base64 = base64UrlString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 = base64.padding(toLength: base64.count + 4 - remainder,
                                    withPad: "=",
                                    startingAt: 0)
        }

        return Data(base64Encoded: base64)
    }
}
