# 📍 Konum Tabanlı Giriş-Çıkış Sistemi - İmplementasyon Kılavuzu

## 🎯 Sistem Özeti

Bu doküman, Camlica360 uygulamasına entegre edilen konum tabanlı giriş-çıkış takip sisteminin detaylı implementasyon kılavuzudur.

**Ana Özellikler:**
- Geofencing tabanlı otomatik konum takibi
- Online/Offline hibrit senkronizasyon
- Real-time giriş-çıkış kaydı
- Geçmiş raporlama ve analiz
- Background sync desteği

---

## 📱 iOS Implementasyon Detayları

### 1. Dosya Yapısı

```
camlica360/
├── Core/
│   ├── Location/
│   │   ├── LocationManager.swift       # Konum yönetimi
│   │   └── GeofenceManager.swift       # Geofence takibi
│   └── Background/
│       └── AttendanceBackgroundSync.swift  # Arka plan sync
├── Modules/
│   └── Attendance/
│       ├── Models/
│       │   ├── AttendanceEventType.swift
│       │   ├── AttendanceLog.swift
│       │   └── WorkplaceLocation.swift
│       ├── Services/
│       │   ├── AttendanceService.swift
│       │   └── AttendanceLocationService.swift
│       ├── ViewModels/
│       │   ├── AttendanceViewModel.swift
│       │   └── AttendanceHistoryViewModel.swift
│       └── Views/
│           ├── AttendanceView.swift
│           └── AttendanceHistoryView.swift
```

### 2. LocationManager Kullanımı

```swift
// Konum izinleri iste
LocationManager.shared.requestLocationPermission(alwaysAllow: true)

// Konum güncellemelerini başlat
LocationManager.shared.startLocationUpdates()

// Delegate ayarla
LocationManager.shared.delegate = self

// Mevcut konumu al
if let currentLocation = LocationManager.shared.getLastKnownLocation() {
    print("Latitude: \(currentLocation.latitude)")
    print("Longitude: \(currentLocation.longitude)")
}
```

### 3. GeofenceManager Kullanımı

```swift
// Geofence region oluştur ve ekle
let region = GeofenceRegion(
    id: "office-istanbul",
    location: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
    radiusInMeters: 150,
    name: "Istanbul Headquarters"
)

let added = GeofenceManager.shared.addGeofenceRegion(region)

// Delegate ayarla
GeofenceManager.shared.delegate = self

// Tüm monitored regions'ı al
let monitored = GeofenceManager.shared.getAllMonitoredRegions()

// Bir konumun geofence içinde olup olmadığını kontrol et
if GeofenceManager.shared.isLocationInRegion(coordinate, regionId: "office-istanbul") {
    print("User is inside the geofence")
}
```

### 4. AttendanceService Kullanımı

```swift
// Giriş kaydı
let log = try await AttendanceService.shared.logAttendanceEvent(
    eventType: .checkIn,
    workplaceLocationId: "location-id",
    coordinate: currentCoordinate,
    accuracyInMeters: 20,
    isManual: false
)

// Bugünün kayıtlarını al
let todaysLogs = try await AttendanceService.shared.getTodaysLogs()

// Pending logları senkronize et (offline queue)
try await AttendanceService.shared.syncPendingLogs()

// Pending logları kontrol et
let pending = AttendanceService.shared.getPendingLogs()
```

### 5. AttendanceViewModel Kullanımı

```swift
// Takip başlat
Task {
    await attendanceViewModel.startAttendanceTracking()
}

// Manuel giriş
Task {
    await attendanceViewModel.manualCheckIn()
}

// Pending logları senkronize et
Task {
    await attendanceViewModel.syncPendingLogs()
}

// Durumları dinle
@ObservedObject var viewModel: AttendanceViewModel

Text(viewModel.isInsideGeofence ? "In Geofence" : "Outside")
Text("Pending logs: \(viewModel.pendingLogsCount)")
```

### 6. Localization Keys

Aşağıdaki keys'ler `Localizable.xcstrings` dosyasına eklenmelidir:

