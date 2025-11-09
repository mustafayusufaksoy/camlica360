import Foundation

/// Tab bar item model
enum TabItem: Int, CaseIterable {
    case home = 0
    case menu = 1
    case reports = 2
    case messages = 3
    case notifications = 4
    case profile = 5
    case izinler = 6

    // MARK: - Properties

    var title: String {
        switch self {
        case .home:
            return LocalizationKeys.tabHome.localized
        case .menu:
            return "Menü"
        case .reports:
            return LocalizationKeys.tabReports.localized
        case .messages:
            return LocalizationKeys.tabMessages.localized
        case .notifications:
            return LocalizationKeys.tabNotifications.localized
        case .profile:
            return LocalizationKeys.tabProfile.localized
        case .izinler:
            return "İzinler"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .menu:
            return "line.3.horizontal"
        case .reports:
            return "chart.bar.fill"
        case .messages:
            return "bubble.left.fill"
        case .notifications:
            return "bell.fill"
        case .profile:
            return "person.fill"
        case .izinler:
            return "calendar" // Using system icon for permissions
        }
    }
}
