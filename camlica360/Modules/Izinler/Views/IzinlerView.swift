import SwiftUI

/// Izinler view - permissions management with role-based routing
struct IzinlerView: View {
    @StateObject private var roleViewModel = RoleCheckViewModel()

    var body: some View {
        Group {
            if roleViewModel.isLoading {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Yükleniyor...")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            } else if let error = roleViewModel.errorMessage {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.red)

                    Text("Hata")
                        .font(.system(size: 20, weight: .semibold))

                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button("Tekrar Dene") {
                        Task {
                            await roleViewModel.checkRole()
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if let role = roleViewModel.userRole {
                // Show view based on role
                if role.isManager {
                    // Manager view - tabs for employee dashboard and approval queue
                    ManagerTabView(userRole: role)
                } else {
                    // Employee view - dashboard only
                    EmployeeDashboardView()
                }
            } else {
                // No role loaded yet
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Başlatılıyor...")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .task {
            await roleViewModel.checkRole()
        }
    }
}

/// Role check ViewModel
@MainActor
class RoleCheckViewModel: ObservableObject {
    @Published var userRole: PermissionRoleDto?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let izinlerService = IzinlerService.shared
    private let keychainManager = KeychainManager.shared

    func checkRole() async {
        isLoading = true
        errorMessage = nil

        // Check if role is already cached
        if let cachedRole = keychainManager.getUserRole() {
            print("✅ [RoleCheckViewModel] Using cached role: \(cachedRole.roleText)")
            userRole = cachedRole
            isLoading = false
            return
        }

        do {
            let role = try await izinlerService.checkUserRole()

            // Cache role
            _ = keychainManager.saveUserRole(role)

            userRole = role

            print("✅ [RoleCheckViewModel] Role loaded: \(role.roleText)")

        } catch let networkError as NetworkError {
            errorMessage = "Rol bilgisi yüklenirken hata oluştu: \(networkError.localizedDescription)"
            print("❌ [RoleCheckViewModel] Failed to load role: \(networkError)")
        } catch {
            errorMessage = "Rol bilgisi yüklenirken bir hata oluştu. Lütfen tekrar deneyin."
            print("❌ [RoleCheckViewModel] Failed to load role: \(error)")
        }

        isLoading = false
    }
}

/// Manager tab view with employee dashboard and approval queue
struct ManagerTabView: View {
    let userRole: PermissionRoleDto
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Control at top
                Picker("Tab", selection: $selectedTab) {
                    Text("İzinlerim").tag(0)
                    Text("Onay Kuyruğu").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .tint(AppColors.primary) // Use primary color for active tab
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color.white)

                // Content based on selected tab
                TabContent(selectedTab: selectedTab)
            }
            .navigationBarHidden(true)
        }
    }
}

/// Tab content switcher
struct TabContent: View {
    let selectedTab: Int

    var body: some View {
        Group {
            if selectedTab == 0 {
                // Employee Dashboard
                EmployeeDashboardContentView()
            } else {
                // Approval Queue
                ManagerApprovalQueueView()
            }
        }
    }
}

/// Employee dashboard content (without NavigationView wrapper)
struct EmployeeDashboardContentView: View {
    @StateObject private var viewModel = IzinlerViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Monthly chart
                MonthlyChartCard(chartData: viewModel.chartData)

                // Approval status
                ApprovalStatusCard(statusData: viewModel.approvalStatusData)

                // User leaves (horizontal scroll)
                UserLeavesSection(leaveData: viewModel.userLeaveData)

                // Leave requests table
                LeaveRequestsSection(requests: viewModel.leaveRequests)
            }
            .padding(AppSpacing.lg)
        }
    }
}

/// Employee dashboard view (original IzinlerView content)
struct EmployeeDashboardView: View {
    @StateObject private var viewModel = IzinlerViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Monthly chart
                    MonthlyChartCard(chartData: viewModel.chartData)

                    // Approval status
                    ApprovalStatusCard(statusData: viewModel.approvalStatusData)

                    // User leaves (horizontal scroll)
                    UserLeavesSection(leaveData: viewModel.userLeaveData)

                    // Leave requests table
                    LeaveRequestsSection(requests: viewModel.leaveRequests)
                }
                .padding(AppSpacing.lg)
            }
            .navigationTitle("İzinlerim")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview

#Preview {
    IzinlerView()
}