```
// Attendance module
"attendance_title" = "Giriş-Çıkış Takibi"
"attendance_subtitle" = "Konumunuzu takip edin ve giriş-çıkış yapın"
"attendance_check_in" = "Giriş"
"attendance_check_out" = "Çıkış"
"check_in_successful" = "Başarıyla giriş yaptınız"
"check_out_successful" = "Başarıyla çıkış yaptınız"
"not_in_workplace" = "Işyeri alanı dışındasınız"
"pending_logs" = "Senkronize Edilmek Bekleyen Kayıtlar"
"pending_logs_count" = "%d kayıt senkronize edilmeyi beklemektedir"
"sync" = "Senkronize Et"
"offline_log_saved" = "Çevrim dışı - kayıt lokal olarak kaydedildi"
"todays_logs" = "Bugünün Kayıtları"
"attendance_history" = "Giriş-Çıkış Geçmişi"
"view_history" = "Geçmişi Görüntüle"

// Location
"location_services_disabled" = "Konum Servisleri Devre Dışı"
"location_enabled" = "Konum Etkinleştirildi"
"location_disabled" = "Konum Devre Dışı"
"location_permission_denied" = "Konum İzni Reddedildi"
"location_permission_restricted" = "Konum İzni Kısıtlanmıştır"
"location_permission_not_determined" = "Konum İzni Belirsiz"
"location_not_available" = "Konum Şu Anda Kullanılabilir Değildir"
"location_status" = "Konum Durumu"
"location_invalid" = "Geçersiz Konum"

// Date ranges
"date_range_today" = "Bugün"
"date_range_yesterday" = "Dün"
"date_range_this_week" = "Bu Hafta"
"date_range_last_week" = "Geçen Hafta"
"date_range_this_month" = "Bu Ay"
"date_range_last_month" = "Geçen Ay"

// History
"first_check_in" = "İlk Giriş"
"last_check_out" = "Son Çıkış"
"total_events" = "Toplam Olaylar"
"all_entries" = "Tüm Girişler"
"working_hours" = "Çalışma Saati"
"checked_in" = "Giriş Yaptı"
"checked_out" = "Çıkış Yaptı"
"not_checked_in" = "Giriş Yapmadı"
"no_logs_found" = "Kayıt Bulunamadı"
```

### 7. Info.plist Konfigürasyonu

```xml
<!-- Location Usage Descriptions (Required) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Işyerinize girip çıkmanızı takip etmek için konumunuza erişim gereklidir</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Arka planda giriş-çıkış takibini sağlamak için konumunuza her zaman erişim gereklidir</string>

<!-- Background Modes (Required for geofencing) -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

### 8. Permissions & Capabilities Setup

1. Xcode'da proje seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** tıkla
4. Aşağıdakileri ekle:
   - Background Modes → Location updates
   - Background Fetch (opsiyonel, offline sync için)

---

## 🖥️ Backend (.NET) Implementasyon Detayları

### 1. Dosya Yapısı

```
HRService/
├── Domain/
│   ├── Entities/
│   │   ├── AttendanceLog.cs
│   │   └── WorkplaceLocation.cs
│   └── Enums/
│       └── AttendanceEventType.cs
├── Application/
│   ├── DTOs/
│   │   ├── Attendance/
│   │   │   ├── CreateAttendanceLogDto.cs
│   │   │   ├── GetAttendanceLogDto.cs
│   │   │   ├── BatchAttendanceLogDto.cs
│   │   │   └── AttendanceLogResponseDto.cs
│   │   └── WorkplaceLocation/
│   │       ├── CreateWorkplaceLocationDto.cs
│   │       ├── UpdateWorkplaceLocationDto.cs
│   │       └── GetWorkplaceLocationDto.cs
│   └── Services/
│       ├── IAttendanceService.cs (Interface)
│       ├── AttendanceService.cs
│       ├── IWorkplaceLocationService.cs (Interface)
│       └── WorkplaceLocationService.cs
├── Infrastructure/
│   └── Repositories/
│       ├── IAttendanceLogRepository.cs
│       ├── AttendanceLogRepository.cs
│       ├── IWorkplaceLocationRepository.cs
│       └── WorkplaceLocationRepository.cs
└── API/
    └── Controllers/
        ├── AttendanceController.cs
        └── WorkplaceLocationController.cs
