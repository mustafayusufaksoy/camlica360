import SwiftUI

/// ViewModel for home view
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var userName: String = "Kullanıcı"
    @Published var userRole: String = ""
    @Published var selectedTab: TabItem = .home
    @Published var userInfo: UserInfo?
    @Published var isLoadingUserData: Bool = false

    // MARK: - Properties

    private let userDefaultsManager = UserDefaultsManager.shared
    private let keychainManager = KeychainManager.shared
    private let personnelService = PersonnelService.shared

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

            // If still showing "Kullanıcı", try to fetch from API
            if userName == "Kullanıcı" {
                Task {
                    await fetchUserDetailsFromAPI()
                }
            }
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

            // If still showing "Kullanıcı", try to fetch from API
            if userName == "Kullanıcı" {
                Task {
                    await fetchUserDetailsFromAPI()
                }
            }
        } else {
            print("❌ [HomeViewModel] Could not load or extract user info")
            // Last resort: fetch from API
            Task {
                await fetchUserDetailsFromAPI()
            }
        }
    }

    /// Fetch user details from Personnel API
    private func fetchUserDetailsFromAPI() async {
        isLoadingUserData = true

        do {
            guard let userId = userInfo?.userId else {
                print("❌ [HomeViewModel] No userId available")
                isLoadingUserData = false
                return
            }

            print("🔍 [HomeViewModel] Fetching user details from API for userId: \(userId)")
            let personnelDetails = try await personnelService.getPersonnelById(userId: userId)

            // Update user name from API
            let firstName = personnelDetails.firstName ?? ""
            let lastName = personnelDetails.lastName ?? ""
            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)

            if !fullName.isEmpty {
                self.userName = fullName
                self.userRole = personnelDetails.position ?? personnelDetails.title ?? ""
                print("✅ [HomeViewModel] User details fetched from API: \(userName)")

                // Update UserInfo and save
                if var updatedUserInfo = userInfo {
                    updatedUserInfo = UserInfo(
                        userId: updatedUserInfo.userId,
                        fullName: fullName,
                        email: personnelDetails.personalEmail ?? updatedUserInfo.email,
                        companyCode: updatedUserInfo.companyCode,
                        companyId: updatedUserInfo.companyId,
                        avatarUrl: personnelDetails.avatarUrl ?? updatedUserInfo.avatarUrl,
                        logoUrl: updatedUserInfo.logoUrl,
                        isCompanyRepresentative: updatedUserInfo.isCompanyRepresentative
                    )
                    userDefaultsManager.saveUserInfo(updatedUserInfo)
                    self.userInfo = updatedUserInfo
                }
            }
        } catch {
            print("❌ [HomeViewModel] Failed to fetch user details: \(error)")
        }

        isLoadingUserData = false
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
