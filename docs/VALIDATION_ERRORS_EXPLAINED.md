# App Store Connect Validation Errors - Çözüm Rehberi

## Alınan Hatalar ve Çözümleri

### ❌ Hata 1: Turkish Description - Invalid Characters
**Sorun:**
Turkish Description alanında geçersiz karakterler var.

**Neden:**
App Store Connect bazı Unicode karakterleri (Turkish-specific) kabul etmiyor:
- ş, ğ, ı, ü, ö, ç (Turkish letters)
- Özel semboller (✓, •, →, vb.)
- Emoji

**Çözüm:**
Turkish metinlerde ASCII-safe karakterler kullanın:

```
WRONG: İşletmenizi yönetin
CORRECT: Isletmenizi yonetin

WRONG: Kişisel bilgilere bakış
CORRECT: Kisisel bilgilere bakis

WRONG: • Feature 1
CORRECT: - Feature 1
```

**Kullanılacak Dönüşümler:**
```
ş → s
ğ → g
ı → i
ü → u
ö → o
ç → c
İ → I
Ş → S
Ğ → G
Ü → U
Ö → O
Ç → C
```

---

### ❌ Hata 2: Phone Number - Invalid Format
**Sorun:**
Phone number alanı formatı yanlış bulunmuş.

**Neden:**
App Store Connect telefon numarasını çok spesifik formatta talep ediyor.

**Yanlış Formatlar:**
```
❌ +90 (555) 123-4567      (parentheses/dashes)
❌ +90-555-123-4567        (dashes)
❌ +90 555 123 4567        (spaces)
❌ 05551234567             (no country code)
❌ 0 (555) 123 4567        (wrong format)
```

**Doğru Format:**
```
✅ +905551234567           (+ followed by country code and number, NO spaces/dashes)
✅ +90-XXXXXXXXXX          (The ONLY other acceptable format with single dash)
```

**Türkiye Telefon Numaraları:**
- Country Code: 90
- Format: +90 + 10-digit number
- Example: +905551234567 or +90-5551234567

**Senin Telefon Numarası:**
Eğer telefon numaranız: 555 123 4567 ise:
```
✅ CORRECT: +905551234567
```

---

### ❌ Hata 3: Turkish URLs - Field Validation Failure
**Sorun:**
Turkish Marketing URL ve Support URL kaydedilemiyor.

**Neden:**
Bu alanlar Phone number alanının validation hatasına bağlı. Bir alan hatada ise, diğer alanlar cascade validation yapıyor.

**Çözüm:**
1. **FIRST** - Phone number'ı düzelt ve kaydet
2. **THEN** - Diğer alanlar otomatik olarak kaydedilebilecek

---

### ❌ Hata 4: Turkish Keywords - Field Validation Failure
**Sorun:**
Turkish Keywords kaydedilemiyor.

**Neden:**
Phone number validation hatası nedeniyle cascade validation.

**Çözüm:**
Phone number'ı düzelt.

---

### ❌ Hata 5: Turkish Promotional Text - Field Validation Failure
**Sorun:**
Turkish Promotional Text kaydedilemiyor.

**Neden:**
1. Phone number hatası (cascade)
2. Muhtemelen Turkish-specific karakterler

**Çözüm:**
1. Phone number'ı düzelt
2. Turkish text'i ASCII-safe yap

---

### ❌ Hata 6: Contact Information Errors
**Sorun:**
Email, Last Name, First Name, Password, Username alanları kaydedilemiyor.

**Neden:**
**Tüm bu hatalar Phone number validation hatasından kaynaklanıyor!**

Apple App Store Connect'in validation sistemi:
- Eğer Contact Information section'da bir alan hata veriyorsa
- Diğer tüm alanlar da cascade olarak başarısız olur
- Bu alanları ayrı ayrı düzeltemezsin

**Çözüm - Bu sırada yapılmalı:**
1. **Phone number'ı ilk düzelt ve kaydet**
2. **Sonra Email, First Name, Last Name gir ve kaydet**
3. **Sonra diğer Turkish alanları gir**

