import SwiftUI

/// Manager approval queue view
struct ManagerApprovalQueueView: View {
    @StateObject private var viewModel = ManagerApprovalQueueViewModel()

    @State private var selectedRequestForApproval: ApprovalQueueRequestDto?
    @State private var showApprovalSheet: Bool = false
    @State private var showRejectionSheet: Bool = false

    // Calculate height for stacked cards
    private func calculateStackHeight(cardCount: Int, hasExpandedCard: Bool) -> CGFloat {
        guard cardCount > 0 else { return 0 }

        let collapsedCardHeight: CGFloat = 120
        let expandedCardHeight: CGFloat = 400
        let cardOffset: CGFloat = 60

        if hasExpandedCard {
            // If one card is expanded, give more height
            return expandedCardHeight + (CGFloat(cardCount - 1) * cardOffset)
        } else {
            // All cards collapsed
            return collapsedCardHeight + (CGFloat(cardCount - 1) * cardOffset)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Background
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Yükleniyor...")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.top, 16)
                    }
                } else if viewModel.pendingRequests.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text("Onay Bekleyen Talep Yok")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Şu anda onayınızı bekleyen izin talebi bulunmamaktadır")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Tab Selector
                            HStack(spacing: 0) {
                                TabButton(
                                    title: "Onay Kuyruğu",
                                    isSelected: viewModel.selectedTab == 0,
                                    action: {
                                        viewModel.selectedTab = 0
                                    }
                                )

                                TabButton(
                                    title: "Geçmiş",
                                    isSelected: viewModel.selectedTab == 1,
                                    action: {
                                        viewModel.selectedTab = 1
                                        Task {
                                            await viewModel.loadApprovalHistory()
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                            // Content based on selected tab
                            if viewModel.selectedTab == 0 {
                                // QUEUE TAB CONTENT
                                // Donut Chart View - Compact horizontal layout
                                HStack(alignment: .center, spacing: 20) {
                                // Chart on the left
                                DonutChartView(
                                    segments: [
                                        ChartSegment(
                                            label: "Bekleyen", value: viewModel.pendingCount,
                                            color: Color.orange),
                                        ChartSegment(
                                            label: "Onaylanan", value: viewModel.approvedCount,
                                            color: Color.green),
                                        ChartSegment(
                                            label: "Reddedilen", value: viewModel.rejectedCount,
                                            color: Color.red),
                                    ],
                                    size: 120,
                                    lineWidth: 20
                                )
                                .padding(.leading, 8)

                                // Legend on the right
                                VStack(alignment: .leading, spacing: 10) {
                                    ChartLegendItem(
                                        label: "Bekleyen", value: viewModel.pendingCount,
                                        color: Color.orange)
                                    ChartLegendItem(
                                        label: "Onaylanan", value: viewModel.approvedCount,
                                        color: Color.green)
                                    ChartLegendItem(
                                        label: "Reddedilen", value: viewModel.rejectedCount,
                                        color: Color.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.primary, lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 8)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                            // Section title for cards
                            HStack {
                                Text("Bekleyen İstekler")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "0F0F0F"))

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                            // Stacked card list (Apple Wallet style) - Only pending requests
                            VStack(spacing: 0) {
                                ZStack(alignment: .top) {
                                    ForEach(Array(viewModel.pendingRequests.enumerated()), id: \.element.id) { index, request in
                                        StackedApprovalCard(
                                            request: request,
                                            index: index,
                                            totalCards: viewModel.pendingRequests.count,
                                            isExpanded: viewModel.expandedCardId == request.id,
                                            onTap: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                    viewModel.expandedCardId = viewModel.expandedCardId == request.id ? nil : request.id
                                                }
                                            },
                                            onApprove: {
                                                selectedRequestForApproval = request
                                                showApprovalSheet = true
                                            },
                                            onReject: {
                                                selectedRequestForApproval = request
                                                showRejectionSheet = true
                                            },
                                            viewModel: viewModel
                                        )
                                    }
                                }
                                .frame(height: calculateStackHeight(
                                    cardCount: viewModel.pendingRequests.count,
                                    hasExpandedCard: viewModel.expandedCardId != nil
                                ))
                                .padding(.horizontal, 16)

                                Spacer(minLength: 100)
                            }
                            } else {
                                // HISTORY TAB CONTENT
                                if viewModel.isLoadingHistory {
                                    VStack {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                        Text("Geçmiş yükleniyor...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                            .padding(.top, 16)
                                    }
                                    .padding(.top, 40)
                                } else if viewModel.approvalHistory.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)

                                        Text("Geçmiş Kayıt Yok")
                                            .font(.system(size: 20, weight: .semibold))

                                        Text("Henüz onaylanmış veya reddedilmiş bir talep bulunmamaktadır")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 32)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    // Section title for history
                                    HStack {
                                        Text("Tüm Talepler")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(hex: "0F0F0F"))

                                        Spacer()

                                        Text("\(viewModel.approvalHistory.count) talep")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)

                                    // History card list - All requests sorted (pending first)
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.sortedApprovalHistory) { request in
                                            HistoryApprovalCard(
                                                request: request,
                                                onTap: {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                        viewModel.expandedCardId = viewModel.expandedCardId == request.id ? nil : request.id
                                                    }
                                                },
                                                isExpanded: viewModel.expandedCardId == request.id,
                                                onApprove: {
                                                    selectedRequestForApproval = request
                                                    showApprovalSheet = true
                                                },
                                                onReject: {
                                                    selectedRequestForApproval = request
                                                    showRejectionSheet = true
                                                },
                                                viewModel: viewModel
                                            )
                                            .padding(.horizontal, 16)
                                        }
                                    }

                                    Spacer(minLength: 100)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showApprovalSheet) {
            if let request = selectedRequestForApproval {
                ApprovalActionSheet(
                    request: request,
                    isApproving: true,
                    viewModel: viewModel,
                    isPresented: $showApprovalSheet
                )
            }
        }
        .sheet(isPresented: $showRejectionSheet) {
            if let request = selectedRequestForApproval {
                ApprovalActionSheet(
                    request: request,
                    isApproving: false,
                    viewModel: viewModel,
                    isPresented: $showRejectionSheet
                )
            }
        }
        .alert("Başarılı", isPresented: $viewModel.showApprovalSuccessAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("İzin talebi başarıyla onaylandı")
        }
        .alert("Başarılı", isPresented: $viewModel.showRejectionSuccessAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("İzin talebi reddedildi")
        }
        .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Tamam", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

