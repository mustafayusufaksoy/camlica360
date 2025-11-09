# 🚨 SON 5 ZORUNLU ALAN - HEMENDİ DOLDUR

## HEMEN UYGULA (5 alandan hangisini doldurmadığını kontrol et)

---

## ❌ ALAN 1: Content Rights Information

**Gidecek yer:**
```
App Store Connect
→ Apps
→ Camlica360
→ App Information (tab)
→ Aşağı scroll et → "Content Rights" bölümü
```

**Yapılacak:**

Soruda: "Does your app contain, require, or use any of the following?"

Seç:
```
✓ I own worldwide rights to all content in this app.
```

**KaydetE (Save button)** → Yeşil checkmark görüne kadar

---

## ❌ ALAN 2: Privacy Policy URL

**Gidecek yer:**
```
App Store Connect
→ Apps
→ Camlica360
→ App Privacy (tab) ← ÖNEMLI: App Information değil, App Privacy tab'ı
→ "Privacy Policy" bölümü
```

**Yapılacak:**

URL alanına gir:
```
https://crm.cmlc.com.tr/privacy-policy
```

⚠️ ÖNEMLİ: Bu URL ÇALIŞMAlı ve gerçek privacy policy text'i göstermeli!

Eğer henüz privacy policy sayfası yoksa, oluştur:

```
https://crm.cmlc.com.tr/privacy-policy

Sayfa içeriği (minimum):

---
Privacy Policy - Camlica360
Effective Date: October 2025

1. DATA COLLECTION
We collect employee data including:
- User credentials (email, employee ID)
- Business information (orders, leave requests, expenses)
- User-generated messages and notes

2. DATA USAGE
Data is used for:
- User authentication and authorization
- Business operations and management
- Service improvement
- Compliance with company data policies

3. DATA PROTECTION
- All data encrypted in transit (HTTPS/TLS)
- Passwords hashed and secured on backend
- Tokens stored securely in iOS Keychain
- Session timeout for security
- Role-based access control

4. DATA SHARING
- No sharing with third parties
- Only with Camlica CRM backend for essential operations
- Only with authorized company infrastructure

5. CONTACT
For privacy questions:
Email: abidin.ocal@camlica.com.tr

6. CHANGES
We may update this policy. Changes will be reflected
on this page with updated date.

---
```

**Kaydet** → Yeşil checkmark

---

## ❌ ALAN 3: Primary Category (Ana Kategori)

**Gidecek yer:**
```
App Store Connect
→ Apps
→ Camlica360
→ App Information (tab)
→ "Category" bölümü
```

**Yapılacak:**

"Primary Category" seç:
```
[✓] Business
```

Opsiyonel - "Secondary Category" (ikincil):
```
[ ] Productivity
```

**Kaydet** → Yeşil checkmark

---

## ❌ ALAN 4: Age Rating (Content Description) - ÖNEMLİ

**Gidecek yer:**
```
App Store Connect
→ Apps
→ Camlica360
→ App Information (tab)
→ Aşağı scroll et → "Age Rating" bölümü
```

**Yapılacak:**

Her soru için aşağıdaki cevapları seç. **HİÇBİRİNİ ATLAMA!**

```
VIOLENCE & SCARY CONTENT:

1. "Cartoons or Fantasy Violence"
   Seç: [✓] Does Not Require This

2. "Realistic Violence"
   Seç: [✓] Does Not Require This

3. "Graphic Violence"
   Seç: [✓] Does Not Require This

SEXUAL CONTENT & NUDITY:

4. "Sexual Content, Nudity, or Erotic Material"
   Seç: [✓] Does Not Require This

5. "Prolonged Sexual or Violent Content"
   Seç: [✓] Does Not Require This

PROFANITY OR CRUDE HUMOR:

6. "Frequent Profanity, Crude Humor"
   Seç: [✓] Does Not Require This

ALCOHOL, TOBACCO, OR DRUG USE:

7. "Alcohol or Tobacco Use"
   Seç: [✓] Does Not Require This

8. "Drug Use"
   Seç: [✓] Does Not Require This

GAMBLING:

9. "Gamification or Paid Loot Boxes"
   Seç: [✓] Does Not Require This

10. "Real Money Gambling"
    Seç: [✓] Does Not Require This

OTHER:

11. "Unrestricted Web Access"
    Seç: [✓] Does Not Require This

12. "User Generated Content"
    Seç: [✓] Infrequent/Mild
    (Çünkü mesajlar & notes user-generated)

13. "Medical/Health Information"
    Seç: [✓] Does Not Require This

14. "Realistic Information From News or Education"
    Seç: [✓] Does Not Require This
```

