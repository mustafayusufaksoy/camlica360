# App Store Review'a Başlamak İçin Gerekli Alanlar

## ❌ Eksik Alanlar (Hemen doldurulmalı)

```
[ ] Content Rights Information - App Information bölümünde ayarla
[ ] Privacy Policy URL - App Privacy bölümünde gir
[ ] Primary Category - Seç
[ ] Age Rating (Content Descriptions) - Tüm kategorileri doldur
[ ] Privacy Practices - App Privacy section'ında admin olarak gir
[ ] Price Tier - Pricing section'ında seç
```

---

## 1. CONTENT RIGHTS INFORMATION

**Açık:** App Store Connect → Apps → Camlica360 → App Information

**Bölüm:** Content Rights

```
Question: Does your app contain, require, or use any of the following?

Select one option:

✓ I own worldwide rights to all content in this app.
  OR
  This app does not contain any content that I did not create or have rights to.
```

**SEÇILECEK:**
```
[✓] I own worldwide rights to all content in this app.
```

**KAYDET**

---

## 2. PRIVACY POLICY URL

**Açık:** App Store Connect → Apps → Camlica360 → App Privacy

**Bölüm:** Privacy Policy

```
Privacy Policy URL:
https://crm.cmlc.com.tr/privacy-policy
```

⚠️ ÖNEMLİ: Bu URL çalışmalı ve gerçek privacy policy'yi göstermeli!

Eğer privacy policy hazırlanmadıysa, şunu kullanabilirsin:

```
Template:
https://crm.cmlc.com.tr/privacy-policy
```

**KAYDET**

---

## 3. PRIMARY CATEGORY (Ana Kategori)

**Açık:** App Store Connect → Apps → Camlica360 → App Information

**Bölüm:** Category

**Seçenekler:**

```
RECOMMENDED FOR THIS APP:

Primary Category:
[✓] Business

Secondary Category (optional):
    Productivity
```

**Neden Business?**
- Bu bir enterprise CRM uygulaması
- İşletme yönetim aracı
- B2B uygulaması
- Kurumsal kullanıcılar için

**KAYDET**

---

## 4. AGE RATING (Yaş Değerlendirmesi)

**Açık:** App Store Connect → Apps → Camlica360 → App Information

**Bölüm:** Age Rating

### Content Description - Tüm soruları cevapla

Aşağıdaki her soru için **"Infrequent/Mild" (Az Sık/Hafif)** veya **"Does Not Require This"** seç:

```
VIOLENCE & SCARY CONTENT:

[ ] Cartoons or Fantasy Violence
    Seç: Does Not Require This

[ ] Realistic Violence
    Seç: Does Not Require This

[ ] Graphic Violence
    Seç: Does Not Require This

SEXUAL CONTENT & NUDITY:

[ ] Sexual Content, Nudity, or Erotic Material
    Seç: Does Not Require This

[ ] Prolonged Sexual or Violent Content
    Seç: Does Not Require This

PROFANITY OR CRUDE HUMOR:

[ ] Infrequent/Mild
    Seç: Does Not Require This

[ ] Frequent/Intense
    Seç: Does Not Require This

ALCOHOL, TOBACCO, OR DRUG USE:

[ ] Alcohol or Tobacco Use
    Seç: Does Not Require This

[ ] Drug Use
    Seç: Does Not Require This

GAMBLING:

[ ] Gamification or Paid Loot Boxes
    Seç: Does Not Require This

[ ] Real Money Gambling
    Seç: Does Not Require This

OTHER:

[ ] Unrestricted Web Access
    Seç: Does Not Require This

[ ] User Generated Content
    Seç: Infrequent/Mild
    (Çünkü mesajlar ve notes user-generated)

[ ] Medical/Health Information
    Seç: Does Not Require This
```

### Recommended Age Rating:

```
Age Rating: 4+
(Business app, no objectionable content)
```

**KAYDET**

---

## 5. PRIVACY PRACTICES (App Privacy - ÖNEMLİ)

**Açık:** App Store Connect → Apps → Camlica360 → App Privacy

**Bölüm:** Data Collection & Privacy

### Admin olarak Gir (Requires Admin Access)

#### Privacy Policy URL (tekrar):
```
https://crm.cmlc.com.tr/privacy-policy
```

#### Data Collection Section:

Sorular:
```
1. Does your app collect user data?

   [✓] Yes

   Reason: Business app collects employee/company data
```

#### Data Types Section:

**Collect the following data types:**

