import SwiftUI

/// Side menu view - slides from right with modern design
struct SideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var selectedTab: TabItem
    @StateObject private var viewModel = HomeViewModel()

    let menuItems = [
        ("home", "Anasayfa", TabItem.home),
        ("document", "İzinler", TabItem.izinler),
        ("user", "Profil", TabItem.profile),
    ]

    var body: some View {
        ZStack {
            if isOpen {
                // Backdrop
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isOpen = false
                        }
                    }

                // Side menu
                HStack(spacing: 0) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 0) {
                        // User profile section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                // Profile circle with initials
                                Circle()
                                    .fill(AppColors.primary.opacity(0.1))
                                    .frame(width: 68, height: 68)
                                    .overlay(
                                        Text(viewModel.getUserInitials())
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(AppColors.primary)
                                    )

                                Spacer()
                            }

                            Text(viewModel.userName)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "0F0F0F"))

                            Text(viewModel.userRole)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "6C7072"))
                        }
                        .padding(.horizontal, 34)
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                        Divider()
                            .background(Color(hex: "E2E4E6"))

                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                // Menu items
                                ForEach(menuItems, id: \.1) { icon, title, tab in
                                    menuItemButton(icon: icon, title: title, tab: tab)
                                }
                            }
                            .padding(.top, 16)
                        }

                        Spacer()

                        // Footer - Logout button
                        VStack(spacing: 0) {
                            Divider()

                            Button(action: {
                                // Logout user
                                AuthStateManager.shared.logout()

                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isOpen = false
                                }
                            }) {
                                HStack(spacing: AppSpacing.md) {
                                    Image(systemName: "arrowshape.left.fill")
                                        .font(.system(size: 16))

                                    Text("Çıkış Yap")
                                        .font(AppFonts.smMedium)

                                    Spacer()
                                }
                                .foregroundColor(Color(hex: "FB2C36"))
                                .padding(AppSpacing.lg)
                            }
                        }
                    }
                    .frame(width: 334)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 30, x: -34, y: 0)
                }
                .transition(.move(edge: .trailing))
            }
        }
    }

    private func menuItemButton(icon: String, title: String, tab: TabItem) -> some View {
        let isActive = selectedTab == tab

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
                isOpen = false
            }
        }) {
            HStack(spacing: 0) {
                // Active indicator (left bar)
                Rectangle()
                    .fill(isActive ? AppColors.primary : Color.clear)
                    .frame(width: 4)

                HStack(spacing: 12) {
                    // Icon
                    if icon.contains(".") {
                        // System icon (e.g., "person.fill")
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(isActive ? AppColors.primary : Color(hex: "0F0F0F"))
                            .frame(width: 24, height: 24)
                    } else {
                        // Asset icon from sidemenü folder
                        Image(icon)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(isActive ? AppColors.primary : Color(hex: "0F0F0F"))
                            .frame(width: 24, height: 24)
                    }

                    Text(title)
                        .font(.system(size: 15))
                        .foregroundColor(isActive ? AppColors.primary : Color(hex: "0F0F0F"))

                    Spacer()
                }
                .padding(.leading, 30)
                .padding(.trailing, 34)
                .padding(.vertical, 11)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SideMenuView(isOpen: .constant(true), selectedTab: .constant(.home))
}
