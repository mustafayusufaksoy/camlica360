📍 Konum Tabanlı Giriş-Çıkış Takip Sistemi - İmplementasyon Planı                                                                       │ │
│ │                                                                                                                                         │ │
│ │ 🎯 Seçilen Yaklaşım                                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ - Konum Yöntemi: Geofencing (Bölge tabanlı)                                                                                             │ │
│ │ - Lokasyon Stratejisi: Her çalışan tek lokasyona atanır                                                                                 │ │
│ │ - Senkronizasyon: Online/Offline hibrit (online varsa anında, yoksa lokal kayıt + sonra sync)                                           │ │
│ │ - Vardiya Entegrasyonu: Hayır (basit giriş-çıkış takibi)                                                                                │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ 📱 PART 1: iOS (Swift) - Mobile App Implementation                                                                                      │ │
│ │                                                                                                                                         │ │
│ │ 1. Core Components - Konum Servisleri                                                                                                   │ │
│ │                                                                                                                                         │ │
│ │ 1.1 LocationManager.swift (Core/Location/)                                                                                              │ │
│ │                                                                                                                                         │ │
│ │ - CLLocationManager wrapper oluşturulacak                                                                                               │ │
│ │ - Geofencing region tanımlama ve izleme                                                                                                 │ │
│ │ - Konum izinleri yönetimi (Always/When In Use)                                                                                          │ │
│ │ - Background location updates                                                                                                           │ │
│ │ - Region enter/exit event handling                                                                                                      │ │
│ │ - Accuracy ve distance filter optimizasyonu                                                                                             │ │
│ │                                                                                                                                         │ │
│ │ 1.2 GeofenceManager.swift (Core/Location/)                                                                                              │ │
│ │                                                                                                                                         │ │
│ │ - Workspace lokasyonları için geofence tanımlama                                                                                        │ │
│ │ - Radius parametresi (örn: 100-200 metre)                                                                                               │ │
│ │ - Multi-region monitoring desteği                                                                                                       │ │
│ │ - Region monitoring limitleri yönetimi (max 20 region)                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ 2. Data Layer - Models & Storage                                                                                                        │ │
│ │                                                                                                                                         │ │
│ │ 2.1 Models (Modules/Attendance/Models/)                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ // WorkplaceLocation.swift                                                                                                              │ │
│ │ - id, companyId, name, latitude, longitude, radius                                                                                      │ │
│ │                                                                                                                                         │ │
│ │ // AttendanceLog.swift                                                                                                                  │ │
│ │ - id, personnelId, workplaceLocationId, eventType (CheckIn/CheckOut)                                                                    │ │
│ │ - timestamp, latitude, longitude, accuracy                                                                                              │ │
│ │ - isSynced, syncedAt, createdAt                                                                                                         │ │
│ │                                                                                                                                         │ │
│ │ // AttendanceEventType.swift (Enum)                                                                                                     │ │
│ │ - checkIn, checkOut                                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ 2.2 Local Storage (Core/Storage/)                                                                                                       │ │
│ │                                                                                                                                         │ │
│ │ - CoreDataManager.swift genişletme                                                                                                      │ │
│ │   - AttendanceLog entity tanımı                                                                                                         │ │
│ │   - Local queue için CRUD operations                                                                                                    │ │
│ │   - Sync durumu takibi                                                                                                                  │ │
│ │ - AttendanceStorage.swift (yeni)                                                                                                        │ │
│ │   - Pending logs yönetimi                                                                                                               │ │
│ │   - Sync retry logic                                                                                                                    │ │
│ │   - Conflict resolution                                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ 3. Business Logic - Services & ViewModels                                                                                               │ │
│ │                                                                                                                                         │ │
│ │ 3.1 Services (Modules/Attendance/Services/)                                                                                             │ │
│ │                                                                                                                                         │ │
│ │ AttendanceService.swift                                                                                                                 │ │
│ │ - Giriş-çıkış kaydı oluşturma                                                                                                           │ │
│ │ - Backend API çağrıları                                                                                                                 │ │
│ │ - Offline queue yönetimi                                                                                                                │ │
│ │ - Background sync scheduler                                                                                                             │ │
│ │                                                                                                                                         │ │
│ │ AttendanceLocationService.swift                                                                                                         │ │
│ │ - Workplace locations getirme                                                                                                           │ │
│ │ - Geofence kurulumu                                                                                                                     │ │
│ │ - Location validation                                                                                                                   │ │
│ │                                                                                                                                         │ │
│ │ 3.2 ViewModels (Modules/Attendance/ViewModels/)                                                                                         │ │
│ │                                                                                                                                         │ │
│ │ AttendanceViewModel.swift                                                                                                               │ │
│ │ - Real-time location status                                                                                                             │ │
│ │ - Giriş-çıkış butonu state management                                                                                                   │ │
│ │ - Geçmiş kayıtlar listesi                                                                                                               │ │
│ │ - Sync status indicator                                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ AttendanceHistoryViewModel.swift                                                                                                        │ │
│ │ - Günlük/haftalık/aylık kayıt listesi                                                                                                   │ │
│ │ - Filtreleme ve arama                                                                                                                   │ │
│ │ - Export/rapor fonksiyonları                                                                                                            │ │
│ │                                                                                                                                         │ │
│ │ 4. UI Layer - Views                                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ 4.1 Views (Modules/Attendance/Views/)                                                                                                   │ │
│ │                                                                                                                                         │ │
│ │ AttendanceView.swift                                                                                                                    │ │
│ │ - Ana giriş-çıkış ekranı                                                                                                                │ │
│ │ - Konum durumu göstergesi (in/out of range)                                                                                             │ │
│ │ - Manuel check-in/out butonları                                                                                                         │ │
│ │ - Bugünkü kayıtlar özeti                                                                                                                │ │
│ │                                                                                                                                         │ │
│ │ AttendanceHistoryView.swift                                                                                                             │ │
│ │ - Geçmiş kayıtlar listesi                                                                                                               │ │
│ │ - Tarih filtreleri                                                                                                                      │ │
│ │ - Detay modal                                                                                                                           │ │
│ │                                                                                                                                         │ │
│ │ AttendanceMapView.swift (Optional)                                                                                                      │ │
│ │ - Workplace location harita görünümü                                                                                                    │ │
│ │ - Geofence boundary visualization                                                                                                       │ │
│ │                                                                                                                                         │ │
│ │ 5. Background Processing                                                                                                                │ │
│ │                                                                                                                                         │ │
│ │ 5.1 Background Tasks (Core/Background/)                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ - AttendanceBackgroundSync.swift                                                                                                        │ │
│ │   - BGTaskScheduler ile periyodik sync                                                                                                  │ │
│ │   - Offline kayıtları backend'e gönderme                                                                                                │ │
│ │   - Retry logic                                                                                                                         │ │
│ │                                                                                                                                         │ │
│ │ 5.2 Notification Handler                                                                                                                │ │
│ │                                                                                                                                         │ │
│ │ - Geofence enter/exit notifications                                                                                                     │ │
│ │ - Kullanıcı bilgilendirme                                                                                                               │ │
│ │                                                                                                                                         │ │
│ │ 6. Permissions & Configuration                                                                                                          │ │
│ │                                                                                                                                         │ │
│ │ 6.1 Info.plist Updates                                                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ - NSLocationAlwaysAndWhenInUseUsageDescription                                                                                          │ │
│ │ - NSLocationWhenInUseUsageDescription                                                                                                   │ │
│ │ - UIBackgroundModes: location                                                                                                           │ │
│ │ - Privacy - Location Always Usage Description (TR/EN)                                                                                   │ │
│ │                                                                                                                                         │ │
│ │ 6.2 Capabilities                                                                                                                        │ │
│ │                                                                                                                                         │ │
│ │ - Background Modes → Location updates                                                                                                   │ │
│ │ - Background fetch                                                                                                                      │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ 🖥️ PART 2: Backend (.NET) - HRService Implementatio                                                                                    │ │
│ │                                                                                                                                         │ │
│ │ 1. Domain Layer                                                                                                                         │ │
│ │                                                                                                                                         │ │
│ │ 1.1 Entities (HRService.Domain/Entities/)                                                                                               │ │
│ │                                                                                                                                         │ │
│ │ WorkplaceLocation.cs                                                                                                                    │ │
│ │ - Id (Guid)                                                                                                                             │ │
│ │ - CompanyId (Guid)                                                                                                                      │ │
│ │ - Name (string)                                                                                                                         │ │
│ │ - Address (string)                                                                                                                      │ │
│ │ - Latitude (double)                                                                                                                     │ │
│ │ - Longitude (double)                                                                                                                    │ │
│ │ - Radius (int) - metre cinsinden                                                                                                        │ │
│ │ - IsActive, CreatedAt, UpdatedAt                                                                                                        │ │
│ │ - Soft delete fields                                                                                                                    │ │
│ │                                                                                                                                         │ │
│ │ AttendanceLog.cs                                                                                                                        │ │
│ │ - Id (Guid)                                                                                                                             │ │
│ │ - CompanyId (Guid)                                                                                                                      │ │
│ │ - CrmPersonnelId (Guid)                                                                                                                 │ │
│ │ - WorkplaceLocationId (Guid)                                                                                                            │ │
│ │ - EventType (enum: CheckIn/CheckOut)                                                                                                    │ │
│ │ - Timestamp (DateTime)                                                                                                                  │ │
│ │ - Latitude (double) - kaydedilen konum                                                                                                  │ │
│ │ - Longitude (double)                                                                                                                    │ │
│ │ - Accuracy (double) - metre                                                                                                             │ │
│ │ - DeviceInfo (string) - iOS cihaz bilgisi                                                                                               │ │
│ │ - IsManual (bool) - manuel mi otomatik mi                                                                                               │ │
│ │ - Note (string, nullable)                                                                                                               │ │
│ │ - CreatedAt, UpdatedAt                                                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ 1.2 Enums (HRService.Domain/Enums/)                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ AttendanceEventType { CheckIn, CheckOut }                                                                                               │ │
│ │                                                                                                                                         │ │
│ │ 2. Application Layer                                                                                                                    │ │
│ │                                                                                                                                         │ │
│ │ 2.1 DTOs (HRService.Application/DTOs/)                                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ Attendance/                                                                                                                             │ │
│ │ - CreateAttendanceLogDto.cs                                                                                                             │ │
│ │ - GetAttendanceLogDto.cs                                                                                                                │ │
│ │ - GetAttendanceLogsByDateRangeDto.cs                                                                                                    │ │
│ │ - AttendanceLogResponseDto.cs                                                                                                           │ │
│ │ - BatchAttendanceLogDto.cs (offline sync için)                                                                                          │ │
│ │                                                                                                                                         │ │
│ │ WorkplaceLocation/                                                                                                                      │ │
│ │ - CreateWorkplaceLocationDto.cs                                                                                                         │ │
│ │ - UpdateWorkplaceLocationDto.cs                                                                                                         │ │
│ │ - GetWorkplaceLocationDto.cs                                                                                                            │ │
│ │ - GetAllWorkplaceLocationsDto.cs                                                                                                        │ │
│ │                                                                                                                                         │ │
│ │ 2.2 Services (HRService.Application/Services/)                                                                                          │ │
│ │                                                                                                                                         │ │
│ │ AttendanceService.cs                                                                                                                    │ │
│ │ - CreateAttendanceLog(dto) - tek kayıt                                                                                                  │ │
│ │ - CreateBatchAttendanceLogs(dtos) - offline sync için bulk insert                                                                       │ │
│ │ - GetAttendanceLogsByPersonnel(personnelId, dateRange)                                                                                  │ │
│ │ - GetAttendanceLogsByCompany(companyId, filters)                                                                                        │ │
│ │ - ValidateAttendanceLocation(lat, lon, workplaceLocationId) - geofence validation                                                       │ │
│ │                                                                                                                                         │ │
│ │ WorkplaceLocationService.cs                                                                                                             │ │
│ │ - CRUD operations                                                                                                                       │ │
│ │ - GetActiveLocationsByCompany(companyId)                                                                                                │ │
│ │ - AssignPersonnelToLocation(personnelId, locationId)                                                                                    │ │
│ │                                                                                                                                         │ │
│ │ 2.3 CQRS Commands/Queries (MediatR)                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ Commands:                                                                                                                               │ │
│ │ - CreateAttendanceLogCommand                                                                                                            │ │
│ │ - CreateBatchAttendanceLogsCommand                                                                                                      │ │
│ │ - CreateWorkplaceLocationCommand                                                                                                        │ │
│ │ - UpdateWorkplaceLocationCommand                                                                                                        │ │
│ │                                                                                                                                         │ │
│ │ Queries:                                                                                                                                │ │
│ │ - GetAttendanceLogsByPersonnelQuery                                                                                                     │ │
│ │ - GetAttendanceLogsByDateRangeQuery                                                                                                     │ │
│ │ - GetWorkplaceLocationsByCompanyQuery                                                                                                   │ │
│ │                                                                                                                                         │ │
│ │ 3. Infrastructure Layer                                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ 3.1 Repositories (HRService.Infrastructure/Repositories/)                                                                               │ │
│ │                                                                                                                                         │ │
│ │ - AttendanceLogRepository.cs                                                                                                            │ │
│ │ - WorkplaceLocationRepository.cs                                                                                                        │ │
│ │                                                                                                                                         │ │
│ │ 3.2 Database (Migrations)                                                                                                               │ │
│ │                                                                                                                                         │ │
│ │ - AddAttendanceLogsTable                                                                                                                │ │
│ │ - AddWorkplaceLocationsTable                                                                                                            │ │
│ │ - Indexes: CompanyId, CrmPersonnelId, Timestamp, EventType                                                                              │ │
│ │                                                                                                                                         │ │
│ │ 4. API Layer                                                                                                                            │ │
│ │                                                                                                                                         │ │
│ │ 4.1 Controllers (HRService.API/Controllers/)                                                                                            │ │
│ │                                                                                                                                         │ │
│ │ AttendanceController.cs                                                                                                                 │ │
│ │ [Route("hr/attendance")]                                                                                                                │ │
│ │ POST /log - Tek giriş-çıkış kaydı                                                                                                       │ │
│ │ POST /log/batch - Bulk offline sync                                                                                                     │ │
│ │ GET /log/{personnelId} - Kişiye ait kayıtlar                                                                                            │ │
│ │ GET /log/company/{companyId} - Şirket raporu                                                                                            │ │
│ │ GET /log/daily/{personnelId}/{date} - Günlük özet                                                                                       │ │
│ │ GET /log/range - Tarih aralığı sorgulama                                                                                                │ │
│ │                                                                                                                                         │ │
│ │ WorkplaceLocationController.cs                                                                                                          │ │
│ │ [Route("hr/workplace-location")]                                                                                                        │ │
│ │ POST /create                                                                                                                            │ │
│ │ PUT /update                                                                                                                             │ │
│ │ DELETE /delete/{id}                                                                                                                     │ │
│ │ GET /getById/{id}                                                                                                                       │ │
│ │ GET /getByCompany/{companyId}                                                                                                           │ │
│ │ GET /getActiveByCompany/{companyId}                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ 5. Validation & Business Rules                                                                                                          │ │
│ │                                                                                                                                         │ │
│ │ 5.1 Validations                                                                                                                         │ │
│ │                                                                                                                                         │ │
│ │ - Aynı kişinin 5 dakika içinde çift kayıt kontrolü                                                                                      │ │
│ │ - Geofence radius içinde mi kontrolü                                                                                                    │ │
│ │ - CheckIn sonrası CheckOut kontrolü (mantıksal sıralama)                                                                                │ │
│ │ - Tarih/saat manipülasyon kontrolü                                                                                                      │ │
│ │                                                                                                                                         │ │
│ │ 5.2 Business Rules                                                                                                                      │ │
│ │                                                                                                                                         │ │
│ │ - Günlük max giriş-çıkış sayısı limiti (örn: 10)                                                                                        │ │
│ │ - Şüpheli aktivite tespiti (çok hızlı giriş-çıkış)                                                                                      │ │
│ │ - Location accuracy threshold (örn: >50m ise uyarı)                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ 🔄 PART 3: Integration & Sync Mechanism                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ 1. Senkronizasyon Stratejisi                                                                                                            │ │
│ │                                                                                                                                         │ │
│ │ Online Mode:                                                                                                                            │ │
│ │                                                                                                                                         │ │
│ │ 1. Geofence event tetiklenir → iOS                                                                                                      │ │
│ │ 2. Anında AttendanceLog oluştur → Local CoreData                                                                                        │ │
│ │ 3. Hemen API'ye POST /hr/attendance/log                                                                                                 │ │
│ │ 4. Başarılıysa isSynced = true, başarısızsa queue'ya ekle                                                                               │ │
│ │                                                                                                                                         │ │
│ │ Offline Mode:                                                                                                                           │ │
│ │                                                                                                                                         │ │
│ │ 1. Network yoksa → Local CoreData'ya kaydet (isSynced = false)                                                                          │ │
│ │ 2. Background task periyodik kontrol (15 dk)                                                                                            │ │
│ │ 3. Network gelince → Batch sync: POST /hr/attendance/log/batch                                                                          │ │
│ │ 4. Backend validasyon + duplicate control                                                                                               │ │
│ │ 5. Başarılı kayıtları isSynced = true yap                                                                                               │ │
│ │                                                                                                                                         │ │
│ │ 2. Conflict Resolution                                                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ - Timestamp bazlı unique constraint (personnelId + timestamp)                                                                           │ │
│ │ - Backend duplicate detection                                                                                                           │ │
│ │ - Client-side retry exponential backoff                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ 📊 PART 4: Testing & Quality Assurance                                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ iOS Tests                                                                                                                               │ │
│ │                                                                                                                                         │ │
│ │ - LocationManager unit tests (mock CLLocationManager)                                                                                   │ │
│ │ - GeofenceManager simülasyonu                                                                                                           │ │
│ │ - AttendanceService offline/online scenario tests                                                                                       │ │
│ │ - CoreData migration tests                                                                                                              │ │
│ │                                                                                                                                         │ │
│ │ Backend Tests                                                                                                                           │ │
│ │                                                                                                                                         │ │
│ │ - Unit tests: AttendanceService validations                                                                                             │ │
│ │ - Integration tests: API endpoints                                                                                                      │ │
│ │ - Load test: Batch sync performance                                                                                                     │ │
│ │ - Geofence validation accuracy test                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ 🚀 PART 5: Deployment & Rollout                                                                                                         │ │
│ │                                                                                                                                         │ │
│ │ iOS                                                                                                                                     │ │
│ │                                                                                                                                         │ │
│ │ 1. Info.plist permissions ekle                                                                                                          │ │
│ │ 2. Background modes aktif et                                                                                                            │ │
│ │ 3. TestFlight beta test                                                                                                                 │ │
│ │ 4. App Store review (location permission açıklaması)                                                                                    │ │
│ │                                                                                                                                         │ │
│ │ Backend                                                                                                                                 │ │
│ │                                                                                                                                         │ │
│ │ 1. Migration scripts çalıştır (test → prod)                                                                                             │ │
│ │ 2. API endpoints deploy                                                                                                                 │ │
│ │ 3. Monitoring & logging setup (Hangfire/Serilog)                                                                                        │ │
│ │ 4. Performance metrics (response time, sync success rate)                                                                               │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ 📝 Dosya Yapısı (Özet)                                                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ iOS (Swift)                                                                                                                             │ │
│ │                                                                                                                                         │ │
│ │ camlica360/                                                                                                                             │ │
│ │ ├── Core/                                                                                                                               │ │
│ │ │   ├── Location/                                                                                                                       │ │
│ │ │   │   ├── LocationManager.swift                                                                                                       │ │
│ │ │   │   └── GeofenceManager.swift                                                                                                       │ │
│ │ │   ├── Storage/                                                                                                                        │ │
│ │ │   │   ├── CoreDataManager.swift (UPDATE)                                                                                              │ │
│ │ │   │   └── AttendanceStorage.swift (NEW)                                                                                               │ │
│ │ │   └── Background/                                                                                                                     │ │
│ │ │       └── AttendanceBackgroundSync.swift (NEW)                                                                                        │ │
│ │ ├── Modules/                                                                                                                            │ │
│ │ │   └── Attendance/ (NEW MODULE)                                                                                                        │ │
│ │ │       ├── Models/                                                                                                                     │ │
│ │ │       │   ├── WorkplaceLocation.swift                                                                                                 │ │
│ │ │       │   ├── AttendanceLog.swift                                                                                                     │ │
│ │ │       │   └── AttendanceEventType.swift                                                                                               │ │
│ │ │       ├── Services/                                                                                                                   │ │
│ │ │       │   ├── AttendanceService.swift                                                                                                 │ │
│ │ │       │   └── AttendanceLocationService.swift                                                                                         │ │
│ │ │       ├── ViewModels/                                                                                                                 │ │
│ │ │       │   ├── AttendanceViewModel.swift                                                                                               │ │
│ │ │       │   └── AttendanceHistoryViewModel.swift                                                                                        │ │
│ │ │       └── Views/                                                                                                                      │ │
│ │ │           ├── AttendanceView.swift                                                                                                    │ │
│ │ │           ├── AttendanceHistoryView.swift                                                                                             │ │
│ │ │           └── AttendanceMapView.swift (optional)                                                                                      │ │
│ │                                                                                                                                         │ │
│ │ Backend (.NET)                                                                                                                          │ │
│ │                                                                                                                                         │ │
│ │ HRService/                                                                                                                              │ │
│ │ ├── Domain/                                                                                                                             │ │
│ │ │   ├── Entities/                                                                                                                       │ │
│ │ │   │   ├── AttendanceLog.cs (NEW)                                                                                                      │ │
│ │ │   │   └── WorkplaceLocation.cs (NEW)                                                                                                  │ │
│ │ │   └── Enums/                                                                                                                          │ │
│ │ │       └── AttendanceEventType.cs (NEW)                                                                                                │ │
│ │ ├── Application/                                                                                                                        │ │
│ │ │   ├── DTOs/Attendance/ (NEW)                                                                                                          │ │
│ │ │   ├── DTOs/WorkplaceLocation/ (NEW)                                                                                                   │ │
│ │ │   ├── Services/                                                                                                                       │ │
│ │ │   │   ├── AttendanceService.cs (NEW)                                                                                                  │ │
│ │ │   │   └── WorkplaceLocationService.cs (NEW)                                                                                           │ │
│ │ │   └── Features/                                                                                                                       │ │
│ │ │       ├── Attendance/Commands/ (NEW)                                                                                                  │ │
│ │ │       └── Attendance/Queries/ (NEW)                                                                                                   │ │
│ │ ├── Infrastructure/                                                                                                                     │ │
│ │ │   └── Repositories/                                                                                                                   │ │
│ │ │       ├── AttendanceLogRepository.cs (NEW)                                                                                            │ │
│ │ │       └── WorkplaceLocationRepository.cs (NEW)                                                                                        │ │
│ │ └── API/                                                                                                                                │ │
│ │     └── Controllers/                                                                                                                    │ │
│ │         ├── AttendanceController.cs (NEW)                                                                                               │ │
│ │         └── WorkplaceLocationController.cs (NEW)                                                                                        │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ ⚙️ Teknik Detaylar                                                                                                                      │ │
│ │                                                                                                                                         │ │
│ │ iOS Geofencing Best Practices:                                                                                                          │ │
│ │                                                                                                                                         │ │
│ │ - Minimum radius: 100m (Apple önerisi)                                                                                                  │ │
│ │ - Maximum monitored regions: 20                                                                                                         │ │
│ │ - Battery optimization: Significant location change kullan                                                                              │ │
│ │ - Background mode: location aktif                                                                                                       │ │
│ │                                                                                                                                         │ │
│ │ Backend Optimizations:                                                                                                                  │ │
│ │                                                                                                                                         │ │
│ │ - Bulk insert için EF Core BulkExtensions                                                                                               │ │
│ │ - Index: (CompanyId, CrmPersonnelId, Timestamp)                                                                                         │ │
│ │ - Pagination: Büyük rapor sorguları için                                                                                                │ │
│ │ - Caching: Workplace locations (Redis/Memory)                                                                                           │ │
│ │                                                                                                                                         │ │
│ │ ---                                                                                                                                     │ │
│ │ 🎯 İmplementasyon Sırası                                                                                                                │ │
│ │                                                                                                                                         │ │
│ │ 1. Backend Foundation (1-2 gün)                                                                                                         │ │
│ │   - Entities + Migrations                                                                                                               │ │
│ │   - Basic CRUD APIs                                                                                                                     │ │
│ │ 2. iOS Core (2-3 gün)                                                                                                                   │ │
│ │   - LocationManager + GeofenceManager                                                                                                   │ │
│ │   - CoreData models                                                                                                                     │ │
│ │ 3. iOS Business Logic (2 gün)                                                                                                           │ │
│ │   - Services + ViewModels                                                                                                               │ │
│ │   - API integration                                                                                                                     │ │
│ │ 4. iOS UI (2 gün)                                                                                                                       │ │
│ │   - Attendance screens                                                                                                                  │ │
│ │   - History & reporting                                                                                                                 │ │
│ │ 5. Sync Mechanism (1-2 gün)                                                                                                             │ │
│ │   - Background tasks                                                                                                                    │ │
│ │   - Offline queue                                                                                                                       │ │
│ │ 6. Backend Advanced (1 gün)                                                                                                             │ │
│ │   - Batch APIs                                                                                                                          │ │
│ │   - Validations                                                                                                                         │ │
│ │ 7. Testing & QA (2-3 gün)                                                                                                               │ │
│ │   - Unit tests                                                                                                                          │ │
│ │   - Integration tests                                                                                                                   │ │
│ │   - Field testing 