```
[ ] Contact Info
    [✓] Name - Required
    [✓] Email address - Required
    [✓] Phone number - Required
    [ ] Physical address - No

    Purpose: User identification and contact
    Legal basis: Contractual necessity
    Privacy policy: Yes

[ ] User ID
    [✓] User ID - Required

    Purpose: Employee identification
    Legal basis: Contractual necessity

[ ] Financial Info
    [ ] Payment info - No (backend handles)
    [ ] Credit score - No
    [ ] Purchase history - No

[ ] Location
    [ ] Precise location - No
    [ ] Coarse location - No

[ ] Sensitive Info
    [ ] Health - No
    [ ] Biometric - No
    [ ] Payment method - No (backend)

[ ] Photos & Videos
    [ ] Photos - Maybe (for receipts/documents)
    [ ] Videos - No

[ ] Audio
    [ ] Audio files - No
    [ ] Voicemails - No

[ ] Search History
    [ ] Search history - No

[ ] Browsing History
    [ ] Browsing history - No

[ ] User-Generated Content
    [✓] Yes

    Types: Messages, notes, expense descriptions
    Purpose: Internal communication
    Legal basis: Contractual necessity

[ ] Crash Data
    [✓] Yes (if crash reporting enabled)

    Purpose: App stability
    Legal basis: Legitimate interest

[ ] Other Data
    [ ] Device ID - No
    [ ] Cookies - No
```

#### Data Retention:

```
How long do you retain user data?

[✓] Until user deletes account
    OR
[✓] As long as user has active account
```

#### Data Sharing:

```
Do you share user data with third parties?

[✓] No
    (Only with Camlica backend API)

OR

[ ] Yes - explain:
    "Only with authorized Camlica CRM backend
     for essential business functions"
```

#### Data Security:

```
How is user data encrypted?

[✓] Yes
    - In transit: HTTPS/TLS
    - At rest: Keychain (iOS)
    - Authentication: OAuth2 + JWT
```

#### Contact Info for Privacy Questions:

```
Email: abidin.ocal@camlica.com.tr
Name: Abidin Ocal
```

**KAYDET**

---

## 6. PRICING (Fiyatlandırma)

**Açık:** App Store Connect → Apps → Camlica360 → Pricing and Availability

**Bölüm:** Pricing

### Price Tier Seç:

```
FREE APPLICATION

[✓] Free
    OR
[ ] Paid - $0.99 to $999.99

RECOMMENDED: FREE
(Enterprise B2B app, usually free for employees)
```

### Regions:

```
Select which countries to make available:

[✓] All countries/regions
    OR
[ ] Select countries

RECOMMENDED: All countries
(Türkiye + Uluslararası işletmeler)
```

### Availability Date:

```
When should your app be available?

[✓] Immediately after approval
    OR
[ ] Set specific date
```

**KAYDET**

---

## 📋 FINAL CHECKLIST

```
CONTENT RIGHTS:
[ ] "I own worldwide rights" seçildi

PRIVACY:
[ ] Privacy Policy URL girildi
[ ] Data collection tüm alanlar dolduruldu
[ ] Contact info eklendi
[ ] Hepsi kaydedildi (✓ yeşil)

CATEGORY:
[ ] Primary: Business
[ ] Secondary: Productivity (optional)

AGE RATING:
[ ] Tüm content descriptions dolduruldu
[ ] Rating: 4+ (recommended)

PRICING:
[ ] Free seçildi
[ ] All regions/countries seçildi
[ ] Saved

KONTROL:
[ ] Hata yok
[ ] Tüm alanlar yeşil
[ ] "Ready to Submit" gösteriliyor
```

---

## ⏭️ SONRA NE?

Tüm alanlar dolduğunda:

```
1. Bir kez daha hepsini kontrol et
2. "Submit for Review" butonuna basıl
3. Review reason'u seç:
   - "New app release"
4. Gönder

Apple 2-24 saat içinde review yapacak
```

---

## 🔗 PRIVACY POLICY TEMPLATE

Eğer privacy policy sayfası yoksa, şunu oluştur:

```html
https://crm.cmlc.com.tr/privacy-policy

CONTENT:

Privacy Policy - Camlica360

Effective Date: October 2025

1. DATA COLLECTION
We collect the following data:
- User credentials (email, ID)
- Business information (orders, leaves, expenses)
- User-generated messages and notes

2. DATA USAGE
Data is used for:
- User authentication
- Business operations
- Service improvement
- Compliance with company policies

3. DATA PROTECTION
- All data encrypted in transit (HTTPS)
- Passwords hashed and secured
- Tokens stored securely in iOS Keychain
- Session timeout for security

4. DATA SHARING
- No sharing with third parties
- Only with Camlica CRM backend
- Only for essential business functions

5. CONTACT
For privacy questions:
Email: abidin.ocal@camlica.com.tr

6. CHANGES
We may update this policy. Changes will be
reflected on this page with updated date.

---

Turkish Version / Türkçe Sürüm

Gizlilik Politikası - Camlica360

...
[Same content in Turkish]
```

---

## 🎯 ADIM ADIM KONTROL

1. **Content Rights** → "I own worldwide rights" ✓
2. **Privacy Policy URL** → https://crm.cmlc.com.tr/privacy-policy ✓
3. **Category** → Business ✓
4. **Age Rating** → 4+ with all "Does Not Require" ✓
5. **Privacy Data** → All sections filled ✓
6. **Pricing** → Free ✓

Hepsi yeşil olunca → **"Submit for Review"** ✓

---

**Status:** Ready to Submit
**Date:** October 27, 2025
**Next:** After filling these fields, app can go to TestFlight review
