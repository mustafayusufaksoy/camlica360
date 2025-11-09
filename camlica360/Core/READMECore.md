# 🔐 Core Module - Authentication & Data Management

Bu belge, Camlica360 iOS uygulamasının **Core** modülünün tüm işleyişini, authentication sistemini, veri depolama mekanizmalarını ve network katmanını detaylıca açıklar.

## 📑 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Authentication Sistemi](#authentication-sistemi)
3. [Network Katmanı](#network-katmanı)
4. [Veri Depolama](#veri-depolama)
5. [JWT Token Yönetimi](#jwt-token-yönetimi)
6. [Veri Akışı](#veri-akışı)
7. [Kullanım Örnekleri](#kullanım-örnekleri)

---

## 🎯 Genel Bakış

Core modülü, uygulamanın temel altyapısını oluşturur ve şu bileşenlerden oluşur:

```
Core/
├── Network/                    # API iletişimi
│   ├── NetworkManager.swift    # HTTP client
│   ├── Endpoint.swift          # API endpoint tanımları
│   ├── NetworkError.swift      # Error handling
│   └── APIConstants.swift      # API konfigürasyonu
│
├── Storage/                    # Veri depolama
│   ├── KeychainManager.swift   # Güvenli depolama (tokens, credentials)
│   └── UserDefaultsManager.swift # App preferences
│
├── Models/                     # Data models
│   └── UserInfo.swift          # Kullanıcı bilgileri
│
└── Utils/                      # Yardımcı araçlar
    └── Helpers/
        └── JWTHelper.swift     # JWT token decode
```

---

## 🔐 Authentication Sistemi

### Giriş Akışı (Login Flow)

Uygulama **2 aşamalı kimlik doğrulama (2FA)** kullanır:

```
1. Login (Credentials) → Temp Token
2. OTP Verification → Access Token
```

### 1️⃣ Adım 1: Login (Credentials)

**Endpoint:** `POST /api/Authentication/login`

**Request:**
```json
{
    "code": "R6426",           // Şirket kodu
    "tcNo": "12345678901",     // TC Kimlik No
    "password": "Password123"  // Şifre
}
```

**Response:**
```json
{
    "userId": "12345-67890-abcde",
    "token": "eyJhbGc...",         // Temp Token (2FA için)
    "companyCode": "R6426",
    "twoFactorEnabled": true,
    "twoFactorMethod": "SMS"       // SMS veya Email
}
```

**İşlemler:**

1. **Temp Token Kaydet** (Keychain)
   ```swift
   keychainManager.saveTempToken(response.token)
   ```

2. **User ID Kaydet** (Keychain)
   ```swift
   keychainManager.saveUserId(response.userId)
   ```

3. **Company Code Kaydet** (Keychain + NetworkManager)
   ```swift
   keychainManager.saveCompanyCode(response.companyCode)
   networkManager.setCompanyCode(response.companyCode)
   ```

4. **User Info Çıkart** (Temp Token'dan)
   ```swift
   if let userInfo = UserInfo.from(token: response.token) {
       userDefaultsManager.saveUserInfo(userInfo)
   }
   ```

   **ÖNEMLİ:** Temp token, kullanıcının **tam adını** içerir:
   - `nameid`: userId
   - `unique_name`: "Satış Danışmanı" (Full Name)
   - `companyCode`: "R6426"

5. **Remember Me** (İsteğe bağlı)
   ```swift
   if rememberMe {
       userDefaultsManager.saveRememberMe(true)
       userDefaultsManager.saveCompanyCode(companyCode)
       userDefaultsManager.saveIdNumber(idNumber)
   }
   ```

### 2️⃣ Adım 2: OTP Verification

**Endpoint:** `POST /api/Authentication/verifyOTP`

**Request:**
```json
{
    "userId": "12345-67890-abcde",
    "code": "224203",              // 6 haneli OTP kodu
    "token": "eyJhbGc..."          // Temp token
}
```

**Response:**
```json
{
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**İşlemler:**

1. **Access Token Kaydet** (Keychain)
   ```swift
   keychainManager.saveAccessToken(response.accessToken)
   ```

2. **NetworkManager'a Token Ata**
   ```swift
   networkManager.setAccessToken(response.accessToken)
   ```

3. **Temp Token Sil** (Artık gerekli değil)
   ```swift
   keychainManager.deleteTempToken()
   ```

4. **Authentication State Güncelle**
   ```swift
   AuthStateManager.shared.login()
   ```

**⚠️ ÖNEMLİ NOT:**

Access token'dan **user info çıkartmıyoruz** çünkü:
- Access token sadece şifrelenmiş `sub` claim'i içerir
- `unique_name` (full name) yok
- User info zaten Adım 1'de temp token'dan çıkartıldı

---

## 🌐 Network Katmanı

### NetworkManager

Tüm API istekleri için **merkezi HTTP client**.

**Özellikler:**
- Generic request method (Codable desteği)
- Otomatik token ekleme (Authorization header)
- Company code header yönetimi
- Error handling
- Async/await desteği

**Kullanım:**

```swift
let response: LoginResponseDto = try await networkManager.request(
    endpoint: .login,
    body: loginRequest,
    responseType: LoginResponseDto.self
)
```

### Endpoint Tanımları

```swift
enum Endpoint {
    case login
    case verifyOTP
    case forgotPassword
    case resetPassword
    case getPersonnelById(String)

    var path: String {
        switch self {
        case .login:
            return "/Authentication/login"
        case .verifyOTP:
            return "/Authentication/verifyOTP"
        case .getPersonnelById(let id):
            return "/CrmPersonnel/getCrmPersonnelById?id=\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .verifyOTP, .forgotPassword, .resetPassword:
            return .post
        case .getPersonnelById:
            return .get
        }
    }
}
```

### Headers

Her request'e otomatik eklenir:

```swift
"Content-Type": "application/json"
"Authorization": "Bearer \(accessToken)"  // Varsa
"CompanyCode": "\(companyCode)"           // Varsa
```

### API Configuration

```swift
// APIConstants.swift
struct APIConstants {
    static let baseURL = "http://192.168.1.101:8080/api"
    static let requestTimeout: TimeInterval = 30
    static let resourceTimeout: TimeInterval = 60
}
```

**Not:** Physical device için Mac'in local IP'si kullanılıyor (`192.168.1.101`).

---

## 💾 Veri Depolama

### 1. KeychainManager (Güvenli Depolama)

**Ne saklanır:**
- ✅ Access Token (JWT)
- ✅ Temp Token (2FA için geçici)
- ✅ User ID
- ✅ Company Code

**Neden Keychain?**
- iOS'un en güvenli depolama mekanizması
- Veriler şifrelenmiş olarak saklanır
- App silindikten sonra bile kalabilir (isteğe bağlı)
- TouchID/FaceID ile korunabilir

**Kullanım:**

```swift
// Kaydet
keychainManager.saveAccessToken("eyJhbGc...")

// Oku
if let token = keychainManager.getAccessToken() {
    print("Token: \(token)")
}

// Sil
keychainManager.deleteAccessToken()
```

**Tüm Metodlar:**

```swift
// Access Token
saveAccessToken(_ token: String) -> Bool
getAccessToken() -> String?
deleteAccessToken() -> Bool

// Temp Token
saveTempToken(_ token: String) -> Bool
getTempToken() -> String?
deleteTempToken() -> Bool

// User ID
saveUserId(_ userId: String) -> Bool
getUserId() -> String?
deleteUserId() -> Bool

// Company Code
saveCompanyCode(_ code: String) -> Bool
getCompanyCode() -> String?
deleteCompanyCode() -> Bool

// Tümünü temizle
clearAll() -> Bool
```

### 2. UserDefaultsManager (App Preferences)

**Ne saklanır:**
- ✅ Remember Me tercihi
- ✅ Kaydedilmiş company code (UI için)
- ✅ Kaydedilmiş TC No (UI için)
- ✅ User Info (JSON olarak - full name, email vb.)
- ✅ First launch flag

**Neden UserDefaults?**
- Hassas olmayan veriler için
- Hızlı okuma/yazma
- UI state için ideal

**Kullanım:**

```swift
// Remember Me
userDefaultsManager.saveRememberMe(true)
let rememberMe = userDefaultsManager.getRememberMe()

// User Info (Codable)
let userInfo = UserInfo(userId: "123", fullName: "John Doe")
userDefaultsManager.saveUserInfo(userInfo)

if let savedUserInfo = userDefaultsManager.getUserInfo() {
    print("Kullanıcı: \(savedUserInfo.displayName)")
}
```

**Tüm Metodlar:**

```swift
// Remember Me
saveRememberMe(_ remember: Bool)
getRememberMe() -> Bool

// Credentials (UI için)
saveCompanyCode(_ code: String)
getCompanyCode() -> String?
saveIdNumber(_ idNumber: String)
getIdNumber() -> String?

// User Info
saveUserInfo(_ userInfo: UserInfo)
getUserInfo() -> UserInfo?
clearUserInfo()

// Tümünü temizle
clearCredentials()
clearAll()
```

---

## 🎫 JWT Token Yönetimi

### JWTHelper

JWT token'ları decode eder ve claim'leri çıkartır.

**Token Yapısı:**

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJuYW1laWQiOiIxMjM0NSIsInVuaXF1ZV9uYW1lIjoiU2F0xLHFnyBEYW7EscWfbWFuxLEiLCJjb21wYW55Q29kZSI6IlI2NDI2In0.
signature
```

Decode edildiğinde:

```json
{
  "nameid": "12345-67890-abcde",           // userId
  "unique_name": "Satış Danışmanı",        // fullName (sadece temp token'da)
  "companyCode": "R6426",
  "exp": 1234567890
}
```

**Claim Tipleri:**

| Claim | Temp Token | Access Token | Açıklama |
|-------|-----------|--------------|----------|
| `nameid` | ✅ | ❌ | User ID (short claim name) |
| `http://schemas.xmlsoap.org/.../nameidentifier` | ❌ | ✅ | User ID (full URI) |
| `unique_name` | ✅ | ❌ | Full Name (short) |
| `http://schemas.xmlsoap.org/.../name` | ❌ | ✅ | Full Name (full URI) |
| `companyCode` | ✅ | ❌ | Company Code |
| `sub` | ❌ | ✅ | Encrypted subject |

**Metodlar:**

```swift
// User ID çıkart
func getUserId(from token: String) -> String?

// Full Name çıkart
func getFullName(from token: String) -> String?

// Company Code çıkart
func getCompanyCode(from token: String) -> String?

// Company Representative check
func isCompanyRepresentative(from token: String) -> Bool

// Avatar URL
func getAvatarUrl(from token: String) -> String?

// Logo URL
func getLogoUrl(from token: String) -> String?
```

**Önemli Detay:**

JWTHelper, **hem short claim names hem de full URI'ları kontrol eder**:

```swift
func getUserId(from token: String) -> String? {
    guard let claims = decodeToken(token) else { return nil }

    // 1. Önce short claim name dene (temp token)
    if let nameid = claims["nameid"] as? String {
        return nameid
    }

    // 2. Sonra full URI dene (access token)
    if let nameid = claims["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"] as? String {
        return nameid
    }

    return nil
}
```

### UserInfo Model

JWT token'dan çıkartılan kullanıcı bilgileri:

```swift
struct UserInfo: Codable {
    let userId: String
    let fullName: String?
    let email: String?
    let companyCode: String?
    let companyId: String?
    let avatarUrl: String?
    let logoUrl: String?
    let isCompanyRepresentative: Bool

    // Computed properties
    var displayName: String {
        return fullName ?? "Kullanıcı"
    }

    var initials: String {
        // "Satış Danışmanı" → "SD"
        let components = fullName?.components(separatedBy: " ")
        let initials = components?.prefix(2).compactMap { $0.first }
        return initials?.map { String($0) }.joined().uppercased() ?? "?"
    }

    // Static factory method
    static func from(token: String) -> UserInfo? {
        let jwtHelper = JWTHelper.shared
        guard let userId = jwtHelper.getUserId(from: token) else {
            return nil
        }

        return UserInfo(
            userId: userId,
            fullName: jwtHelper.getFullName(from: token),
            companyCode: jwtHelper.getCompanyCode(from: token),
            avatarUrl: jwtHelper.getAvatarUrl(from: token),
            logoUrl: jwtHelper.getLogoUrl(from: token),
            isCompanyRepresentative: jwtHelper.isCompanyRepresentative(from: token)
        )
    }
}
```

---

## 🔄 Veri Akışı

### Login'den Profile'a Tam Akış

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. LOGIN SCREEN                                                 │
└─────────────────────────────────────────────────────────────────┘
                            ↓
        User enters: CompanyCode, TCNO, Password
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. AuthService.login()                                          │
│    - POST /api/Authentication/login                             │
│    - Response: userId, tempToken, companyCode                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. DEPOLAMA (Login Response)                                    │
│    ┌─────────────────────────────────────────────────────────┐ │
│    │ KEYCHAIN                                                │ │
│    │ - tempToken: "eyJhbGc..."                               │ │
│    │ - userId: "12345-67890"                                 │ │
│    │ - companyCode: "R6426"                                  │ │
│    └─────────────────────────────────────────────────────────┘ │
│    ┌─────────────────────────────────────────────────────────┐ │
│    │ USERDEFAULTS                                            │ │
│    │ - userInfo: {                                           │ │
│    │     userId: "12345-67890",                              │ │
│    │     fullName: "Satış Danışmanı",  ← TEMP TOKEN'DAN     │ │
│    │     companyCode: "R6426"                                │ │
│    │   }                                                     │ │
│    └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. OTP SCREEN                                                   │
│    User enters: 6-digit OTP code                                │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. AuthService.verifyOTP()                                      │
│    - POST /api/Authentication/verifyOTP                         │
│    - Request: userId, code, tempToken                           │
│    - Response: accessToken                                      │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. DEPOLAMA (OTP Verification)                                  │
│    ┌─────────────────────────────────────────────────────────┐ │
│    │ KEYCHAIN                                                │ │
│    │ - accessToken: "eyJhbGc..." ← YENİ                      │ │
│    │ - tempToken: DELETED ✗                                  │ │
│    │ - userId: "12345-67890" (korunur)                       │ │
│    │ - companyCode: "R6426" (korunur)                        │ │
│    └─────────────────────────────────────────────────────────┘ │
│    ┌─────────────────────────────────────────────────────────┐ │
│    │ USERDEFAULTS                                            │ │
│    │ - userInfo: { ... } (DEĞİŞMEZ - temp token'dan geldi)  │ │
│    └─────────────────────────────────────────────────────────┘ │
│    ┌─────────────────────────────────────────────────────────┐ │
│    │ NETWORKMANAGER                                          │ │
│    │ - setAccessToken(accessToken)                           │ │
│    └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. AuthStateManager.login()                                     │
│    - isAuthenticated = true                                     │
│    - Navigate to HomeView                                       │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 8. HOME VIEW                                                    │
│    ┌─────────────────────────────────────────────────────────┐ │
│    │ Header:                                                 │ │
│    │ [Logo]                    [SD] ← ProfileButton          │ │
│    │                              ↑                          │ │
│    │                    userInfo.initials                    │ │
│    └─────────────────────────────────────────────────────────┘ │
│    ┌─────────────────────────────────────────────────────────┐ │
│    │ Profile Section:                                        │ │
│    │ [SD] Satış Danışmanı  ← userInfo.displayName           │ │
│    └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                  User taps ProfileButton
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 9. PROFILE VIEW                                                 │
│    - ProfileViewModel.loadProfileData()                         │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 10. PersonnelService.getPersonnelById()                         │
│     - GET /api/CrmPersonnel/getCrmPersonnelById?id={userId}     │
│     - Headers:                                                  │
│       • Authorization: Bearer {accessToken}                     │
│       • CompanyCode: R6426                                      │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 11. BACKEND RESPONSE (PersonnelDetailDto)                       │
│     {                                                           │
│       "id": "12345-67890",                                      │
│       "firstName": "Satış",                                     │
│       "lastName": "Danışmanı",                                  │
│       "fullName": "Satış Danışmanı",                            │
│       "tcNo": "12345678901",                                    │
│       "dateOfBirth": "1990-01-01T00:00:00Z",                    │
│       "gender": 0,                                              │
│       "bloodType": 0,                                           │
│       "rhFactor": 0,                                            │
│       "maritalStatus": 0,                                       │
│       "personalEmail": "satis@example.com",                     │
│       "corporateEmail": "satis@deneme.com",                     │
│       "mobilePhone": "+90 555 123 4567",                        │
│       "companyName": "Deneme Firm",                             │
│       "department": "Finans Departmanı",                        │
│       "position": "Satış Danışmanı",                            │
│       "addresses": [...],                                       │
│       "emergencyContacts": [...],                               │
│       "team": "deneme"                                          │
│     }                                                           │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 12. PROFILE VIEW - FULL DISPLAY                                 │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ [SD] Satış Danışmanı                                  │   │
│     │      Satış Danışmanı                                  │   │
│     │      Sicil No: 12345                                  │   │
│     └───────────────────────────────────────────────────────┘   │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ 👤 Kişisel Bilgiler                                   │   │
│     │ Doğum Tarihi: 1 Ocak 1990                             │   │
│     │ TC Kimlik No: 12345678901                             │   │
│     │ Cinsiyet: Erkek                                       │   │
│     │ Kan Grubu: A+                                         │   │
│     │ Medeni Durum: Bekar                                   │   │
│     └───────────────────────────────────────────────────────┘   │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ 📞 İletişim Bilgileri                                 │   │
│     │ Kişisel E-posta: satis@example.com                    │   │
│     │ Kurumsal E-posta: satis@deneme.com                    │   │
│     │ Cep Telefonu: +90 555 123 4567                        │   │
│     └───────────────────────────────────────────────────────┘   │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ 💼 İş Bilgileri                                       │   │
│     │ Şirket: Deneme Firm                                   │   │
│     │ Departman: Finans Departmanı                          │   │
│     │ Pozisyon: Satış Danışmanı                             │   │
│     └───────────────────────────────────────────────────────┘   │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ 📍 Adres Bilgileri                                    │   │
│     │ Atatürk Mah, Dinar, AFYONKARAHİSAR                    │   │
│     └───────────────────────────────────────────────────────┘   │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ 🚨 Acil Durum İletişim                                │   │
│     │ İsim: asdsa                                           │   │
│     │ Yakınlık: asdsad                                      │   │
│     │ Telefon: +90 555 999 8888                             │   │
│     └───────────────────────────────────────────────────────┘   │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ 👥 Ekip Bilgileri                                     │   │
│     │ Ekip: deneme                                          │   │
│     └───────────────────────────────────────────────────────┘   │
│     ┌───────────────────────────────────────────────────────┐   │
│     │ [🚪 Çıkış Yap]                                        │   │
│     └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📘 Kullanım Örnekleri

### Authentication

#### Login İşlemi

```swift
// LoginViewModel.swift
@MainActor
class LoginViewModel: ObservableObject {
    @Published var companyCode = ""
    @Published var idNumber = ""
    @Published var password = ""
    @Published var rememberMe = false
    @Published var isLoading = false
    @Published var error: String?

    private let authService = AuthService.shared

    func login() async {
        isLoading = true
        error = nil

        do {
            let response = try await authService.login(
                companyCode: companyCode,
                idNumber: idNumber,
                password: password,
                rememberMe: rememberMe
            )

            // Navigate to OTP screen
            // Pass response.userId and response.twoFactorMethod

        } catch let networkError as NetworkError {
            error = networkError.localizedDescription
        } catch {
            error = "Giriş yapılamadı"
        }

        isLoading = false
    }
}
```

#### OTP Verification

```swift
// OTPViewModel.swift
@MainActor
class OTPViewModel: ObservableObject {
    @Published var otpCode = ""
    @Published var isLoading = false
    @Published var error: String?

    private let authService = AuthService.shared
    let userId: String

    func verifyOTP() async {
        isLoading = true
        error = nil

        do {
            let response = try await authService.verifyOTP(
                userId: userId,
                code: otpCode
            )

            // Success - token saved automatically
            // Navigate to home
            AuthStateManager.shared.login()

        } catch let networkError as NetworkError {
            error = networkError.localizedDescription
        } catch {
            error = "Doğrulama başarısız"
        }

        isLoading = false
    }
}
```

### Profile Data Fetching

```swift
// ProfileViewModel.swift
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var personnelInfo: PersonnelDetailDto?
    @Published var isLoading = false
    @Published var error: String?

    private let personnelService = PersonnelService.shared
    private let userDefaultsManager = UserDefaultsManager.shared

    func loadProfileData() {
        guard let userInfo = userDefaultsManager.getUserInfo() else {
            error = "Kullanıcı bilgisi bulunamadı"
            return
        }

        Task {
            isLoading = true
            error = nil

            do {
                let personnel = try await personnelService.getPersonnelById(
                    userId: userInfo.userId
                )
                self.personnelInfo = personnel

            } catch let networkError as NetworkError {
                self.error = networkError.localizedDescription
            } catch {
                self.error = "Profil bilgileri yüklenemedi"
            }

            isLoading = false
        }
    }

    func getUserInitials() -> String {
        guard let personnel = personnelInfo else { return "?" }
        let first = String(personnel.firstName.prefix(1))
        let last = String(personnel.lastName.prefix(1))
        return "\(first)\(last)".uppercased()
    }
}
```

### Logout

```swift
// ProfileViewModel.swift
func logout() {
    do {
        try authService.logout()
        AuthStateManager.shared.logout()
    } catch {
        print("❌ Logout error: \(error)")
    }
}

// AuthService.swift
func logout() throws {
    // Clear Keychain
    _ = keychainManager.deleteAccessToken()
    _ = keychainManager.deleteUserId()
    _ = keychainManager.deleteCompanyCode()

    // Clear UserDefaults (keep Remember Me if enabled)
    if !userDefaultsManager.getRememberMe() {
        userDefaultsManager.clearCredentials()
    }
    userDefaultsManager.clearUserInfo()

    // Clear NetworkManager
    networkManager.setAccessToken(nil)
    networkManager.setCompanyCode(nil)

    print("✅ [AuthService] User logged out successfully")
}
```

---

## 🔍 Debug Logging

Tüm servisler detaylı log mesajları içerir:

```swift
// ✅ Success logs
print("✅ [AuthService] Login successful, temp token saved")
print("✅ [AuthService] User info extracted from temp token: Satış Danışmanı")
print("✅ [NetworkManager] Request successful: /Authentication/login")

// ⚠️ Warning logs
print("⚠️ [HomeViewModel] No user info found in storage, extracting from token...")

// ❌ Error logs
print("❌ [AuthService] Login failed: Invalid credentials")
print("❌ [NetworkManager] Request failed: 401 Unauthorized")
```

**Log Formatı:** `[Emoji] [Component] Message`

---

## 🚨 Error Handling

### NetworkError

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case decodingError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .noData:
            return "Sunucudan veri alınamadı"
        case .unauthorized:
            return "Oturum süreniz dolmuş. Lütfen tekrar giriş yapın."
        case .forbidden:
            return "Bu işlem için yetkiniz bulunmuyor"
        case .notFound:
            return "İstenen kaynak bulunamadı"
        case .serverError(let code):
            return "Sunucu hatası (\(code))"
        case .decodingError:
            return "Veri işlenirken hata oluştu"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
```

### Kullanım

```swift
do {
    let response = try await networkManager.request(...)
} catch let networkError as NetworkError {
    // NetworkError'ı yakala
    self.error = networkError.errorDescription
} catch {
    // Diğer hataları yakala
    self.error = "Beklenmeyen bir hata oluştu"
}
```

---

## ✅ Best Practices

### 1. Token Yönetimi

✅ **DO:**
- Temp token'dan user info çıkart (fullName var)
- Access token'ı sadece API istekleri için kullan
- Token'ları Keychain'de sakla
- Logout'ta tüm token'ları temizle

❌ **DON'T:**
- Access token'dan fullName çıkartmaya çalışma
- Token'ları UserDefaults'a kaydetme
- Temp token'ı silmeyi unutma

### 2. Async/Await

✅ **DO:**
```swift
@MainActor
class ViewModel: ObservableObject {
    func loadData() async {
        do {
            let data = try await service.fetch()
            self.data = data  // Main thread'de UI güncellenir
        } catch {
            self.error = error.localizedDescription
        }
    }
}
```

❌ **DON'T:**
```swift
func loadData() {
    Task {
        let data = try await service.fetch()
        // ⚠️ Main thread'de değilsen UI güncellemesi crash verir
        self.data = data
    }
}
```

### 3. Error Handling

✅ **DO:**
- Özel error tiplerini catch et (`NetworkError`, `DecodingError`)
- Kullanıcı dostu mesajlar göster
- Debug için detaylı log yaz

❌ **DON'T:**
- Generic `catch` kullan
- Error mesajlarını ignore etme
- Kullanıcıya teknik hata gösterme

---

## 🎓 Sık Sorulan Sorular

### Q: Neden temp token'dan user info çıkartıyoruz?

**A:** Backend'in access token'ı sadece `sub` (encrypted subject) içeriyor. `unique_name` claim'i yok. Temp token ise tüm kullanıcı bilgilerini içeriyor (`unique_name`, `nameid`, `companyCode`). Bu yüzden login sırasında temp token'dan user info çıkartıp kaydediyoruz.

### Q: Access token ne zaman kullanılıyor?

**A:** Access token, OTP doğrulamasından sonra gelen **asıl authentication token**'dır. Tüm API isteklerinde `Authorization: Bearer {accessToken}` header'ında gönderiliyor. Kullanıcının kimliğini doğrulamak için kullanılıyor.

### Q: Remember Me nasıl çalışıyor?

**A:** Eğer kullanıcı "Beni Hatırla" seçeneğini işaretlerse:
1. `rememberMe = true` UserDefaults'a kaydedilir
2. `companyCode` ve `idNumber` UserDefaults'a kaydedilir
3. Uygulama açıldığında login formu bu değerlerle doldurulur
4. Şifre **asla** kaydedilmez (güvenlik)

### Q: Logout'ta hangi veriler silinir?

**A:**
- **Keychain:** accessToken, userId, companyCode (hepsi)
- **UserDefaults:** userInfo (silinir)
- **UserDefaults:** rememberMe, savedCompanyCode, savedIdNumber (korunur - Remember Me aktifse)
- **NetworkManager:** accessToken, companyCode (memory'den silinir)

### Q: Physical device'da localhost'a nasıl bağlanırız?

**A:**
1. Backend'i `0.0.0.0:8080` üzerinde dinlet (tüm network interface'lere açık)
2. Mac'in local IP'sini al (`ifconfig | grep "inet "`)
3. iOS'ta `http://{MAC_IP}:8080/api` kullan (örn: `http://192.168.1.101:8080/api`)
4. Info.plist'e `NSAllowsArbitraryLoads = true` ekle (development için)

---

## 📚 İlgili Dosyalar

- **Authentication:** `/Modules/Authentication/`
- **Profile:** `/Modules/Profile/`
- **Network Tests:** `/camlica360Tests/Network/`
- **API Documentation:** Backend README.md

---

**Version:** 1.0
**Last Updated:** 2025-10-19
**Maintained By:** Development Team
**Status:** Active ✅
