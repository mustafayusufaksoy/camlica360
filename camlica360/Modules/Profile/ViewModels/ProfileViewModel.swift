import SwiftUI

/// ViewModel for profile view
@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var personnelInfo: PersonnelDetailDto?
    @Published var isLoading: Bool = false
    @Published var error: String?

    // MARK: - Properties

    private let personnelService = PersonnelService.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    private let authService = AuthService.shared

    // MARK: - Initialization

    init() {
        loadProfileData()
    }

    // MARK: - Public Methods

    /// Load profile data from backend
    func loadProfileData() {
        // Get userId from saved UserInfo
        guard let userInfo = userDefaultsManager.getUserInfo() else {
            error = "Kullanıcı bilgisi bulunamadı"
            print("❌ [ProfileViewModel] No user info found")
            return
        }

        Task {
            isLoading = true
            error = nil

            do {
                let personnel = try await personnelService.getPersonnelById(userId: userInfo.userId)
                self.personnelInfo = personnel
                print("✅ [ProfileViewModel] Profile data loaded: \(personnel.displayName)")
            } catch let networkError as NetworkError {
                self.error = networkError.localizedDescription
                print("❌ [ProfileViewModel] Network error: \(networkError.localizedDescription)")
            } catch {
                self.error = "Profil bilgileri yüklenemedi"
                print("❌ [ProfileViewModel] Error: \(error.localizedDescription)")
            }

            isLoading = false
        }
    }

    /// Logout user
    func logout() {
        do {
            try authService.logout()
            AuthStateManager.shared.logout()
        } catch {
            print("❌ [ProfileViewModel] Logout error: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Methods

    /// Get user initials for avatar
    func getUserInitials() -> String {
        guard let personnel = personnelInfo else { return "?" }
        let first = String(personnel.firstName.prefix(1))
        let last = String(personnel.lastName.prefix(1))
        return "\(first)\(last)".uppercased()
    }

    /// Get blood type display text
    func getBloodTypeDisplay() -> String? {
        guard let bloodType = personnelInfo?.bloodType,
              let rhFactor = personnelInfo?.rhFactor else {
            return nil
        }

        let bloodTypeText = ["A", "B", "AB", "O"][bloodType]
        let rhText = rhFactor == 0 ? "+" : "-"
        return "\(bloodTypeText)\(rhText)"
    }

    /// Get gender display text
    func getGenderDisplay() -> String? {
        guard let gender = personnelInfo?.gender else { return nil }
        return gender == 0 ? "Erkek" : "Kadın"
    }

    /// Get marital status display text
    func getMaritalStatusDisplay() -> String? {
        guard let status = personnelInfo?.maritalStatus else { return nil }
        switch status {
        case 0: return "Bekar"
        case 1: return "Evli"
        case 2: return "Boşanmış"
        default: return nil
        }
    }
}