/// Stacked approval card with Apple Wallet style
struct StackedApprovalCard: View {
    let request: ApprovalQueueRequestDto
    let index: Int
    let totalCards: Int
    let isExpanded: Bool
    let onTap: () -> Void
    let onApprove: () -> Void
    let onReject: () -> Void
    @ObservedObject var viewModel: ManagerApprovalQueueViewModel

    private var cardOffset: CGFloat {
        if isExpanded {
            return 0
        }
        return CGFloat(index) * 60 // 60pt offset per card for stacked effect
    }

    private var cardScale: CGFloat {
        if isExpanded {
            return 1.0
        }
        return 1.0 - (CGFloat(index) * 0.03) // Slight scale reduction for depth
    }

    private var cardOpacity: Double {
        if isExpanded {
            return 1.0
        }
        // Cards further back are slightly more transparent
        return 1.0 - (Double(index) * 0.1)
    }

    private var statusBorderColor: Color {
        switch request.requestStatus {
        case 0: return .orange
        case 1: return .green
        case 2: return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isExpanded {
                // Expanded view - full card details
                ExpandedApprovalCard(
                    request: request,
                    onApprove: onApprove,
                    onReject: onReject,
                    viewModel: viewModel
                )
            } else {
                // Collapsed view - compact preview
                CollapsedApprovalCard(
                    request: request,
                    viewModel: viewModel
                )
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(statusBorderColor, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .offset(y: cardOffset)
        .zIndex(isExpanded ? 1000 : Double(totalCards - index))
        .onTapGesture {
            onTap()
        }
    }
}

/// Collapsed card preview (minimal info)
struct CollapsedApprovalCard: View {
    let request: ApprovalQueueRequestDto
    @ObservedObject var viewModel: ManagerApprovalQueueViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Üst Kısım - Her Zaman Görünür
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.personnelName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(request.permissionTypeName)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                StatusBadge(status: request.requestStatus)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Tarih Bilgisi - Her Zaman Görünür
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)

                Text("\(viewModel.formatDate(request.startDate)) - \(viewModel.formatDate(request.endDate))")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Spacer()
                .frame(height: 16)
        }
    }
}

