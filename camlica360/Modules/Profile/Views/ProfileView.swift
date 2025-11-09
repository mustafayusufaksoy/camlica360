import SwiftUI

/// Profile view showing user details
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else if let personnel = viewModel.personnelInfo {
                    profileContent(personnel)
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.neutral100)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Profil bilgileri yükleniyor...")
                .font(AppFonts.smRegular)
                .foregroundColor(AppColors.neutral600)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(AppColors.error)

            Text(error)
                .font(AppFonts.smRegular)
                .foregroundColor(AppColors.neutral700)
                .multilineTextAlignment(.center)

            PrimaryButton(
                title: "Tekrar Dene",
                action: { viewModel.loadProfileData() }
            )
            .padding(.top, AppSpacing.md)
        }
        .padding(AppSpacing.xl)
    }

    // MARK: - Profile Content

    private func profileContent(_ personnel: PersonnelDetailDto) -> some View {
        VStack(spacing: AppSpacing.lg) {
            // Avatar Section
            avatarSection(personnel)

            // Personal Information
            infoCard(
                title: "Kişisel Bilgiler",
                icon: "person.fill",
                content: {
                    personalInfoContent(personnel)
                }
            )

            // Contact Information
            infoCard(
                title: "İletişim Bilgileri",
                icon: "phone.fill",
                content: {
                    contactInfoContent(personnel)
                }
            )

            // Employment Information
            infoCard(
                title: "İş Bilgileri",
                icon: "briefcase.fill",
                content: {
                    employmentInfoContent(personnel)
                }
            )

            // Address Information
            if let addresses = personnel.addresses, !addresses.isEmpty {
                infoCard(
                    title: "Adres Bilgileri",
                    icon: "mappin.and.ellipse",
                    content: {
                        addressInfoContent(addresses)
                    }
                )
            }

            // Emergency Contacts
            if let contacts = personnel.emergencyContacts, !contacts.isEmpty {
                infoCard(
                    title: "Acil Durum İletişim",
                    icon: "phone.circle.fill",
                    content: {
                        emergencyContactsContent(contacts)
                    }
                )
            }

            // Team Information
            if personnel.team != nil || personnel.unit != nil {
                infoCard(
                    title: "Ekip Bilgileri",
                    icon: "person.3.fill",
                    content: {
                        teamInfoContent(personnel)
                    }
                )
            }

            // Logout Button
            Button(action: { viewModel.logout() }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Çıkış Yap")
                        .font(AppFonts.smMedium)
                }
                .foregroundColor(AppColors.error)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.md)
                .background(AppColors.white)
                .cornerRadius(AppSpacing.radiusMd)
            }
        }
    }

    // MARK: - Avatar Section

    private func avatarSection(_ personnel: PersonnelDetailDto) -> some View {
        VStack(spacing: AppSpacing.md) {
            // Avatar
            Circle()
                .fill(AppColors.primary950.opacity(0.1))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(viewModel.getUserInitials())
                        .font(AppFonts.custom(size: 36, weight: .bold))
                        .foregroundColor(AppColors.primary950)
                )

            // Name
            Text(personnel.displayName)
                .font(AppFonts.large(size: 20, weight: .semibold))
                .foregroundColor(AppColors.black)

            // Position
            if let position = personnel.position {
                Text(position)
                    .font(AppFonts.smRegular)
                    .foregroundColor(AppColors.neutral600)
            }

            // Personnel Number
            if let personnelNumber = personnel.fullPersonnelNumber {
                Text("Sicil No: \(personnelNumber)")
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral500)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.radiusMd)
    }

    // MARK: - Personal Info Content

    private func personalInfoContent(_ personnel: PersonnelDetailDto) -> some View {
        VStack(spacing: AppSpacing.md) {
            if let dateOfBirth = personnel.formattedDateOfBirth {
                infoRow(label: "Doğum Tarihi", value: dateOfBirth)
            }

            if let tcNo = personnel.tcNo {
                infoRow(label: "TC Kimlik No", value: tcNo)
            }

            if let gender = viewModel.getGenderDisplay() {
                infoRow(label: "Cinsiyet", value: gender)
            }

            if let bloodType = viewModel.getBloodTypeDisplay() {
                infoRow(label: "Kan Grubu", value: bloodType)
            }

            if let maritalStatus = viewModel.getMaritalStatusDisplay() {
                infoRow(label: "Medeni Durum", value: maritalStatus)
            }
        }
    }

    // MARK: - Contact Info Content

    private func contactInfoContent(_ personnel: PersonnelDetailDto) -> some View {
        VStack(spacing: AppSpacing.md) {
            if let email = personnel.personalEmail {
                infoRow(label: "Kişisel E-posta", value: email)
            }

            if let corporateEmail = personnel.corporateEmail {
                infoRow(label: "Kurumsal E-posta", value: corporateEmail)
            }

            if let phone = personnel.mobilePhone {
                infoRow(label: "Cep Telefonu", value: phone)
            }

            if let homePhone = personnel.homePhone {
                infoRow(label: "Ev Telefonu", value: homePhone)
            }
        }
    }

    // MARK: - Employment Info Content

    private func employmentInfoContent(_ personnel: PersonnelDetailDto) -> some View {
        VStack(spacing: AppSpacing.md) {
            if let company = personnel.companyName {
                infoRow(label: "Şirket", value: company)
            }

            if let department = personnel.department {
                infoRow(label: "Departman", value: department)
            }

            if let position = personnel.position {
                infoRow(label: "Pozisyon", value: position)
            }

            if let startDate = personnel.formattedEmploymentStartDate {
                infoRow(label: "İşe Giriş Tarihi", value: startDate)
            }
        }
    }

    // MARK: - Address Info Content

    private func addressInfoContent(_ addresses: [AddressInfo]) -> some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(addresses.indices, id: \.self) { index in
                let address = addresses[index]
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    if address.isPrimary == true {
                        Text("Birincil Adres")
                            .font(AppFonts.xsMedium)
                            .foregroundColor(AppColors.primary950)
                            .padding(.bottom, AppSpacing.xs)
                    }

                    if let detail = address.addressDetail, !detail.isEmpty {
                        Text(detail)
                            .font(AppFonts.smRegular)
                            .foregroundColor(AppColors.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(address.fullAddress)
                        .font(AppFonts.smRegular)
                        .foregroundColor(AppColors.neutral700)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if index < addresses.count - 1 {
                    Divider()
                }
            }
        }
    }

    // MARK: - Emergency Contacts Content

    private func emergencyContactsContent(_ contacts: [EmergencyContactInfo]) -> some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(contacts.indices, id: \.self) { index in
                let contact = contacts[index]
                VStack(spacing: AppSpacing.sm) {
                    if let name = contact.contactName {
                        infoRow(label: "İsim", value: name)
                    }
                    if let relation = contact.relation {
                        infoRow(label: "Yakınlık", value: relation)
                    }
                    if let phone = contact.emergencyContactPhone {
                        infoRow(label: "Telefon", value: phone)
                    }
                }

                if index < contacts.count - 1 {
                    Divider()
                }
            }
        }
    }

    // MARK: - Team Info Content

    private func teamInfoContent(_ personnel: PersonnelDetailDto) -> some View {
        VStack(spacing: AppSpacing.md) {
            if let team = personnel.team {
                infoRow(label: "Ekip", value: team)
            }
            if let unit = personnel.unit {
                infoRow(label: "Birim", value: unit)
            }
            if let title = personnel.title {
                infoRow(label: "Ünvan", value: title)
            }
        }
    }

    // MARK: - Info Card

    private func infoCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primary950)

                Text(title)
                    .font(AppFonts.smMedium)
                    .foregroundColor(AppColors.black)
            }

            Divider()

            // Content
            content()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.radiusMd)
    }

    // MARK: - Info Row

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(AppFonts.xsRegular)
                .foregroundColor(AppColors.neutral600)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(AppFonts.smRegular)
                .foregroundColor(AppColors.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
