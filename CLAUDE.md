# 📱 Camlica360 iOS Project Architecture

Bu belge, Camlica360 iOS projesinin genel yapısını, mimarisini ve geliştirme standartlarını açıklar. AI asistanları ve geliştiricilerin projeyi anlamalarına yardımcı olur.

## 🎯 Proje Özeti

**Proje Adı:** Camlica360
**Platform:** iOS (SwiftUI)
**Mimarı:** MVVM (Model-View-ViewModel) + Modüler Yapı
**Diller:** Swift
**Desteklenen Diller:** English (en), Turkish (tr)
**Minimum Deployment:** iOS 15.0+

## 📂 Klasör Yapısı

```
camlica360/
├── App/                           # Uygulama entry point
│   ├── camlica360App.swift        # App delegate ve scene setup
│   └── AppDelegate.swift          # App lifecycle (isteğe bağlı)
│
├── Core/                          # Paylaşılan core functionality
│   ├── Network/                   # API networking
│   │   ├── NetworkManager.swift   # HTTP client
│   │   ├── Endpoint.swift         # API endpoints
│   │   └── NetworkError.swift     # Error handling
│   │
│   ├── Storage/                   # Veri depolama
│   │   ├── UserDefaultsManager.swift
│   │   ├── KeychainManager.swift  # Güvenli depolama
│   │   └── CoreDataManager.swift  # (isteğe bağlı)
│   │
│   ├── Utils/                     # Utility fonksiyonları
│   │   ├── Extensions/            # Swift extensions
│   │   │   ├── String+Extensions.swift
│   │   │   ├── String+Localization.swift
│   │   │   ├── View+Extensions.swift
│   │   │   ├── Color+Extensions.swift
│   │   │   └── Date+Extensions.swift
│   │   │
│   │   ├── Validators/            # Doğrulama fonksiyonları
│   │   │   └── Validator.swift
│   │   │
│   │   └── Constants/             # Sabitler
│   │       ├── AppConstants.swift
│   │       ├── APIConstants.swift
│   │       └── LocalizationKeys.swift
│   │
│   └── DependencyInjection/       # DI container
│       └── DIContainer.swift
│
├── Resources/                     # Tüm kaynaklar (merkezden yönetim)
│   ├── Theme/                     # Tema yönetimi
│   │   ├── Colors.swift           # Renk paleti
│   │   ├── Fonts.swift            # Font tanımları
│   │   ├── Images.swift           # Image assets
│   │   └── Spacing.swift          # Layout spacing
│   │
│   ├── Localization/              # Çoklangdılı destek
│   │   ├── README.md              # Localization rehberi
│   │   ├── Localizable.xcstrings  # Strings Catalog (EN/TR)
│   │   ├── en.lproj/              # English resources
│   │   └── tr.lproj/              # Turkish resources
│   │
│   └── Assets.xcassets/           # Xcode asset catalog
│
├── Modules/                       # Feature modules (MVVM)
│   ├── Authentication/            # Auth feature
│   │   ├── Views/                 # SwiftUI views
│   │   │   ├── LoginView.swift
│   │   │   └── RegisterView.swift
│   │   │
│   │   ├── ViewModels/            # Business logic
│   │   │   ├── LoginViewModel.swift
│   │   │   └── RegisterViewModel.swift
│   │   │
│   │   ├── Models/                # Data models
│   │   │   └── User.swift
│   │   │
│   │   └── Services/              # API/data services
│   │       └── AuthService.swift
│   │
│   ├── Home/                      # Home feature
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   └── Services/
│   │
│   └── Profile/                   # Profile feature
│       ├── Views/
│       ├── ViewModels/
│       ├── Models/
│       └── Services/
│
├── Common/                        # Paylaşılan components
│   ├── Components/                # Reusable UI components
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   └── SecondaryButton.swift
│   │   │
│   │   ├── TextFields/
│   │   │   └── CustomTextField.swift
│   │   │
│   │   ├── Cards/
│   │   │   └── CardView.swift
│   │   │
│   │   └── LoadingViews/
│   │       └── LoadingView.swift
│   │
│   ├── Modifiers/                 # View modifiers
│   │   └── CustomViewModifiers.swift
│   │
│   └── Protocols/                 # Shared protocols
│       └── ViewModelProtocol.swift
│
└── Navigation/                    # Navigation yönetimi
    ├── Coordinator.swift          # Navigation coordinator
    ├── Router.swift               # Route handler
    └── DeepLinkHandler.swift      # Deep link handling
```

## 🏗️ Mimari Desen: MVVM

Her module MVVM paternini takip eder:

```
View (SwiftUI)
    ↓
ViewModel (@ObservedObject)
    ↓
Model + Service
    ↓
Network/Storage/Core
```

### Model Örneği:
```swift
// Modules/Authentication/Models/User.swift
struct User: Codable {
    let id: Int
    let email: String
    let name: String
}
```

### ViewModel Örneği:
```swift
// Modules/Authentication/ViewModels/LoginViewModel.swift
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?

    private let authService: AuthService

    func login() async {
        // Business logic
    }
}
```

### View Örneği:
```swift
// Modules/Authentication/Views/LoginView.swift
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            TextField(LocalizationKeys.emailPlaceholder.localized, text: $viewModel.email)
            // UI code
        }
    }
}
```