**SONUÇ:** Age Rating otomatik **4+** olacak

**Kaydet** → Yeşil checkmark

---

## ❌ ALAN 5: Privacy Practices (ÇOK ÖNEMLİ)

**Gidecek yer:**
```
App Store Connect
→ Apps
→ Camlica360
→ App Privacy (tab) ← ÖNEMLI TAB
→ "Data Collection & Privacy" bölümü
```

**Yapılacak (Admin olarak):**

### 5.1 Privacy Policy URL (tekrar)
```
https://crm.cmlc.com.tr/privacy-policy
```

### 5.2 Data Collection Question

```
"Does your app collect user data?"

Seç: [✓] Yes
```

### 5.3 Data Types - TÜMÜNÜ DOLDUR

```
☑ CONTACT INFO
  ☑ Name - Required
  ☑ Email Address - Required
  ☑ Phone Number - Required
  ☐ Physical Address

  Purpose: User identification and contact
  Legal Basis: Contractual Necessity
  Privacy Policy: Yes

☑ USER ID
  ☑ User ID - Required

  Purpose: Employee identification
  Legal Basis: Contractual Necessity

☑ FINANCIAL INFO
  ☐ Payments
  ☐ Purchases
  ☐ Credit info

☐ LOCATION DATA
  ☐ Precise
  ☐ Coarse

☐ SENSITIVE INFO
  ☐ Health
  ☐ Biometric

☑ PHOTOS & VIDEOS
  ☐ Photos (Optional - for receipts)
  ☐ Videos

☐ AUDIO

☑ USER-GENERATED CONTENT
  Purpose: Internal communication
  Legal Basis: Contractual Necessity

☑ CRASH DATA (if enabled)
  Purpose: App stability
  Legal Basis: Legitimate interest
```

### 5.4 Data Retention

```
"How long do you retain this data?"

Seç: [✓] Until user deletes account / as long as active
```

### 5.5 Data Sharing

```
"Do you share user data with third parties?"

Seç: [✓] No
  (OR: "Only with Camlica CRM backend for operations")
```

### 5.6 Data Security

```
Encrypt in transit: [✓] Yes (HTTPS)
Encrypt at rest: [✓] Yes (Keychain)
Authentication: [✓] OAuth2
Session management: [✓] Yes
```

### 5.7 Contact Information

```
Email: abidin.ocal@camlica.com.tr
Name: Abidin Ocal
```

**Kaydet** → Yeşil checkmark

---

## ✅ KONTROL LISTESI - HEPSİNİ KONTROL ET

App Store Connect'te hepsinin yanında yeşil checkmark olmalı:

```
[ ] Content Rights Information ...................... ✓ yeşil
[ ] Privacy Policy URL .............................. ✓ yeşil
[ ] Primary Category (Business) ..................... ✓ yeşil
[ ] Age Rating (4+) ................................. ✓ yeşil
[ ] Privacy Practices ............................... ✓ yeşil

HATA MESAJI YOK
```

---

## 🎯 AFTER - SONRA NE OLACAK?

Hepsi doldurulduktan sonra:

```
1. App Store Connect sayfayı yenilemesini bekle (F5)
2. "Submit for Review" butonu aktif olacak (artık grayed out olmayacak)
3. Build seçimi yap (TestFlight build)
4. Beta review notes'ı doldur
5. Submit for Review'ye basıl
6. Apple 2-24 saat içinde review yapacak
```

---

## 🔴 EĞER HALA HATA VARSA

Aşağıdakileri kontrol et:

```
[ ] Privacy Policy URL tam olarak yazıldı mı?
    https://crm.cmlc.com.tr/privacy-policy

[ ] Age Rating'de TÜM soruları cevapladın mı?
    (Hiçbirini atlama!)

[ ] Privacy Practices'de contact info doğru mu?
    abidin.ocal@camlica.com.tr

[ ] Primary Category seçildi mi?
    Business

[ ] Content Rights "I own" seçildi mi?
```

Hepsi ✓ ise, sayfayı yenile (F5) ve submit butonu aktif olmalı.

---

## 📝 PRIVACY POLICY SAYFASI - TEMPLATE

Eğer sayfa hazır değilse, şunu kopyala ve sunucuya koy:

**URL:** `https://crm.cmlc.com.tr/privacy-policy`

