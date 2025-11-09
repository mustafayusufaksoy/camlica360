import Foundation
import Security

/// Keychain Manager for secure data storage
class KeychainManager {
    // MARK: - Singleton

    static let shared = KeychainManager()

    // MARK: - Keys

    private enum Keys {
        static let accessToken = "accessToken"
        static let tempToken = "tempToken"
        static let userId = "userId"
        static let companyCode = "companyCode"
        static let userRole = "userRole"
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Save access token
    func saveAccessToken(_ token: String) -> Bool {
        return save(key: Keys.accessToken, value: token)
    }

    /// Get access token
    func getAccessToken() -> String? {
        return get(key: Keys.accessToken)
    }

    /// Delete access token
    func deleteAccessToken() -> Bool {
        return delete(key: Keys.accessToken)
    }

    /// Save temp token (for 2FA)
    func saveTempToken(_ token: String) -> Bool {
        return save(key: Keys.tempToken, value: token)
    }

    /// Get temp token
    func getTempToken() -> String? {
        return get(key: Keys.tempToken)
    }

    /// Delete temp token
    func deleteTempToken() -> Bool {
        return delete(key: Keys.tempToken)
    }

    /// Save user ID
    func saveUserId(_ userId: String) -> Bool {
        return save(key: Keys.userId, value: userId)
    }

    /// Get user ID
    func getUserId() -> String? {
        return get(key: Keys.userId)
    }

    /// Delete user ID
    func deleteUserId() -> Bool {
        return delete(key: Keys.userId)
    }

    /// Save company code
    func saveCompanyCode(_ code: String) -> Bool {
        return save(key: Keys.companyCode, value: code)
    }

    /// Get company code
    func getCompanyCode() -> String? {
        return get(key: Keys.companyCode)
    }

    /// Delete company code
    func deleteCompanyCode() -> Bool {
        return delete(key: Keys.companyCode)
    }

    /// Save user role
    func saveUserRole(_ role: PermissionRoleDto) -> Bool {
        guard let jsonData = try? JSONEncoder().encode(role),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return false
        }
        return save(key: Keys.userRole, value: jsonString)
    }

    /// Get user role
    func getUserRole() -> PermissionRoleDto? {
        guard let jsonString = get(key: Keys.userRole),
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(PermissionRoleDto.self, from: jsonData)
    }

    /// Delete user role
    func deleteUserRole() -> Bool {
        return delete(key: Keys.userRole)
    }

    /// Clear all keychain data
    func clearAll() -> Bool {
        let tokens = [Keys.accessToken, Keys.tempToken, Keys.userId, Keys.companyCode, Keys.userRole]
        var success = true

        for key in tokens {
            if !delete(key: key) {
                success = false
            }
        }

        return success
    }

    // MARK: - Private Helpers

    private func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
