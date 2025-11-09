import SwiftUI

/// Base layout wrapper for all pages
/// Provides consistent background, header, sidebar and structure
struct BaseLayout<Content: View, HeaderTrailing: View>: View {
    let content: Content
    let headerTrailing: HeaderTrailing?
    let showHeader: Bool

    @Binding var showMenu: Bool
    @Binding var selectedTab: TabItem

    // User info for profile button
    private let userDefaultsManager = UserDefaultsManager.shared
    private var userInfo: UserInfo? {
        userDefaultsManager.getUserInfo()
    }

    init(
        showHeader: Bool = true,
        showMenu: Binding<Bool>,
        selectedTab: Binding<TabItem>,
        @ViewBuilder headerTrailing: () -> HeaderTrailing? = { nil },
        @ViewBuilder content: () -> Content
    ) {
        self.showHeader = showHeader
        self._showMenu = showMenu
        self._selectedTab = selectedTab
        self.headerTrailing = headerTrailing()
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background color for all pages
            AppColors.background
                .ignoresSafeArea()

            // Page content with header
            VStack(spacing: 0) {
                if showHeader {
                    headerSection
                }

                content
            }

            // Side menu overlay
            SideMenuView(isOpen: $showMenu, selectedTab: $selectedTab)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image("crm-siyah-logo-login")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 38)

                Spacer()

                if let trailing = headerTrailing {
                    trailing
                }

                // Profile button
                ProfileButton(userInfo: userInfo) {
                    handleProfileTap()
                }
            }
            .padding(AppSpacing.lg)

            Divider()
        }
    }

    // MARK: - Actions

    private func handleProfileTap() {
        selectedTab = .profile
        print("✅ [BaseLayout] Profile button tapped, switching to profile tab")
    }
}

// MARK: - Convenience initializer for no trailing content

extension BaseLayout where HeaderTrailing == EmptyView {
    init(
        showHeader: Bool = true,
        showMenu: Binding<Bool>,
        selectedTab: Binding<TabItem>,
        @ViewBuilder content: () -> Content
    ) {
        self.showHeader = showHeader
        self._showMenu = showMenu
        self._selectedTab = selectedTab
        self.headerTrailing = nil
        self.content = content()
    }
}

// MARK: - Preview

#Preview {
    BaseLayout(showMenu: .constant(false), selectedTab: .constant(.home)) {
        VStack {
            Text("Sample Content")
                .font(AppFonts.smMedium)
                .padding()
        }
    }
}

#Preview("With Trailing") {
    BaseLayout(showMenu: .constant(false), selectedTab: .constant(.izinler)) {
        Text("Yıl içi izinler")
            .font(AppFonts.smMedium)
            .foregroundColor(AppColors.black)
    } content: {
        VStack {
            Text("Sample Content")
                .font(AppFonts.smMedium)
                .padding()
        }
    }
}
