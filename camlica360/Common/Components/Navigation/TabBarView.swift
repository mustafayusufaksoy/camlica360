import SwiftUI

/// Reusable tab bar component for navigation with custom design
struct TabBarView: View {
    @Binding var selectedTab: TabItem
    @Binding var showMenu: Bool

    var body: some View {
        HStack(spacing: 21) {
            // All tabs: Home, Menu, Izinler, Profile
            let visibleItems: [TabItem] = [.home, .menu, .izinler, .profile]

            ForEach(visibleItems, id: \.self) { item in
                TabBarButton(
                    item: item,
                    isSelected: selectedTab == item,
                    action: {
                        if item == .menu {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMenu = true
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = item
                            }
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 75)
        .background(AppColors.white)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
    }
}

/// Individual tab bar button with custom styling
struct TabBarButton: View {
    let item: TabItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: item.icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : Color(hex: "9DB2CE"))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? AppColors.primary : Color.clear)
                .cornerRadius(16)
        }
    }
}

// MARK: - Preview

#Preview {
    TabBarView(selectedTab: .constant(.home), showMenu: .constant(false))
}