```

### 2. API Endpoints

#### Attendance Endpoints

```
POST   /hr/attendance/log                          # Single attendance log
POST   /hr/attendance/log/batch                    # Batch upload (offline sync)
GET    /hr/attendance/log/{personnelId}            # Get logs by personnel
GET    /hr/attendance/log/range                    # Get logs by date range
GET    /hr/attendance/log/daily/{personnelId}/{date}  # Daily summary
GET    /hr/attendance/log/company/{companyId}     # Company reporting
POST   /hr/attendance/validate/location            # Validate geofence
```

#### Workplace Location Endpoints

```
POST   /hr/workplace-location/create               # Create location
PUT    /hr/workplace-location/update               # Update location
DELETE /hr/workplace-location/delete/{id}          # Delete location
GET    /hr/workplace-location/getById/{id}         # Get by ID
GET    /hr/workplace-location/getByCompany/{id}    # Get by company
GET    /hr/workplace-location/getActiveByCompany/{id}  # Get active (mobile)
GET    /hr/workplace-location/getByDepartment/{id} # Get by department
POST   /hr/workplace-location/assign               # Assign employee
GET    /hr/workplace-location/getAssignedEmployees/{id}  # Get employees
```

### 3. Database Schema

#### AttendanceLog Table

```sql
CREATE TABLE attendance_logs (
    id UUID PRIMARY KEY,
    company_id UUID NOT NULL,
    crm_personnel_id UUID NOT NULL,
    workplace_location_id UUID NOT NULL,
    event_type INTEGER NOT NULL, -- 0=CheckIn, 1=CheckOut
    timestamp TIMESTAMP NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy_in_meters DOUBLE PRECISION,
    device_info VARCHAR(500),
    is_manual BOOLEAN NOT NULL,
    note VARCHAR(1000),
    is_synced BOOLEAN DEFAULT true,
    synced_at TIMESTAMP,
    duplicate_hash VARCHAR(256),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    deleted_by_user_id UUID,
    CONSTRAINT fk_attendance_location FOREIGN KEY (workplace_location_id)
        REFERENCES workplace_locations(id),
    INDEX idx_personnel_timestamp (crm_personnel_id, timestamp),
    INDEX idx_company_date (company_id, created_at),
    INDEX idx_duplicate_hash (duplicate_hash)
);
```

#### WorkplaceLocation Table

```sql
CREATE TABLE workplace_locations (
    id UUID PRIMARY KEY,
    company_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    radius_in_meters INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    notes VARCHAR(1000),
    assigned_employee_count INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    created_by_user_id UUID NOT NULL,
    updated_at TIMESTAMP,
    updated_by_user_id UUID,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    deleted_by_user_id UUID,
    INDEX idx_company_active (company_id, is_active),
    INDEX idx_coordinates (latitude, longitude)
);
```

### 4. Validations & Business Rules

```csharp
// Duplicate Check (5 minute window)
var recentLog = await _repository.GetByPersonnelAndTimeAsync(
    personnelId,
    DateTime.UtcNow.AddMinutes(-5)
);
if (recentLog?.EventType == requestedEventType) {
    throw new InvalidOperationException("Duplicate entry within 5 minutes");
}

// Geofence Validation
var distance = CalculateDistance(locationCoord, userCoord);
if (distance > location.RadiusInMeters) {
    throw new InvalidOperationException("Location is outside geofence");
}

// Accuracy Check
if (request.AccuracyInMeters > 100) {
    // Flag for manual verification
}
```

### 5. Offline Sync Strategy

**Client → Server Sync Process:**

1. **Online Mode:**
   - Giriş-çıkış event tetiklenir
   - Anında POST /hr/attendance/log
   - Success: Mark as synced
   - Failure: Add to offline queue

2. **Offline Mode:**
   - Giriş-çıkış event tetiklenir
   - Local CoreData'ya kaydet (isSynced=false)
   - BackgroundTask periyodik kontrol

3. **Background Sync:**
   - 15 dakika aralığında kontrolü kur
   - Network available → POST /hr/attendance/log/batch
   - Batch 1-100 logs'u handle eder
   - Server duplicate detection yapar

---

## 🔄 Integration Points

### App Initialization

```swift
// In SceneDelegate or App.swift
@main
struct camlica360App: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .onAppear {
                    // Initialize background sync
                    AttendanceBackgroundSync.initializeBackgroundSync()

