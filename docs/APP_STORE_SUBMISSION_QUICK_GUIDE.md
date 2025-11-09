# 🚀 App Store Submission - Hızlı Kılavuz

## 📋 ADIM 1: Demo Kullanıcı Oluştur

CRM sisteminizde aşağıdaki bilgilerle bir test kullanıcısı oluşturun:

```
Şirket Kodu (Company Code): DEMO
Çalışan ID (ID Number): 12345
Adı: Abidin Öcal
Parolası: Demo@123456
Rol: Çalışan (Employee)
```

⚠️ **ÖNEMLİ:** Kullanıcının tüm app özelliklerine erişimi olmalı:
- ✅ Giriş yapabilmeli
- ✅ OTP doğrulama alabilmeli
- ✅ İzin taleplerini görebilmeli
- ✅ Profil bilgilerini görebilmeli

---

## 📱 ADIM 2: App Store Connect'te Bilgileri Gir

### App Metadata (Bilgiler)

| Alan | Türkçe | İngilizce |
|------|--------|----------|
| **App Adı** | Camlica360 | Camlica360 |
| **Subtitle** | İK Yönetimi ve İzin Talepleri | HR Management & Leave Request |

### Promotional Text (Tanıtım Metni)

**Türkçe:**
```
İzin taleplerini kolay yönetin. Şirkete bağlı kalın, izin durumunu kontrol edin ve tüm HR işlemlerini bir yerde yapın.
```

**İngilizce:**
```
Manage your HR requests efficiently on the go. Request leave, check approvals, and track your benefits all in one place.
```

### Description (Açıklama)

➡️ **Bkz:** `APP_STORE_REVIEW_INFO.md` dosyasının **Section 3** - Tam açıklamalar İngilizce ve Türkçe

Özet olarak şunları içermeli:
- ✓ Uygulamanın ne yaptığı
- ✓ Temel özellikleri (Login, Leave Request, Approvals, Charts, Profile)
- ✓ Hedef kitle (Çalışanlar ve Yöneticiler)
- ✓ Desteklenen diller (EN, TR)

### Keywords (Anahtar Kelimeler)

**Türkçe:**
```
insan kaynakları yönetimi, izin talebi, çalışan avantajları, devamsızlık, tatil, hastalık izni, onay, bordro, iş gücü, planlama
```

**İngilizce:**
```
hr management, leave request, employee benefits, absence, vacation, sick leave, approval, payroll, workforce, schedule, attendance
```

### Support URL
```
https://crm.cmlc.com.tr/
```

### Marketing URL
```
https://crm.cmlc.com.tr/
```

### Copyright
```
© 2025 Camlica360. All rights reserved.
```

---

## 🔑 ADIM 3: Beta App Review Information (En Önemli Adım!)

### ✅ "Sign-in required" kutusunu işaretle

### Demo Account Information gir:

```
Username (Kullanıcı Adı):
DEMO_12345

Password (Parola):
Demo@123456
```

**Veya ayrı ayrı:**
```
Company Code: DEMO
ID Number: 12345
Password: Demo@123456
```

### Notes (Notlar) - Aşağıdaki metni ekle:

```
DEMO ACCOUNT CREDENTIALS

Company: Camlica (Demo)
User: Abidin Öcal
Role: Employee

To Test:
1. Login with provided credentials
2. Verify OTP (check email/SMS or use test OTP if provided)
3. Browse Home, İzinler (Leave), and Profile tabs
4. Create a new leave request (optional)
5. Check leave balance and approval status
6. Logout

Important Notes:
- This is a B2B enterprise HR app used by Camlica CRM users
- App requires internet connection and active API backend
- All sensitive data (tokens) stored securely in Keychain
- Uses HTTPS only for API communication
- Supports English and Turkish languages

Backend API: https://crm.cmlc.com.tr/api/
For issues: abidin.ocal@camlica.com.tr
```

---

## 🖼️ ADIM 4: Screenshots (Ekran Görüntüleri)

Aşağıdaki ekranlardan screenshots alın:

1. **Login Screen** - "Giriş yapın" ekranı
2. **OTP Verification** - OTP doğrulama ekranı
3. **Home Tab** - Ana sayfa ve hoş geldin mesajı
4. **Leave Management** - İzin yönetimi (charts, status, requests)
5. **Profile Tab** - Profil bilgileri
6. **Manager Approval Queue** (varsa) - Yönetici onay kuyruğu

Her screenshot için İngilizce ve Türkçe metinler hazırla.

---

## 📧 ADIM 5: Contact Information

```
İsim: Abidin Öcal
Email: abidin.ocal@camlica.com.tr
Telefon: +90 (XXX) XXX XXXX  (Güncellenecek)
```

---

## ✅ ADIM 6: Kontrol Listesi

App Store Connect'e göndermeden önce tamamla:

- [ ] Build oluşturdum ve TestFlight'a yükledim
- [ ] Demo hesabı oluşturdum ve test ettim
- [ ] App adı ve subtitle girdim
- [ ] Tanıtım metni girdim (EN & TR)
- [ ] Tam açıklama girdim (EN & TR)
- [ ] Anahtar kelimeler girdim (EN & TR)
- [ ] Support URL girdim
- [ ] Marketing URL girdim
- [ ] Copyright girdim
- [ ] Contact Information girdim
- [ ] "Sign-in required" kutusunu işaretledim
- [ ] Demo credentials girdim
- [ ] Beta App Review Notes girdim
- [ ] Screenshots yükledim
- [ ] Yaş değerlendirmesini yaptım
- [ ] Gönderiye hazırım

---

## 🎯 ADIM 7: Gönder

1. App Store Connect'te "Gönder" (Submit for Review) butonuna tıkla
2. Apple'ın review ekibi uygulamayı inceleyecek (3-24 saat)
3. Sorularının olursa, demo hesabı ve notes aracılığıyla yanıt ver
4. Onaylı Başarılı geri dönüş gelmesini bekle ✅

---

## 📞 Sorulsa Cevap Olabilecek Yaygın Sorular

**S: Neden giriş gerekli?**
A: Bu, kurumsal bir B2B uygulamasıdır. Kullanıcılar Camlica CRM sisteminde kayıtlı olmalıdır.

**S: Offline çalışır mı?**
A: Hayır, tüm veriler backend API'den gelir. İnternet bağlantısı gereklidir.

**S: Hangi izinleri kullanıyor?**
A: Yerel ağ erişimi (isteğe bağlı), başka hiçbir izin kullanmaz.

**S: Veri güvenliği nasıl?**
A: HTTPS-only, JWT tokens, Keychain'de depolanan hassas veriler.

---

**Hazırlandı:** 27 Ekim 2025
**Durum:** Review'e hazır