**HTML/Content:**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Privacy Policy - Camlica360</title>
</head>
<body>
    <h1>Privacy Policy - Camlica360</h1>
    <p><strong>Effective Date:</strong> October 2025</p>

    <h2>1. Data Collection</h2>
    <p>Camlica360 collects the following user data:</p>
    <ul>
        <li>Employee credentials (email, ID number)</li>
        <li>Business information (orders, leave requests, expenses)</li>
        <li>User-generated messages and notes</li>
        <li>Company and organizational data</li>
    </ul>

    <h2>2. Data Usage</h2>
    <p>We use this data for:</p>
    <ul>
        <li>User authentication and authorization</li>
        <li>Business operations and management</li>
        <li>Service delivery and improvement</li>
        <li>Compliance with company policies</li>
    </ul>

    <h2>3. Data Protection</h2>
    <p>Your data is protected through:</p>
    <ul>
        <li>HTTPS encryption in transit</li>
        <li>Secure password hashing</li>
        <li>iOS Keychain for token storage</li>
        <li>Automatic session timeout</li>
        <li>Role-based access control</li>
    </ul>

    <h2>4. Data Sharing</h2>
    <p>We do not share user data with third parties.
    Data is only sent to Camlica CRM backend for essential business operations.</p>

    <h2>5. Your Rights</h2>
    <p>You have the right to:</p>
    <ul>
        <li>Access your personal data</li>
        <li>Request data correction</li>
        <li>Request account deletion</li>
        <li>File a complaint with relevant authorities</li>
    </ul>

    <h2>6. Contact</h2>
    <p>For privacy questions, contact:</p>
    <p>Email: <a href="mailto:abidin.ocal@camlica.com.tr">abidin.ocal@camlica.com.tr</a></p>

    <h2>7. Changes to This Policy</h2>
    <p>We may update this policy periodically.
    Changes will be reflected on this page with an updated effective date.</p>

    <hr>

    <h1>Gizlilik Politikası - Camlica360</h1>
    <p><strong>Yürürlük Tarihi:</strong> Ekim 2025</p>

    <h2>1. Veri Toplama</h2>
    <p>Camlica360 aşağıdaki kullanıcı verilerini toplar:</p>
    <ul>
        <li>Çalışan kimlik bilgileri (e-posta, ID numarası)</li>
        <li>İşletme bilgileri (siparişler, izin talepleri, giderler)</li>
        <li>Kullanıcı tarafından oluşturulan mesajlar ve notlar</li>
        <li>Şirket ve organizasyon verileri</li>
    </ul>

    <h2>2. Veri Kullanımı</h2>
    <p>Bu veriler şu amaçlarla kullanılır:</p>
    <ul>
        <li>Kullanıcı kimlik doğrulama ve yetkilendirme</li>
        <li>İşletme operasyonları ve yönetimi</li>
        <li>Hizmet sağlama ve iyileştirme</li>
        <li>Şirket politikaları ile uyum</li>
    </ul>

    <h2>3. Veri Koruması</h2>
    <p>Verileriniz aşağıdakiler aracılığıyla korunur:</p>
    <ul>
        <li>Transmisyonda HTTPS şifrelemesi</li>
        <li>Şifre karma işlemi</li>
        <li>iOS Keychain'de token depolaması</li>
        <li>Otomatik oturum zaman aşımı</li>
        <li>Rol tabanlı erişim kontrolü</li>
    </ul>

    <h2>4. Veri Paylaşımı</h2>
    <p>Kullanıcı verilerini üçüncü taraflarla paylaşmayız.
    Veriler sadece gerekli iş operasyonları için Camlica CRM sunucusuna gönderilir.</p>

    <h2>5. İletişim</h2>
    <p>Gizlilik soruları için:</p>
    <p>E-posta: <a href="mailto:abidin.ocal@camlica.com.tr">abidin.ocal@camlica.com.tr</a></p>
</body>
</html>
```

---

## 🚀 SON ADIM

Hepsi doldurulduktan sonra:

```
1. Sayfayı yenile (F5)
2. "Submit for Review" butonu kontrol et (artık aktif olmalı)
3. Build seç
4. Beta notes ekle
5. Submit'e basıl
```

**Başarıyla tamamlandı mı?**
Bana haber ver, sonra demo account ve screenshots'a geçeceğiz.

---

**Document:** Final 5 Required Fields
**Time to Complete:** ~15 minutes
**Status:** Critical - Must complete before submission
