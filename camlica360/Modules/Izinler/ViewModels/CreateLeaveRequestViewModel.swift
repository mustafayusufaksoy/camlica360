import Foundation
import SwiftUI

/// ViewModel for creating a new leave request
@MainActor
class CreateLeaveRequestViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var leaveType: DropdownOption? = nil
    @Published var startDate: Date? = nil
    @Published var startTime: Date? = nil
    @Published var endDate: Date? = nil
    @Published var endTime: Date? = nil
    @Published var description: String = ""
    @Published var selectedFiles: [URL] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert: Bool = false

    // MARK: - Validation Errors

    @Published var leaveTypeError: String?
    @Published var startDateError: String?
    @Published var startTimeError: String?
    @Published var endDateError: String?
    @Published var endTimeError: String?

    // MARK: - Dependencies

    private let izinlerService: IzinlerService
    private let keychainManager: KeychainManager

    // MARK: - Data

    @Published var leaveTypeOptions: [DropdownOption] = []
    private var permissionTypes: [PermissionTypeDto] = []

    // MARK: - Initialization

    init(
        izinlerService: IzinlerService = .shared,
        keychainManager: KeychainManager = .shared
    ) {
        self.izinlerService = izinlerService
        self.keychainManager = keychainManager

        // Load permission types on init
        Task {
            await loadPermissionTypes()
        }
    }

    // MARK: - Computed Properties

    var isFormValid: Bool {
        leaveType != nil &&
        startDate != nil &&
        startTime != nil &&
        endDate != nil &&
        endTime != nil
    }

    var totalDuration: String {
        guard let start = startDate, let end = endDate else {
            return "0 gün"
        }

        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        let totalDays = abs(days) + 1 // Include both start and end day

        if totalDays == 1 {
            return "1 gün"
        } else {
            return "\(totalDays) gün"
        }
    }

    // MARK: - Methods

    func resetForm() {
        leaveType = nil
        startDate = nil
        startTime = nil
        endDate = nil
        endTime = nil
        description = ""
        selectedFiles = []
        clearErrors()
    }

    func clearErrors() {
        leaveTypeError = nil
        startDateError = nil
        startTimeError = nil
        endDateError = nil
        endTimeError = nil
        errorMessage = nil
    }

    func validateForm() -> Bool {
        clearErrors()
        var isValid = true

        if leaveType == nil {
            leaveTypeError = "İzin türü seçiniz"
            isValid = false
        }

        if startDate == nil {
            startDateError = "Başlangıç tarihi seçiniz"
            isValid = false
        }

        if startTime == nil {
            startTimeError = "Başlangıç saati seçiniz"
            isValid = false
        }

        if endDate == nil {
            endDateError = "Bitiş tarihi seçiniz"
            isValid = false
        }

        if endTime == nil {
            endTimeError = "Bitiş saati seçiniz"
            isValid = false
        }

        // Validate end date is after start date
        if let start = startDate, let end = endDate, end < start {
            endDateError = "Bitiş tarihi başlangıç tarihinden önce olamaz"
            isValid = false
        }

        return isValid
    }

    func submitLeaveRequest() async {
        guard validateForm() else { return }

        // Get user ID
        guard let userId = keychainManager.getUserId() else {
            errorMessage = "Kullanıcı bilgisi bulunamadı"
            return
        }

        // Get selected permission type ID
        guard let selectedLeaveType = leaveType,
              let permissionType = permissionTypes.first(where: { $0.name == selectedLeaveType.title }) else {
            errorMessage = "İzin türü seçiniz"
            return
        }

        // Combine date and time
        guard let startDate = startDate,
              let startTime = startTime,
              let endDate = endDate,
              let endTime = endTime else {
            errorMessage = "Lütfen tüm tarih ve saat bilgilerini giriniz"
            return
        }

        let calendar = Calendar.current
        let startDateTime = combineDateAndTime(date: startDate, time: startTime, calendar: calendar)
        let endDateTime = combineDateAndTime(date: endDate, time: endTime, calendar: calendar)

        // Format dates to ISO8601
        let iso8601Formatter = ISO8601DateFormatter()
        let startDateString = iso8601Formatter.string(from: startDateTime)
        let endDateString = iso8601Formatter.string(from: endDateTime)

        // Calculate desired days
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let desiredDays = abs(days) + 1

        isLoading = true
        errorMessage = nil

        do {
            // Create DTO
            let request = CreatePermissionRequestDto(
                personnelId: userId,
                permissionTypeId: permissionType.id,
                startDate: startDateString,
                endDate: endDateString,
                desiredDays: desiredDays,
                description: description.isEmpty ? nil : description,
                attachmentPath: nil, // TODO: Handle file upload
                status: 0 // Pending
            )

            print("🔵 [CreateLeaveRequestViewModel] Submitting request: \(request)")

            // Submit to backend
            let (requestId, warning) = try await izinlerService.createPermissionRequest(request)

            print("✅ [CreateLeaveRequestViewModel] Request created with ID: \(requestId)")

            // Show warning if backend returned one
            if let warningMessage = warning {
                print("⚠️ [CreateLeaveRequestViewModel] Backend warning: \(warningMessage)")
                // Could show a different alert or add to success message
            }

            showSuccessAlert = true
            resetForm()
        } catch let networkError as NetworkError {
            errorMessage = "İzin talebi oluşturulurken bir hata oluştu: \(networkError.localizedDescription)"
            print("❌ [CreateLeaveRequestViewModel] Failed to create request: \(networkError)")
        } catch {
            errorMessage = "İzin talebi oluşturulurken bir hata oluştu. Lütfen tekrar deneyin."
            print("❌ [CreateLeaveRequestViewModel] Failed to create request: \(error)")
        }

        isLoading = false
    }

    // MARK: - Private Methods

    /// Load permission types from backend
    private func loadPermissionTypes() async {
        do {
            print("🔵 [CreateLeaveRequestViewModel] Loading permission types")

            permissionTypes = try await izinlerService.getPermissionTypes()

            // Map to dropdown options
            leaveTypeOptions = permissionTypes.map { type in
                DropdownOption(
                    title: type.name,
                    description: type.description ?? ""
                )
            }

            print("✅ [CreateLeaveRequestViewModel] Loaded \(permissionTypes.count) permission types")

        } catch {
            print("❌ [CreateLeaveRequestViewModel] Failed to load permission types: \(error)")
            // Fallback to empty array
            leaveTypeOptions = []
        }
    }

    /// Combine date and time into a single Date object
    private func combineDateAndTime(date: Date, time: Date, calendar: Calendar) -> Date {
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute

        return calendar.date(from: combined) ?? date
    }
}
