import SwiftUI

/// Leave requests table section with filters and actions
struct LeaveRequestsSection: View {
    let requests: [LeaveRequest]

    @State private var showFilter: Bool = false
    @State private var showCreateForm: Bool = false
    @State private var showDetailModal: Bool = false
    @State private var selectedRequest: LeaveRequest?
    @State private var currentPage: Int = 1
    let itemsPerPage: Int = 10

    private var totalPages: Int {
        max(1, Int(ceil(Double(requests.count) / Double(itemsPerPage))))
    }

    private var paginatedRequests: [LeaveRequest] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, requests.count)
        guard startIndex < requests.count else { return [] }
        return Array(requests[startIndex..<endIndex])
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Header with filter and create button
            HStack(spacing: AppSpacing.md) {
                // Filter button
                Button(action: {
                    showFilter.toggle()
                }) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 16))
                        Text("Filtrele")
                            .font(AppFonts.xsRegular)
                    }
                    .foregroundColor(AppColors.neutral700)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.white)
                    .cornerRadius(AppSpacing.radiusSm)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusSm)
                            .stroke(AppColors.neutral200, lineWidth: 1)
                    )
                }

                Spacer()

                // Create button
                Button(action: {
                    showCreateForm = true
                }) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("İzin Talep Oluştur")
                            .font(AppFonts.xsRegular)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.primary600)
                    .cornerRadius(AppSpacing.radiusSm)
                }
            }

            // Table
            leaveRequestsTable

            // Pagination
            paginationView
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.radiusMd)
        .fullScreenCover(isPresented: $showCreateForm) {
            CreateLeaveRequestView()
        }
        .sheet(isPresented: $showDetailModal) {
            if let request = selectedRequest {
                LeaveRequestDetailView(request: request)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Table

    private var leaveRequestsTable: some View {
        let columns = [
            TableColumn(title: "İzin Türü", key: "type", width: 150),
            TableColumn(title: "Süre", key: "duration", width: 80),
            TableColumn(title: "Başlangıç Tarihi", key: "startDate", width: 120),
            TableColumn(title: "Bitiş Tarihi", key: "endDate", width: 120),
            TableColumn(title: "Açıklama", key: "description", width: 120),
            TableColumn(title: "Onay Durumu", key: "status", width: 150)
        ]

        return ScrollView(.horizontal, showsIndicators: false) {
            DataTable(columns: columns, data: paginatedRequests) { request in
                Button(action: {
                    selectedRequest = request
                    showDetailModal = true
                }) {
                    HStack(spacing: 0) {
                        // Leave Type
                        Text(request.leaveType)
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral700)
                            .frame(width: 150, alignment: .leading)
                            .padding(.horizontal, AppSpacing.sm)

                        Divider()

                        // Duration
                        Text(request.duration)
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral700)
                            .frame(width: 80, alignment: .leading)
                            .padding(.horizontal, AppSpacing.sm)

                        Divider()

                        // Start Date
                        Text(request.startDate)
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral700)
                            .frame(width: 120, alignment: .leading)
                            .padding(.horizontal, AppSpacing.sm)

                        Divider()

                        // End Date
                        Text(request.endDate)
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral700)
                            .frame(width: 120, alignment: .leading)
                            .padding(.horizontal, AppSpacing.sm)

                        Divider()

                        // Description
                        Text(request.description)
                            .font(AppFonts.xsRegular)
                            .foregroundColor(AppColors.neutral700)
                            .lineLimit(1)
                            .frame(width: 120, alignment: .leading)
                            .padding(.horizontal, AppSpacing.sm)

                        Divider()

                        // Status badge
                        HStack(spacing: AppSpacing.sm) {
                            Text(request.status.title)
                                .font(AppFonts.xsRegular)
                                .foregroundColor(request.status.color)
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, 4)
                                .background(request.status.backgroundColor)
                                .cornerRadius(4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.neutral400)
                        }
                        .frame(width: 150, alignment: .leading)
                        .padding(.horizontal, AppSpacing.sm)
                    }
                    .padding(.vertical, AppSpacing.md)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Pagination

    private var paginationView: some View {
        HStack {
            // Info
            Text("Sayfa: \(itemsPerPage) kaydın \(min(currentPage * itemsPerPage, requests.count))")
                .font(AppFonts.xsRegular)
                .foregroundColor(AppColors.neutral600)

            Spacer()

            // Page numbers
            HStack(spacing: AppSpacing.xs) {
                // Previous
                Button(action: {
                    if currentPage > 1 {
                        currentPage -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10))
                        .foregroundColor(currentPage > 1 ? AppColors.neutral700 : AppColors.neutral400)
                }
                .disabled(currentPage == 1)

                // Page buttons
                ForEach(1...min(5, totalPages), id: \.self) { page in
                    Button(action: {
                        currentPage = page
                    }) {
                        Text("\(page)")
                            .font(AppFonts.xsRegular)
                            .foregroundColor(currentPage == page ? .white : AppColors.neutral700)
                            .frame(width: 24, height: 24)
                            .background(currentPage == page ? AppColors.primary600 : Color.clear)
                            .cornerRadius(4)
                    }
                }

                if totalPages > 5 {
                    Text("...")
                        .font(AppFonts.xsRegular)
                        .foregroundColor(AppColors.neutral600)

                    Text("\(totalPages)")
                        .font(AppFonts.xsRegular)
                        .foregroundColor(AppColors.neutral700)
                }

                // Next
                Button(action: {
                    if currentPage < totalPages {
                        currentPage += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(currentPage < totalPages ? AppColors.neutral700 : AppColors.neutral400)
                }
                .disabled(currentPage == totalPages)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleRequests = [
        LeaveRequest(leaveType: "Doğum/Evlilik İzni", duration: "10 gün", startDate: "28/07/2025 - 09:00", endDate: "30/07/2025 - 18:00", description: "Lorem ipsum dolor sit amet", status: .pending, attachments: ["document.pdf"]),
        LeaveRequest(leaveType: "Hastalık İzni", duration: "2 gün", startDate: "28/07/2025 - 09:00", endDate: "30/07/2025 - 18:00", description: "Lorem ipsum dolor sit amet", status: .approved, attachments: ["rapor.pdf"]),
        LeaveRequest(leaveType: "Doğum/Evlilik İzni", duration: "10 gün", startDate: "28/07/2025 - 09:00", endDate: "30/07/2025 - 18:00", description: "Lorem ipsum dolor sit amet", status: .rejected, attachments: []),
        LeaveRequest(leaveType: "Hastalık İzni", duration: "2 gün", startDate: "28/07/2025 - 09:00", endDate: "30/07/2025 - 18:00", description: "Lorem ipsum dolor sit amet", status: .normal, attachments: []),
        LeaveRequest(leaveType: "Doğum/Evlilik İzni", duration: "10 gün", startDate: "28/07/2025 - 09:00", endDate: "30/07/2025 - 18:00", description: "Lorem ipsum dolor sit amet", status: .pending, attachments: []),
        LeaveRequest(leaveType: "Hastalık İzni", duration: "2 gün", startDate: "28/07/2025 - 09:00", endDate: "30/07/2025 - 18:00", description: "Lorem ipsum dolor sit amet", status: .approved, attachments: []),
        LeaveRequest(leaveType: "Savunma", duration: "8 gün", startDate: "28/07/2025 - 09:00", endDate: "30/07/2025 - 18:00", description: "Lorem ipsum dolor sit amet", status: .normal, attachments: [])
    ]

    return LeaveRequestsSection(requests: sampleRequests)
        .padding()
        .background(AppColors.background)
}
