import SwiftUI

/// Home view - main dashboard
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showMenu: Bool = false

    var body: some View {
        BaseLayout(showMenu: $showMenu, selectedTab: $viewModel.selectedTab) {
            headerTrailingContent
        } content: {
            VStack(spacing: 0) {
                // Content based on selected tab
                Group {
                    switch viewModel.selectedTab {
                    case .home:
                        homeContent
                    case .izinler:
                        IzinlerView()
                    case .profile:
                        profileContent
                    default:
                        placeholderContent
                    }
                }

                // Tab bar
                TabBarView(selectedTab: $viewModel.selectedTab, showMenu: $showMenu)
            }
        }
    }

    // MARK: - Header Content

    @ViewBuilder
    private var headerTrailingContent: some View {
        switch viewModel.selectedTab {
        case .izinler:
            Text("İzinler")
                .font(AppFonts.smMedium)
                .foregroundColor(AppColors.black)
        default:
            EmptyView()
        }
    }

    // MARK: - Content Views

    private var homeContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                // User profile section
                profileSection

                // Chart placeholder sections
                //chartPlaceholderSection

                Spacer()
            }
            .padding(AppSpacing.lg)
        }
    }

    private var profileContent: some View {
        ProfileView()
    }

    private var placeholderContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                Text("Bu sayfa henüz hazır değil")
                    .font(AppFonts.smRegular)
                    .foregroundColor(AppColors.neutral600)
                    .padding(AppSpacing.lg)
            }
        }
    }

    // MARK: - Subviews

    private var profileSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // User card
            HStack(spacing: AppSpacing.lg) {
                // Profile picture with initials
                Circle()
                    .fill(AppColors.primary950.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(viewModel.getUserInitials())
                            .font(AppFonts.custom(size: 20, weight: .bold))
                            .foregroundColor(AppColors.primary950)
                    )

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(viewModel.userName)
                        .font(AppFonts.smMedium)
                        .foregroundColor(AppColors.black)

                    if !viewModel.userRole.isEmpty {
                        Text(viewModel.userRole)
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral600)
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.radiusMd)
        }
    }

    private var chartPlaceholderSection: some View {
        VStack(spacing: AppSpacing.lg) {
            // Chart placeholder 1
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Text("Grafik 1")
                        .font(AppFonts.smMedium)
                        .foregroundColor(AppColors.black)
                    Spacer()
                    Text("Sonradan Eklenecek")
                        .font(AppFonts.xsRegular)
                        .foregroundColor(AppColors.neutral600)
                }

                RoundedRectangle(cornerRadius: AppSpacing.radiusMd)
                    .fill(AppColors.neutral200.opacity(0.5))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.neutral500)
                            Text("Chart Placeholder")
                                .font(AppFonts.smRegular)
                                .foregroundColor(AppColors.neutral500)
                        }
                    )
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)

            // Chart placeholder 2
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Text("Grafik 2")
                        .font(AppFonts.smMedium)
                        .foregroundColor(AppColors.black)
                    Spacer()
                    Text("Sonradan Eklenecek")
                        .font(AppFonts.xsRegular)
                        .foregroundColor(AppColors.neutral600)
                }

                RoundedRectangle(cornerRadius: AppSpacing.radiusMd)
                    .fill(AppColors.neutral200.opacity(0.5))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.neutral500)
                            Text("Chart Placeholder")
                                .font(AppFonts.smRegular)
                                .foregroundColor(AppColors.neutral500)
                        }
                    )
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
        }
    }
}

// MARK: - Stat Card Component

private struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let change: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)

                Spacer()

                Text(change)
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral600)
            }

            Text(value)
                .font(AppFonts.smMedium)
                .foregroundColor(AppColors.black)

            Text(title)
                .font(AppFonts.xsRegular)
                .foregroundColor(AppColors.neutral600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColors.white)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
