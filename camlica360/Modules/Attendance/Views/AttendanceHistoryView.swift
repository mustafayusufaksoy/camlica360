import SwiftUI

struct AttendanceHistoryView: View {
    @StateObject private var viewModel = AttendanceHistoryViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: AppSpacing.md) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("back".localized)
                            }
                            .foregroundColor(AppColors.primary)
                        }
                        Spacer()
                        Text("attendance_history".localized)
                            .font(AppFonts.bold(size: 18))
                        Spacer()
                        Image(systemName: "chevron.left")
                            .opacity(0) // For spacing
                    }
                    .padding(.horizontal, AppSpacing.md)

                    // Date Range Picker
                    Picker("date_range".localized, selection: $viewModel.selectedDateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppSpacing.md)
                    .onChange(of: viewModel.selectedDateRange) { _, newValue in
                        viewModel.selectDateRange(newValue)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, AppSpacing.lg)
                    } else if viewModel.dailySummaries.isEmpty {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "calendar")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.secondary)
                            Text("no_logs_found".localized)
                                .font(AppFonts.medium(size: 16))
                                .foregroundColor(AppColors.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        // Daily Summaries List
                        ScrollView {
                            VStack(spacing: AppSpacing.md) {
                                ForEach(viewModel.dailySummaries) { summary in
                                    DailySummaryCard(summary: summary)
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)
                        }
                    }

                    Spacer()
                }
            }
            .onAppear {
                viewModel.loadLogs()
            }
            .alert("error_title".localized, isPresented: $viewModel.showError) {
                Button("ok".localized, role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "unknown_error".localized)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Daily Summary Card

struct DailySummaryCard: View {
    let summary: DailySummary
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(summary.dateString)
                        .font(AppFonts.bold(size: 16))
                    Text(summary.statusString)
                        .font(AppFonts.regular(size: 12))
                        .foregroundColor(AppColors.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text(summary.workingHoursString)
                        .font(AppFonts.bold(size: 16))
                    Text("working_hours".localized)
                        .font(AppFonts.regular(size: 11))
                        .foregroundColor(AppColors.secondary)
                }

                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.primary)
                }
                .padding(.leading, AppSpacing.sm)
            }
            .padding(AppSpacing.md)

            // Details (if expanded)
            if isExpanded {
                Divider()
                    .padding(.horizontal, AppSpacing.md)

                VStack(spacing: AppSpacing.sm) {
                    // Check-in time
                    if let firstCheckIn = summary.firstCheckIn {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.green)
                            Text("first_check_in".localized)
                            Spacer()
                            Text(firstCheckIn.formatted(date: .omitted, time: .shortened))
                                .font(AppFonts.medium(size: 13))
                        }
                        .font(AppFonts.regular(size: 13))
                        .padding(.vertical, AppSpacing.xs)
                    }

                    // Check-out time
                    if let lastCheckOut = summary.lastCheckOut {
                        HStack {
                            Image(systemName: "arrow.left.circle.fill")
                                .foregroundColor(.red)
                            Text("last_check_out".localized)
                            Spacer()
                            Text(lastCheckOut.formatted(date: .omitted, time: .shortened))
                                .font(AppFonts.medium(size: 13))
                        }
                        .font(AppFonts.regular(size: 13))
                        .padding(.vertical, AppSpacing.xs)
                    }

                    // Total events
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(AppColors.primary)
                        Text("total_events".localized)
                        Spacer()
                        Text("\(summary.checkInCount + summary.checkOutCount)")
                            .font(AppFonts.medium(size: 13))
                    }
                    .font(AppFonts.regular(size: 13))
                    .padding(.vertical, AppSpacing.xs)

                    // Log entries
                    if !summary.logs.isEmpty {
                        Divider()
                            .padding(.vertical, AppSpacing.xs)

                        VStack(spacing: AppSpacing.xs) {
                            Text("all_entries".localized)
                                .font(AppFonts.bold(size: 12))
                                .foregroundColor(AppColors.secondary)

                            ForEach(summary.logs) { log in
                                LogEntryRow(log: log)
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                }
                .padding(AppSpacing.md)
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.xs)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.xs)
                .stroke(AppColors.border, lineWidth: 0.5)
        )
    }
}

#Preview {
    AttendanceHistoryView()
}
