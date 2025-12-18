import SwiftUI

struct AttendanceView: View {
    @StateObject private var viewModel = AttendanceViewModel()
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: AppSpacing.md) {
                    // Header
                    VStack(spacing: AppSpacing.xs) {
                        Text("attendance_title".localized)
                            .font(AppFonts.custom(size: 28, weight: .bold))
                            .foregroundColor(AppColors.primary)

                        Text("attendance_subtitle".localized)
                            .font(AppFonts.custom(size: 14, weight: .regular))
                            .foregroundColor(AppColors.neutral600)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.md)

                    // Location Status Card
                    LocationStatusCard(
                        isInsideGeofence: viewModel.isInsideGeofence,
                        currentLocation: viewModel.currentWorkplaceLocation,
                        locationStatus: viewModel.locationStatus
                    )
                    .padding(.horizontal, AppSpacing.md)

                    // Check-in/Check-out Buttons
                    CheckInOutButtonsView(
                        isInsideGeofence: viewModel.isInsideGeofence,
                        isLoading: viewModel.isLoading,
                        lastEventType: viewModel.lastEventType,
                        onCheckIn: {
                            Task {
                                await viewModel.manualCheckIn()
                            }
                        },
                        onCheckOut: {
                            Task {
                                await viewModel.manualCheckOut()
                            }
                        }
                    )
                    .padding(.horizontal, AppSpacing.md)

                    // Pending Logs Alert
                    if viewModel.pendingLogsCount > 0 {
                        PendingLogsCard(
                            count: viewModel.pendingLogsCount,
                            isLoading: viewModel.isLoading,
                            onSync: {
                                Task {
                                    await viewModel.syncPendingLogs()
                                }
                            }
                        )
                        .padding(.horizontal, AppSpacing.md)
                    }

                    // Today's Logs
                    if !viewModel.todaysLogs.isEmpty {
                        TodaysLogsCard(logs: viewModel.todaysLogs)
                            .padding(.horizontal, AppSpacing.md)
                    }

                    Spacer()

                    // Action Buttons
                    HStack(spacing: AppSpacing.sm) {
                        NavigationLink(destination: AttendanceHistoryView()) {
                            HStack {
                                Image(systemName: "clock.fill")
                                Text("view_history".localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(AppSpacing.md)
                            .background(AppColors.neutral600)
                            .foregroundColor(.white)
                            .cornerRadius(AppSpacing.xs)
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.md)
                }
            }
            .onAppear {
                Task {
                    await viewModel.startAttendanceTracking()
                }
            }
            .onDisappear {
                viewModel.stopAttendanceTracking()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        await viewModel.startAttendanceTracking()
                    }
                } else if newPhase == .background {
                    // Allow geofencing to continue in background
                }
            }
            .alert("error_title".localized, isPresented: $viewModel.showError) {
                Button("ok".localized, role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "unknown_error".localized)
            }
        }
    }
}

// MARK: - Location Status Card

struct LocationStatusCard: View {
    let isInsideGeofence: Bool
    let currentLocation: WorkplaceLocation?
    let locationStatus: String

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("location_status".localized)
                        .font(AppFonts.custom(size: 14, weight: .bold))
                        .foregroundColor(AppColors.neutral600)

                    if isInsideGeofence, let location = currentLocation {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.green)
                                Text(location.name)
                                    .font(AppFonts.custom(size: 16, weight: .medium))
                            }
                            Text(location.address)
                                .font(AppFonts.custom(size: 12, weight: .regular))
                                .foregroundColor(AppColors.neutral600)
                        }
                    } else {
                        HStack {
                            Image(systemName: "location.slash")
                                .foregroundColor(.red)
                            Text("not_in_workplace".localized)
                                .font(AppFonts.custom(size: 16, weight: .medium))
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.xs)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.xs)
                .stroke(
                    isInsideGeofence ? Color.green.opacity(0.5) : Color.red.opacity(0.5),
                    lineWidth: 2
                )
        )
    }
}

// MARK: - Check-in/Check-out Buttons

struct CheckInOutButtonsView: View {
    let isInsideGeofence: Bool
    let isLoading: Bool
    let lastEventType: AttendanceEventType?
    let onCheckIn: () -> Void
    let onCheckOut: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                Button(action: onCheckIn) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("check_in".localized)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.md)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(AppSpacing.xs)
                    .opacity(isInsideGeofence ? 1.0 : 0.5)
                }
                .disabled(!isInsideGeofence || isLoading)

                Button(action: onCheckOut) {
                    HStack {
                        Image(systemName: "arrow.left.circle.fill")
                        Text("check_out".localized)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.md)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(AppSpacing.xs)
                    .opacity(isInsideGeofence ? 1.0 : 0.5)
                }
                .disabled(!isInsideGeofence || isLoading)
            }

            if isLoading {
                ProgressView()
                    .tint(AppColors.primary)
            }

            if let lastEvent = lastEventType {
                Text("last_event: \(lastEvent.displayName)")
                    .font(AppFonts.custom(size: 12, weight: .regular))
                    .foregroundColor(AppColors.neutral600)
            }
        }
    }
}

// MARK: - Pending Logs Card

struct PendingLogsCard: View {
    let count: Int
    let isLoading: Bool
    let onSync: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading) {
                        Text("pending_logs".localized)
                            .font(AppFonts.custom(size: 14, weight: .medium))
                        Text(String(format: "pending_logs_count".localized, count))
                            .font(AppFonts.custom(size: 12, weight: .regular))
                            .foregroundColor(AppColors.neutral600)
                    }
                }
                Spacer()
                Button(action: onSync) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("sync".localized)
                            .font(AppFonts.custom(size: 12, weight: .medium))
                    }
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColors.primary)
                .foregroundColor(.white)
                .cornerRadius(AppSpacing.xs)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(AppSpacing.xs)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.xs)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Today's Logs Card

struct TodaysLogsCard: View {
    let logs: [AttendanceLog]

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text("todays_logs".localized)
                    .font(AppFonts.custom(size: 14, weight: .bold))
                Spacer()
                Text("\(logs.count) entries")
                    .font(AppFonts.custom(size: 12, weight: .regular))
                    .foregroundColor(AppColors.neutral600)
            }

            VStack(spacing: AppSpacing.xs) {
                ForEach(logs.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5)) { log in
                    LogEntryRow(log: log)
                        .padding(.vertical, AppSpacing.xs)
                        .borderBottom(color: AppColors.neutral200, width: 0.5)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.xs)
    }
}

// MARK: - Log Entry Row

struct LogEntryRow: View {
    let log: AttendanceLog

    var body: some View {
        HStack {
            Image(systemName: log.eventType == .checkIn ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                .foregroundColor(log.eventType == .checkIn ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.eventType.displayName)
                    .font(AppFonts.custom(size: 13, weight: .medium))
                Text(log.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(AppFonts.custom(size: 11, weight: .regular))
                    .foregroundColor(AppColors.neutral600)
            }

            Spacer()

            if !log.isSynced {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - View Extension for Border

extension View {
    func borderBottom(color: Color = .gray, width: CGFloat = 1) -> some View {
        VStack {
            self
            Divider()
                .foregroundColor(color)
        }
    }
}

#Preview {
    AttendanceView()
}