/// Expanded card with full details
struct ExpandedApprovalCard: View {
    let request: ApprovalQueueRequestDto
    let onApprove: () -> Void
    let onReject: () -> Void
    @ObservedObject var viewModel: ManagerApprovalQueueViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Üst Kısım - Her Zaman Görünür
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.personnelName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(request.permissionTypeName)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                StatusBadge(status: request.requestStatus)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Tarih Bilgisi - Her Zaman Görünür
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)

                Text("\(viewModel.formatDate(request.startDate)) - \(viewModel.formatDate(request.endDate))")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Genişletilmiş İçerik
            VStack(alignment: .leading, spacing: 12) {
                // Süre
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)

                    Text("\(request.desiredDays) gün")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                // İzin Türü Detayı
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 12))
                        .foregroundColor(.purple)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("İzin Türü:")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(request.permissionTypeName)
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
                    }
                }

                // Açıklama (varsa)
                if let description = request.description, !description.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Açıklama:")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(description)
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                                .lineLimit(3)
                        }
                    }
                }

                // Butonlar (sadece pending requestler için)
                if request.requestStatus == 0 {
                    HStack(spacing: 12) {
                        Button(action: onReject) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Reddet")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Button(action: onApprove) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Onayla")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .transition(.opacity.combined(with: .move(edge: .top)))

            Spacer()
                .frame(height: 16)
        }
    }
}

/// Status badge component
struct StatusBadge: View {
    let status: Int

    var displayText: String {
        PermissionRequestStatus(rawValue: status)?.displayText ?? "Bilinmiyor"
    }

    var color: Color {
        switch status {
        case 0: return .orange
        case 1: return .green
        case 2: return .red
        case 3: return .gray
        default: return .gray
        }
    }

    var body: some View {
        Text(displayText)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

/// Approval/Rejection action sheet
struct ApprovalActionSheet: View {
    let request: ApprovalQueueRequestDto
    let isApproving: Bool
    @ObservedObject var viewModel: ManagerApprovalQueueViewModel
    @Binding var isPresented: Bool

    @State private var note: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Request summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Talep Bilgileri")
                        .font(.system(size: 16, weight: .semibold))

                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "Çalışan", value: request.personnelName)
                        InfoRow(label: "İzin Türü", value: request.permissionTypeName)
                        InfoRow(
                            label: "Tarih Aralığı",
                            value:
                                "\(viewModel.formatDate(request.startDate)) - \(viewModel.formatDate(request.endDate))"
                        )
                        InfoRow(
                            label: "Süre",
                            value: "\(request.desiredDays) gün"
                        )

                        if let description = request.description, !description.isEmpty {
                            InfoRow(label: "Açıklama", value: description)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                )

                // Note field
                VStack(alignment: .leading, spacing: 8) {
                    Text(isApproving ? "Onay Notu (Opsiyonel)" : "Red Nedeni (Zorunlu)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)

                    TextEditor(text: $note)
                        .frame(height: 120)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                Spacer()

                // Action button
                Button(action: {
                    Task {
                        if isApproving {
                            await viewModel.approveRequest(
                                requestId: request.permissionRequestId,
                                reason: note.isEmpty ? nil : note)
                        } else {
                            await viewModel.rejectRequest(
                                requestId: request.permissionRequestId, reason: note)
                        }

                        // Close sheet if successful
                        if viewModel.errorMessage == nil {
                            isPresented = false
                        }
                    }
                }) {
                    if viewModel.isApproving || viewModel.isRejecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text(isApproving ? "Onayla" : "Reddet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(isApproving ? Color.green : Color.red)
                .cornerRadius(12)
                .disabled(
                    viewModel.isApproving || viewModel.isRejecting || (!isApproving && note.isEmpty)
                )
            }
            .padding(16)
            .navigationTitle(isApproving ? "İzni Onayla" : "İzni Reddet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

/// Info row component
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

/// Tab button for Queue/History switcher
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primary : Color(hex: "6C7072"))

                Rectangle()
                    .fill(isSelected ? AppColors.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// History approval card (non-stacked, regular list)
struct HistoryApprovalCard: View {
    let request: ApprovalQueueRequestDto
    let onTap: () -> Void
    let isExpanded: Bool
    let onApprove: () -> Void
    let onReject: () -> Void
    @ObservedObject var viewModel: ManagerApprovalQueueViewModel

    private var statusBorderColor: Color {
        switch request.requestStatus {
        case 0: return .orange
        case 1: return .green
        case 2: return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isExpanded {
                // Expanded view
                ExpandedApprovalCard(
                    request: request,
                    onApprove: onApprove,
                    onReject: onReject,
                    viewModel: viewModel
                )
            } else {
                // Collapsed view
                CollapsedApprovalCard(
                    request: request,
                    viewModel: viewModel
                )
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(statusBorderColor, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ManagerApprovalQueueView()
}
