import Foundation

/// Localization keys - Organized by module/feature
///
/// Physical Structure: Single Localizable.xcstrings file (Apple best practice)
/// Logical Structure: Organized with MARK comments below
///
/// All strings are in: Resources/Localization/Localizable.xcstrings
enum LocalizationKeys: String {
    // MARK: - Common

    case required = "common_required"
    case error = "common_error"
    case success = "common_success"
    case ok = "common_ok"
    case cancel = "common_cancel"
    case close = "common_close"
    case save = "common_save"
    case delete = "common_delete"
    case edit = "common_edit"
    case back = "common_back"
    case next = "common_next"
    case loading = "common_loading"
    case noData = "common_no_data"
    case tryAgain = "common_try_again"

    // MARK: - Authentication - Login

    case loginWelcome = "auth_login_welcome"
    case loginSubtitle = "auth_login_subtitle"
    case loginCompanyCode = "auth_login_company_code"
    case loginCompanyCodePlaceholder = "auth_login_company_code_placeholder"
    case loginIdNumber = "auth_login_id_number"
    case loginIdNumberPlaceholder = "auth_login_id_number_placeholder"
    case loginPassword = "auth_login_password"
    case loginPasswordPlaceholder = "auth_login_password_placeholder"
    case loginRememberMe = "auth_login_remember_me"
    case loginForgotPassword = "auth_login_forgot_password"
    case loginButton = "auth_login_button"

    // MARK: - Authentication - Terms

    case loginTermsText = "auth_login_terms_text"
    case loginTermsAndConditions = "auth_login_terms_and_conditions"
    case loginPrivacyPolicy = "auth_login_privacy_policy"
    case loginPrivacyNotice = "auth_login_privacy_notice"
    case loginTermsAccepted = "auth_login_terms_accepted"

    // MARK: - Authentication - Errors

    case loginErrorCompanyCode = "auth_login_error_company_code"
    case loginErrorIdNumber = "auth_login_error_id_number"
    case loginErrorPassword = "auth_login_error_password"

    // MARK: - Authentication - Forgot Password

    case forgotPasswordTitle = "auth_forgot_password_title"
    case forgotPasswordSubtitle = "auth_forgot_password_subtitle"
    case forgotPasswordButton = "auth_forgot_password_button"
    case forgotPasswordFooter = "auth_forgot_password_footer"

    // MARK: - Authentication - OTP Verification

    case otpVerificationTitle = "auth_otp_verification_title"
    case otpVerificationSubtitle = "auth_otp_verification_subtitle"
    case otpVerificationButton = "auth_otp_verification_button"
    case otpVerificationTimer = "auth_otp_verification_timer"
    case otpResendCode = "auth_otp_resend_code"
    case otpNoSMS = "auth_otp_no_sms"
    case otpSendEmail = "auth_otp_send_email"

    // MARK: - Authentication - Reset Password

    case resetPasswordTitle = "auth_reset_password_title"
    case resetPasswordSubtitle = "auth_reset_password_subtitle"
    case resetPasswordNewPassword = "auth_reset_password_new_password"
    case resetPasswordNewPasswordPlaceholder = "auth_reset_password_new_password_placeholder"
    case resetPasswordConfirmPassword = "auth_reset_password_confirm_password"
    case resetPasswordConfirmPasswordPlaceholder = "auth_reset_password_confirm_password_placeholder"
    case resetPasswordButton = "auth_reset_password_button"
    case resetPasswordFooter = "auth_reset_password_footer"
    case resetPasswordSuccess = "auth_reset_password_success"
    case resetPasswordErrorMismatch = "auth_reset_password_error_mismatch"
    case resetPasswordErrorMinLength = "auth_reset_password_error_min_length"

    // MARK: - Home - Tab Bar

    case tabHome = "home_tab_home"
    case tabReports = "home_tab_reports"
    case tabMessages = "home_tab_messages"
    case tabNotifications = "home_tab_notifications"
    case tabProfile = "home_tab_profile"

    // MARK: - Home - Dashboard

    case homeCompleted = "home_completed_title"
    case homePending = "home_pending_title"

    // MARK: - Attendance - Main

    case attendanceTitle = "attendance_title"
    case attendanceSubtitle = "attendance_subtitle"
    case checkIn = "attendance_check_in"
    case checkOut = "attendance_check_out"
    case checkInSuccessful = "check_in_successful"
    case checkOutSuccessful = "check_out_successful"
    case notInWorkplace = "not_in_workplace"
    case offlineLogSaved = "offline_log_saved"

    // MARK: - Attendance - Pending Logs

    case pendingLogs = "pending_logs"
    case pendingLogsCount = "pending_logs_count"
    case sync = "sync"

    // MARK: - Attendance - History

    case todaysLogs = "todays_logs"
    case attendanceHistory = "attendance_history"
    case viewHistory = "view_history"
    case firstCheckIn = "first_check_in"
    case lastCheckOut = "last_check_out"
    case totalEvents = "total_events"
    case allEntries = "all_entries"
    case workingHours = "working_hours"
    case checkedIn = "checked_in"
    case checkedOut = "checked_out"
    case notCheckedIn = "not_checked_in"
    case noLogsFound = "no_logs_found"

    // MARK: - Attendance - Date Ranges

    case dateRangeToday = "date_range_today"
    case dateRangeYesterday = "date_range_yesterday"
    case dateRangeThisWeek = "date_range_this_week"
    case dateRangeLastWeek = "date_range_last_week"
    case dateRangeThisMonth = "date_range_this_month"
    case dateRangeLastMonth = "date_range_last_month"
    case dateRange = "date_range"

    // MARK: - Location Services

    case locationServicesDisabled = "location_services_disabled"
    case locationEnabled = "location_enabled"
    case locationDisabled = "location_disabled"
    case locationPermissionDenied = "location_permission_denied"
    case locationPermissionRestricted = "location_permission_restricted"
    case locationPermissionNotDetermined = "location_permission_not_determined"
    case locationNotAvailable = "location_not_available"
    case locationStatus = "location_status"
    case locationInvalid = "location_invalid"

    // MARK: - Legacy (For backward compatibility)

    case welcomeMessage = "welcome_message"
    case loginTitle = "login_title"
    case emailPlaceholder = "email_placeholder"
    case passwordPlaceholder = "password_placeholder"
    case errorInvalidEmail = "error_invalid_email"

    // MARK: - Localization

    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }

    /// Localize with parameters
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self.rawValue, comment: ""), arguments: arguments)
    }
}