                    // Setup location permissions
                    LocationManager.shared.requestLocationPermission(alwaysAllow: true)
                }
        }
    }
}
```

### Network Configuration

Update `APIConstants.swift`:

```swift
struct APIConstants {
    static let baseURL = "https://api.camlica360.com"
    static let hrBaseURL = "https://hr-api.camlica360.com"
    // ... other constants
}
```

---

## 🧪 Testing Checklist

### iOS Tests

- [ ] LocationManager konum güncellemelerini alıyor
- [ ] GeofenceManager region enter/exit events tetikliyor
- [ ] AttendanceViewModel doğru state yönetiyor
- [ ] Offline queue CoreData'ya kaydediliyor
- [ ] Background sync pending logs'ları gönderiliyor
- [ ] Network errors gracefully handle ediliyor

### Backend Tests

- [ ] POST /hr/attendance/log single log oluşturuyor
- [ ] POST /hr/attendance/log/batch batch logs işliyor
- [ ] Duplicate detection çalışıyor
- [ ] Geofence validation doğru sonuç dönüyor
- [ ] Company reporting queries performans sorunları yok
- [ ] Pagination büyük dataset'lerde çalışıyor

### End-to-End Tests

- [ ] Check-in online mode'de başarılı
- [ ] Check-in offline mode'de lokal kaydediliyor
- [ ] App background'da geofencing çalışıyor
- [ ] Network gelince pending logs senkronize oluyor
- [ ] Duplicate entries reddediliyor
- [ ] History view geçmiş kayıtları gösteriyor

---

## 🚀 Deployment Checklist

### iOS Deployment

- [ ] Info.plist location permissions eklendi
- [ ] Background Modes capabilities aktif
- [ ] Localization strings eklenmiş
- [ ] TestFlight beta test yapıldı
- [ ] Privacy Policy güncellenmiş
- [ ] App Store review submitted

### Backend Deployment

- [ ] Database migrations tested
- [ ] API endpoints tested
- [ ] Error handling ve logging setup
- [ ] Performance monitoring active
- [ ] Backup strategy in place
- [ ] Rollback plan documented

---

## 📊 Monitoring & Analytics

### iOS Metrics

- [ ] Location permission request rate
- [ ] Geofence enter/exit frequency
- [ ] Background sync success rate
- [ ] Offline queue size trending
- [ ] Error rates by type

### Backend Metrics

- [ ] API response times
- [ ] Attendance log creation rate
- [ ] Batch sync throughput
- [ ] Database query performance
- [ ] Error rates and types

---

## 🐛 Common Issues & Solutions

### Issue: Geofencing not working in background

**Solution:**
- Ensure NSLocationAlwaysAndWhenInUseUsageDescription is in Info.plist
- Enable "Background Modes → Location updates" capability
- Test on real device (simulator geofencing is unreliable)

### Issue: Offline logs not syncing

**Solution:**
- Check pending logs: `AttendanceService.shared.getPendingLogs()`
- Verify network connectivity
- Check app has background app refresh permission
- Review BGTaskScheduler logs in Xcode console

### Issue: High battery drain

**Solution:**
- Verify LocationManager.distanceFilter is set to 10m minimum
- Check geofence radius isn't too small (<100m)
- Ensure significant location change filter is configured
- Monitor background task frequency

### Issue: Duplicate attendance records

**Solution:**
- Backend validates timestamp + personnelId uniqueness
- Check DuplicateHash calculation
- Verify 5-minute duplicate window is working
- Review sync timing between offline queue and backend

---

## 📚 References

- [Apple LocationKit Documentation](https://developer.apple.com/documentation/corelocation)
- [Background Execution Guide](https://developer.apple.com/documentation/backgroundtasks)
- [Geofencing Best Practices](https://developer.apple.com/videos/)
- [BackgroundTasks Framework](https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler)

---

**Version:** 1.0
**Last Updated:** October 28, 2025
**Maintained By:** Development Team