## 🎨 Theme & Styling

Tüm renkler, fontlar ve spacing **Resources/Theme** klasöründe merkezden yönetilir:

```swift
// Kullanım örneği:
Text("Hello")
    .font(AppFonts.bold(size: 18))
    .foregroundColor(AppColors.primary)
    .padding(AppSpacing.md)
```

## 🌍 Localization

Modern **Strings Catalog** (.xcstrings) kullanılır:

```swift
// Basit kullanım:
Text("login_title".localized)

// Constants ile (önerilen):
Text(LocalizationKeys.loginTitle.localized)

// Detaylı bilgi: Resources/Localization/README.md
```

## 📋 Kod Standartları

### Naming Convention

#### Dosya ve Klasörleri:
- **PascalCase** kullan: `LoginView.swift`, `AuthService.swift`
- Suffix ekle: `ViewModel`, `View`, `Service`, `Model`
- Örnek: `LoginViewModel.swift`, `AuthService.swift`

#### Kod İçinde:
- Değişkenler: `camelCase` → `userName`, `isLoading`
- Constants: `UPPER_SNAKE_CASE` (enum içinde capitalize)
- Functions: `camelCase` → `fetchUser()`, `validateEmail()`

#### String Keys:
- `snake_case` kullan: `login_title`, `error_invalid_email`
- Kategori_Subcategory_Action_Object: `auth_login_button_text`

### Kod Organizasyonu

```swift
class MyViewController {
    // MARK: - Properties
    private var data: Data

    // MARK: - Lifecycle
    init() {}

    // MARK: - Public Methods
    func publicMethod() {}

    // MARK: - Private Methods
    private func privateMethod() {}
}
```

### Error Handling

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
```

## 🔄 Module Ekleme Adımları

Yeni bir feature module eklemek için:

```
1. Modules/ altında klasör oluştur: Modules/NewFeature/
2. Alt klasörleri ekle: Views/, ViewModels/, Models/, Services/
3. Models oluştur
4. Service oluştur (API/Data işlemleri için)
5. ViewModel oluştur (@MainActor, @ObservedObject)
6. View oluştur (SwiftUI)
7. Navigation/Coordinator'a ekle
```

## 🧪 Testing Structure

```
camlica360Tests/
├── ViewModels/
│   └── LoginViewModelTests.swift
├── Services/
│   └── AuthServiceTests.swift
├── Models/
│   └── UserTests.swift
└── Mocks/
    └── MockAuthService.swift
```

## 📦 Dependency Injection

DIContainer kullanarak dependencies yönet:

```swift
class DIContainer {
    static let shared = DIContainer()

    func makeAuthService() -> AuthService {
        return AuthService(networkManager: NetworkManager.shared)
    }
}
```

## 🚀 Best Practices

✅ **DO:**
- Her modülü bağımsız tutmaya çalış
- Protokol kullan (extension ve mocking için)
- Core kütüphaneleri (Network, Storage) kullan
- String'ler için LocalizationKeys kullan
- Theme color/font kullan
- Error handling yap
- Async/await kullan (URLSession işlemleri için)
- @MainActor ekle (UI güncellemeleri için)

❌ **DON'T:**
- Hardcoded string'ler yazma
- Modüller arası direct import (Service aracılığı kullan)
- ViewModels arasında data paylaş (SharedViewModel kullan)
- Magic numbers ve hex colors kullan
- Spaghetti code yapı
- `@StateObject` ViewModeline dışarıdan dependency geçme
- Blocking network calls (async/await kullan)

## 🔗 Core Utilities Kullanımı

### String Extensions
```swift
let localized = "login_title".localized
let formatted = "Hello, %@".localized(with: "John")
```

### Color Extensions
```swift
let color = Color(hex: "#FF5733")
```

### Date Extensions
```swift
let formatted = Date().formatted(with: "dd/MM/yyyy")
```

## 🐛 Debugging Tips

1. **Network Debug:** Interceptor kullan, request/response log et
2. **State Debug:** ViewModel'deki @Published değerleri debug et
3. **Navigation Debug:** DeepLinkHandler test et
4. **Localization Debug:** Xcode Settings → Debug Effective User Defaults

## 📚 İlgili Belgeler

- [Localization Guide](camlica360/Resources/Localization/README.md)
- [Theme Configuration](camlica360/Resources/Theme/)
- Test belgesi (yakında)
- API Documentation (yakında)

## 🔄 Git Workflow

```
main (production)
  ↓
dev (development branch)
  ↓
feature/feature-name (feature branches)
  ↓
Commit message: "feat: add login functionality"
```

### Commit Mesajı Formatı
```
feat: new feature
fix: bug fix
refactor: refactoring
docs: documentation
test: tests
style: formatting
```

## 📞 Sorular & İletişim

- **Mimari sorular:** Architecture Decision Records (ADR) için docs/ klasörüne bakınız
- **Style sorular:** Bu belgeyi kontrol edin
- **Feature requests:** Takım ile koordinasyon yapın

---

**Version:** 1.0
**Last Updated:** 2025-10-18
**Maintained By:** Development Team
**Status:** Active
