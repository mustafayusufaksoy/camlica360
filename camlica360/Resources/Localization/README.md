# 🌍 Localization Guide

Bu klasör, uygulamanın tüm çok dilli desteklerini (Localization) yönetir. Modern **Strings Catalog** (`xcstrings`) yöntemi kullanılmaktadır.

## 📋 Desteklenen Diller

- 🇬🇧 **English** (en)
- 🇹🇷 **Turkish** (tr)

## 📁 Dosya Yapısı

```
Localization/
├── README.md                          # Bu dosya
├── Localizable.xcstrings              # TÜM localization strings (tek dosya)
├── en.lproj/                          # İngilizce kaynakları (varsa)
└── tr.lproj/                          # Türkçe kaynakları (varsa)
```

## 🎯 Strategy: Physical vs. Logical Organization

**Physical:** Tek `Localizable.xcstrings` dosyası (Apple best practice)
**Logical:** `LocalizationKeys.swift` enum'da MARK commentleriyle organize

### Neden Tek Dosya?

- ✅ Xcode'un native `.xcstrings` desteği tek dosya ile çalışır
- ✅ NSLocalizedString otomatik okur (tableName parametresi gerekmez)
- ✅ Preview ve runtime'da hemen çalışır
- ✅ Daha az complexity

### Modüler Organizasyon Nasıl?

Kod tarafında `LocalizationKeys.swift` enum'u kategorilere ayrılmıştır:

```swift
enum LocalizationKeys: String {
    // MARK: - Common
    case ok = "common_ok"
    case cancel = "common_cancel"

    // MARK: - Authentication - Login
    case loginWelcome = "auth_login_welcome"
    case loginButton = "auth_login_button"
}
```

## 🎯 Kullanım

### 1. **Strings Ekleme - Xcode GUI**

`Localizable.xcstrings` dosyasını Xcode'da açın:

```
1. Xcode → File Navigator
2. Resources/Localization/Localizable.xcstrings (double-click)
3. Arayüzde "+" butonuna tıkla
4. İngilizce metni gir
5. Türkçe çevirisi otomatik eklenir
```

### 2. **Kod'da String Kullanma**

#### Seçenek A: Direct String (En Basit)
```swift
import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            Text("login_title".localized)
            TextField("email_placeholder".localized, text: $email)
        }
    }
}
```

#### Seçenek B: Constants ile (Önerilen - Type-Safe)
```swift
import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            Text(LocalizationKeys.loginTitle.localized)
            TextField(LocalizationKeys.emailPlaceholder.localized, text: $email)
        }
    }
}
```

#### Seçenek C: Format Arguments
```swift
let userName = "Ahmet"
let message = "Hello, %@".localized(with: userName)
// Output: "Hello, Ahmet" (EN) / "Merhaba, Ahmet" (TR)
```

## ➕ Yeni String Ekleme Adımları

### Step 1: Localizable.xcstrings'e Ekle
Xcode'da `Localizable.xcstrings` dosyasını aç ve yeni string ekle:

```json
"auth_feature_new_key" : {
  "extractionState" : "manual",
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "English text"
      }
    },
    "tr" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Türkçe metin"
      }
    }
  }
}
```

### Step 2: LocalizationKeys.swift'e Ekle
`Core/Utils/Constants/LocalizationKeys.swift` dosyasında doğru MARK kategorisine ekle:

```swift
// MARK: - Authentication - New Feature
case authFeatureNewKey = "auth_feature_new_key"
```

### Step 3: Kod'da Kullan
Type-safe şekilde kullan:
```swift
Text(LocalizationKeys.authFeatureNewKey.localized)
```

## 📋 String Kategorileri

Strings Catalog'daki string'ler kategorilere ayrılmıştır:

```
🔹 Common          → Genel kullanılan string'ler
🔹 Authentication  → Giriş/Kayıt ilgili
🔹 Errors          → Hata mesajları
🔹 Validation      → Doğrulama mesajları
```

## 🎨 Best Practices

✅ **DO:**
- Key isimleri `snake_case` kullan: `welcome_message`
- Kategorilere ayır: `auth_login_title`, `error_invalid_email`
- Xcode GUI'den düzenle
- `LocalizationKeys` enum'ı kullan
- String'lerin sonuna translatable olup olmadığını belirt

❌ **DON'T:**
- Hardcoded string'ler yazma
- Key isimleri rastgele belirleme
- View'lar içinde format string'leri yazma

## 🔤 String Key Naming Convention

```
category_subcategory_action_object

Örnekler:
✅ auth_login_email_placeholder
✅ auth_register_button_text
✅ error_network_timeout
✅ error_invalid_email
✅ profile_settings_language_title
```

## 🧪 Cihazda Dil Değiştirme

**Simulator'de:**
```
Settings → General → Language & Region → iPhone Language → Türkçe/English
```

**Gerçek Cihazda:**
```
Settings → General → Language & Region → iPhone Language → Türkçe/English
```

## 🔄 Pluralization ve Format

Eğer plural kurallarına ihtiyaç varsa:

```swift
// Localizable.xcstrings içinde:
{
  "items_count" : {
    "extractionState" : "manual",
    "localizations" : {
      "en" : {
        "variations" : {
          "plural" : {
            "one" : {
              "stringUnit" : {
                "state" : "translated",
                "value" : "%d item"
              }
            },
            "other" : {
              "stringUnit" : {
                "state" : "translated",
                "value" : "%d items"
              }
            }
          }
        }
      }
    }
  }
}
```

## 📚 Referanslar

- **String+Localization.swift** - Extension fonksiyonları
- **LocalizationKeys.swift** - Tüm key'ler burada

## 🐛 Troubleshooting

**Problem:** String gösterilmiyor, sadece key görünüyor
- ✅ `Localizable.xcstrings` dosyasını kontrol et
- ✅ Target membership ayarlarını kontrol et
- ✅ Build → Clean Build Folder yap

**Problem:** Yeni string'ler görünmüyor
- ✅ Uygulamayı rebuild et
- ✅ Simulator'ı restart et

---

**Version:** 1.0
**Last Updated:** 2025-10-18
**Maintained By:** Development Team
