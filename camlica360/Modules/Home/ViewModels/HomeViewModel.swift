import SwiftUI

/// ViewModel for home view
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var userName: String = "Kullanıcı"
    @Published var userRole: String = ""
    @Published var selectedTab: TabItem = .home
    @Published var userInfo: UserInfo?

    // MARK: - Properties

    private let userDefaultsManager = UserDefaultsManager.shared
    private let keychainManager = KeychainManager.shared

    // MARK: - Initialization

    init() {
        loadUserInfo()
    }

    // MARK: - Public Methods

    /// Load user info from storage
    func loadUserInfo() {
        // First try to load from UserDefaults
        if let savedUserInfo = userDefaultsManager.getUserInfo() {
            self.userInfo = savedUserInfo
            self.userName = savedUserInfo.displayName
            print("✅ [HomeViewModel] User info loaded: \(userName)")
            return
        }

        // If not found, try to extract from token
        print("⚠️ [HomeViewModel] No user info found in storage, extracting from token...")
        if let token = keychainManager.getAccessToken(),
           let extractedUserInfo = UserInfo.from(token: token) {
            self.userInfo = extractedUserInfo
            self.userName = extractedUserInfo.displayName

            // Save for future use
            userDefaultsManager.saveUserInfo(extractedUserInfo)
            print("✅ [HomeViewModel] User info extracted from token: \(userName)")
        } else {
            print("❌ [HomeViewModel] Could not load or extract user info")
        }
    }

    /// Format name for display
    func formattedUserName() -> String {
        return userName
    }

    /// Get user initials for avatar
    func getUserInitials() -> String {
        return userInfo?.initials ?? "?"
    }
}
