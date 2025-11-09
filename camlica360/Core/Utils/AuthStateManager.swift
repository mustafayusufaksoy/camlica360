import SwiftUI

/// Global authentication state manager
/// Manages authentication state across the entire app
class AuthStateManager: ObservableObject {
    // MARK: - Singleton

    static let shared = AuthStateManager()

    // MARK: - Published Properties

    @Published var isAuthenticated: Bool = false

    // MARK: - Properties

    private let authService = AuthService.shared
    private let keychainManager = KeychainManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared

    // MARK: - Initialization

    private init() {
        // Check authentication status on initialization
        checkAuthenticationStatus()
    }

    // MARK: - Public Methods

    /// Check if user is authenticated and restore session if valid token exists
    func checkAuthenticationStatus() {
        let sessionRestored = authService.restoreSession()

        if sessionRestored {
            isAuthenticated = true
            print("✅ Session restored - user is authenticated")

            // Extract user info from token if not already saved
            if userDefaultsManager.getUserInfo() == nil {
                print("⚠️ User info not found, extracting from token...")
                extractUserInfoFromToken()
            }
        } else {
            isAuthenticated = false
            print("ℹ️ No valid session - user needs to login")
        }
    }

    /// Extract user info from saved access token
    private func extractUserInfoFromToken() {
        guard let token = keychainManager.getAccessToken() else {
            print("❌ [AuthStateManager] No access token found")
            return
        }

        if let userInfo = UserInfo.from(token: token) {
            userDefaultsManager.saveUserInfo(userInfo)
            print("✅ [AuthStateManager] User info extracted and saved: \(userInfo.displayName)")
        } else {
            print("❌ [AuthStateManager] Could not extract user info from token")
        }
    }

    /// Set user as authenticated (called after successful login/OTP verification)
    func setAuthenticated() {
        isAuthenticated = true
        print("✅ User authenticated")
    }

    /// Logout user and clear authentication state
    func logout() {
        do {
            try authService.logout()
            isAuthenticated = false
            print("✅ User logged out")
        } catch {
            print("❌ Logout error: \(error.localizedDescription)")
        }
    }
}