---

## 🔧 ÇÖZÜM ADIM ADIM

### ADIM 1: Contact Information'ı Düzelt

```
Gidecek yer: App Store Connect
            → Select your app
            → App Information
            → Contact Information

Şu şekilde düzelt:

First Name:
Abidin

Last Name:
Ocal

Email Address:
abidin.ocal@camlica.com.tr

Phone Number:
+905551234567    ← BUNU DOĞRU FORMATTA GİR
(no spaces, no dashes, just + and numbers)
```

**Kaydet** → Eğer başarılı olursa, devam et

---

### ADIM 2: Turkish Descriptions'ı Düzelt

Gidecek yer: App Information → Localization (Turkish)

```
Promotional Text:
Isletmenizi her yerden yonetim. Siparisler, HR, depo, giderler - tum entegre mobil CRM platformunda.

Description:
[Use the ASCII-safe version from APP_STORE_FIXED_METADATA.txt]

Keywords:
crm, isletme yonetimi, insan kaynaklari, yonetim, arac siparis, depo, gider, personel, mobil crm, is akisi, onay, pano, calisan, organizasyon, sirket yonetimi, vardiya, izin, talebi, bayi, depo yonetimi, satis, tedarik, butceleme, takim yonetimi, is uygulamasi, kurumsal, turkce crm, camlica

Support URL:
https://crm.cmlc.com.tr/support

Marketing URL:
https://crm.cmlc.com.tr
```

**Kaydet**

---

### ADIM 3: Kontrol Et

```
Eğer hepsi başarıyla kaydedildiyse ✓
Validation hatası olmadı ✓
Devam edebilirsin ✓
```

---

## 📋 KONTROL LİSTESİ

```
Phone Number:
[ ] Formatı kontrol ettim: +90XXXXXXXXXX (no spaces/dashes)
[ ] Gerçek telefon numarasını girdim
[ ] Kaydettim ve başarılı oldu

Contact Information:
[ ] First Name: Abidin
[ ] Last Name: Ocal
[ ] Email: abidin.ocal@camlica.com.tr
[ ] Phone: (saved in previous step)
[ ] Kaydettim

Turkish Localization:
[ ] Promotional Text (ASCII-safe) girdim
[ ] Description (ASCII-safe) girdim
[ ] Keywords (ASCII-safe) girdim
[ ] URLs girdim
[ ] Kaydettim

Validation:
[ ] Hata yok
[ ] Tüm alanlar yeşil
[ ] Devam edebilirim
```

---

## 💡 İPUÇLARI

1. **Copy-Paste'den Dikkat Et**
   - Browser'dan copy-paste yapıyor musun?
   - Bazen gizli karakterler transfer olabiliyor
   - Doğrudan App Store Connect'e yazmayı dene

2. **Turkish Dil Desteğine Dikkat**
   - Turkish karakterleri sorun yaratabilir
   - ASCII versiyonlarını kullan
   - YALNIZCA English field'de full Turkish karakterleri kullanabilirsin

3. **Phone Format'ı Tekrar Kontrol**
   - Telefon numarasında boşluk var mı? Kaldır
   - Tire (-) var mı? Kaldır
   - Parantez ( ) var mı? Kaldır
   - Sadece +90XXXXXXXXXX format olmalı

---

## 🆘 Eğer Hala Sorun Varsa

1. **Cache'i Temizle**
   - Browser cookies'ini sil
   - App Store Connect'ten logout et
   - Yeniden login et

2. **Başka Bir Browser Dene**
   - Chrome → Safari
   - Safari → Chrome

3. **App Store Connect'e Sor**
   - Hata mesajının tam metnini kaydet
   - Apple Support'a iletişim kur
   - Screenshot at

---

**Son Güncelleme:** 27 Ekim 2025
**Status:** Validation Hataları Çözüldü
