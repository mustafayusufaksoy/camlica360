import Foundation

/// Personnel detail DTO matching backend response
struct PersonnelDetailDto: Codable {
    // Personal Information
    let id: String
    let firstName: String
    let lastName: String
    let fullName: String?
    let tcNo: String?
    let passportNumber: String?
    let dateOfBirth: String?
    let placeOfBirth: String?
    let gender: Int?
    let bloodType: Int?
    let rhFactor: Int?
    let nationality: Int?
    let maritalStatus: Int?
    let disabilityStatus: Int?

    // Contact Information
    let personalEmail: String?
    let corporateEmail: String?
    let mobilePhone: String?
    let homePhone: String?

    // Employment Information
    let companyName: String?
    let companyCode: String?
    let companyId: String?
    let personnelNumber: String?
    let fullPersonnelNumber: String?
    let department: String?
    let position: String?
    let title: String?
    let unit: String?
    let team: String?
    let managerId: String?
    let dealerId: String?
    let mainDealerId: String?
    let departmentId: String?
    let positionId: String?
    let dealerDepartmentCode: String?
    let employmentStartDate: String?
    let employmentEndDate: String?
    let employmentStatus: Int?
    let workingType: Int?
    let shift: Int?
    let socialSecurityNumber: String?
    let salaryType: Int?

    // Avatar
    let avatarUrl: String?

    // Collections
    let addresses: [AddressInfo]?
    let emergencyContacts: [EmergencyContactInfo]?
    let educationHistory: [EducationInfo]?
    let foreignLanguages: [ForeignLanguageInfo]?
    let certificates: [CertificateInfo]?
    let salaryRights: SalaryRightsInfo?

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, fullName
        case tcNo, passportNumber
        case dateOfBirth, placeOfBirth
        case gender, bloodType, rhFactor, nationality, maritalStatus, disabilityStatus
        case personalEmail, corporateEmail, mobilePhone, homePhone
        case companyName, companyCode, companyId
        case personnelNumber, fullPersonnelNumber
        case department, position, title, unit, team
        case managerId, dealerId, mainDealerId, departmentId, positionId
        case dealerDepartmentCode, employmentStartDate, employmentEndDate
        case employmentStatus, workingType, shift, socialSecurityNumber, salaryType
        case avatarUrl
        case addresses, emergencyContacts, educationHistory, foreignLanguages, certificates, salaryRights
    }

    /// Get display full name
    var displayName: String {
        return fullName ?? "\(firstName) \(lastName)"
    }

    /// Get formatted date of birth
    var formattedDateOfBirth: String? {
        guard let dateString = dateOfBirth else { return nil }
        // Backend format: ISO 8601
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.locale = Locale(identifier: "tr_TR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }

    /// Get formatted employment start date
    var formattedEmploymentStartDate: String? {
        guard let dateString = employmentStartDate else { return nil }
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.locale = Locale(identifier: "tr_TR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Nested Types

/// Address information
struct AddressInfo: Codable {
    let id: String?
    let city: String?
    let district: String?
    let neighborhood: String?
    let addressDetail: String?
    let isPrimary: Bool?

    var fullAddress: String {
        var parts: [String] = []
        if let neighborhood = neighborhood { parts.append(neighborhood) }
        if let district = district { parts.append(district) }
        if let city = city { parts.append(city) }
        if let detail = addressDetail { parts.append(detail) }
        return parts.joined(separator: ", ")
    }
}

/// Emergency contact information
struct EmergencyContactInfo: Codable {
    let id: String?
    let contactName: String?
    let relation: String?
    let emergencyContactPhone: String?
}

/// Education history
struct EducationInfo: Codable {
    let id: String?
    let educationLevel: Int?
    let schoolName: String?
    let department: String?
    let graduationYear: Int?
}

/// Foreign language
struct ForeignLanguageInfo: Codable {
    let id: String?
    let language: String?
    let level: Int?
}

/// Certificate
struct CertificateInfo: Codable {
    let id: String?
    let certificateName: String?
    let issuerInstitution: String?
    let issueDate: String?
}

/// Salary rights
struct SalaryRightsInfo: Codable {
    let salaryAmount: Decimal?
    let currency: Int?
    let paymentMethod: Int?
    let bankName: String?
    let iban: String?
    let bonusPlan: String?
    let benefits: String?
}
