import Foundation

/// UserDefaults Manager for app preferences
class UserDefaultsManager {
    // MARK: - Singleton

    static let shared = UserDefaultsManager()

    // MARK: - Keys

    private enum Keys {
        static let rememberMe = "rememberMe"
        static let savedCompanyCode = "savedCompanyCode"
        static let savedIdNumber = "savedIdNumber"
        static let isFirstLaunch = "isFirstLaunch"
        static let userFullName = "userFullName"
        static let userEmail = "userEmail"
        static let userInfo = "userInfo"
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Remember Me

    /// Save remember me preference
    func saveRememberMe(_ remember: Bool) {
        UserDefaults.standard.set(remember, forKey: Keys.rememberMe)
    }

    /// Get remember me preference
    func getRememberMe() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.rememberMe)
    }

    /// Save company code
    func saveCompanyCode(_ code: String) {
        UserDefaults.standard.set(code, forKey: Keys.savedCompanyCode)
    }

    /// Get saved company code
    func getCompanyCode() -> String? {
        return UserDefaults.standard.string(forKey: Keys.savedCompanyCode)
    }

    /// Save ID number
    func saveIdNumber(_ idNumber: String) {
        UserDefaults.standard.set(idNumber, forKey: Keys.savedIdNumber)
    }

    /// Get saved ID number
    func getIdNumber() -> String? {
        return UserDefaults.standard.string(forKey: Keys.savedIdNumber)
    }

    // MARK: - User Info

    /// Save user full name
    func saveUserFullName(_ name: String) {
        UserDefaults.standard.set(name, forKey: Keys.userFullName)
    }

    /// Get user full name
    func getUserFullName() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userFullName)
    }

    /// Save user email
    func saveUserEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: Keys.userEmail)
    }

    /// Get user email
    func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userEmail)
    }

    /// Save complete user info from JWT token
    func saveUserInfo(_ userInfo: UserInfo) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userInfo)
            UserDefaults.standard.set(data, forKey: Keys.userInfo)
            print("✅ [UserDefaultsManager] User info saved")
        } catch {
            print("❌ [UserDefaultsManager] Failed to encode user info: \(error)")
        }
    }

    /// Get saved user info
    func getUserInfo() -> UserInfo? {
        guard let data = UserDefaults.standard.data(forKey: Keys.userInfo) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let userInfo = try decoder.decode(UserInfo.self, from: data)
            return userInfo
        } catch {
            print("❌ [UserDefaultsManager] Failed to decode user info: \(error)")
            return nil
        }
    }

    // MARK: - App State

    /// Check if first launch
    func isFirstLaunch() -> Bool {
        let isFirst = !UserDefaults.standard.bool(forKey: Keys.isFirstLaunch)
        if isFirst {
            UserDefaults.standard.set(true, forKey: Keys.isFirstLaunch)
        }
        return isFirst
    }

    // MARK: - Clear Data

    /// Clear all saved credentials
    func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: Keys.savedCompanyCode)
        UserDefaults.standard.removeObject(forKey: Keys.savedIdNumber)
        UserDefaults.standard.removeObject(forKey: Keys.rememberMe)
    }

    /// Clear all user data
    func clearAll() {
        clearCredentials()
        UserDefaults.standard.removeObject(forKey: Keys.userFullName)
        UserDefaults.standard.removeObject(forKey: Keys.userEmail)
        UserDefaults.standard.removeObject(forKey: Keys.userInfo)
    }
}
