# ⚙️ Konum Tabanlı Giriş-Çıkış Sistemi - Local Setup Kontrol Listesi

## 🔴 TAMAMLANMIŞ: Network Configuration

### ✅ Backend API Configuration
```
appsettings.json:
- Database: localhost:5432 (from 192.168.1.200) ✅ FIXED
- CRM Service: https://localhost:5054
- Kafka: localhost:9094
- Kestrel Endpoint: https://localhost:5053
```

### ✅ iOS API Configuration
```
APIConstants.swift:
- Environment: .development (from .production) ✅ FIXED
- Base URL: http://localhost:5000/api (from 192.168.1.101:8080)
- HR Base URL: http://localhost:5053 (from 192.168.1.101:5053)
```

---

## 📋 Kalan Eksik Bileşenler

### 🔴 KRITIK: Backend Dependencies (Gerekli)

#### 1. Database Service
- [ ] PostgreSQL running on localhost:5432
- [ ] Database: `mmo004_hr` created
- [ ] User: postgres / Password: c3d3040cf240310a16d8fbf423ccdcff212ede69210c2e95619fdb8a30a87da8

**Check Command:**
```bash
psql -h localhost -U postgres -d mmo004_hr -c "SELECT 1"
```

#### 2. Message Queue
- [ ] Kafka running on localhost:9094
- [ ] Topics: `somed-events-hr` created (optional, Kafka creates auto)

**Check Command:**
```bash
kafka-topics.sh --list --bootstrap-server localhost:9094
```

#### 3. CRM Service (gRPC)
- [ ] CRM Service running on https://localhost:5054
- [ ] gRPC endpoint accessible
- [ ] SSL certificate (self-signed acceptable in dev)

**Note:** Backend can work without CRM, but CrmPersonnelGrpcService calls will fail

---

## 🔧 Backend Implementation Checklist

### Missing Service Implementations (Critical for API to work)

#### ❌ TODO: IAttendanceService Implementation

**File:** `HRService.Application/Services/AttendanceService.cs` (needs creation)

```csharp
public interface IAttendanceService
{
    Task<AttendanceLogResponseDto> CreateAttendanceLogAsync(
        CreateAttendanceLogDto dto, string companyCode);

    Task<BatchAttendanceLogResponseDto> CreateBatchAttendanceLogsAsync(
        BatchAttendanceLogDto dto, string companyCode);

    Task<List<GetAttendanceLogDto>> GetAttendanceLogsByPersonnelAsync(
        Guid personnelId, DateTime startDate, DateTime endDate, string companyCode);

    Task<List<GetAttendanceLogDto>> GetCompanyAttendanceLogsAsync(
        Guid companyId, DateTime startDate, DateTime endDate,
        int pageNumber, int pageSize, string companyCode);

    Task<LocationValidationResult> ValidateLocationAsync(
        Guid workplaceLocationId, double latitude, double longitude, string companyCode);
}
```

#### ❌ TODO: IWorkplaceLocationService Implementation

**File:** `HRService.Application/Services/WorkplaceLocationService.cs` (needs creation)

```csharp
public interface IWorkplaceLocationService
{
    Task<GetWorkplaceLocationDto> CreateWorkplaceLocationAsync(
        CreateWorkplaceLocationDto dto, string companyCode);

    Task<GetWorkplaceLocationDto> UpdateWorkplaceLocationAsync(
        UpdateWorkplaceLocationDto dto, string companyCode);

    Task<bool> DeleteWorkplaceLocationAsync(
        Guid id, Guid deletedByUserId, string companyCode);

    Task<GetWorkplaceLocationDto> GetWorkplaceLocationByIdAsync(
        Guid id, string companyCode);

    Task<List<GetWorkplaceLocationDto>> GetWorkplaceLocationsByCompanyAsync(
        Guid companyId, string companyCode);

    Task<List<GetWorkplaceLocationDto>> GetActiveWorkplaceLocationsAsync(
        Guid companyId, string companyCode);
}
```

#### ❌ TODO: Repository Implementations

**Files needed:**
- `HRService.Infrastructure/Repositories/AttendanceLogRepository.cs`
- `HRService.Infrastructure/Repositories/WorkplaceLocationRepository.cs`

#### ❌ TODO: Database Migrations

**Files needed:**
- `HRService.Infrastructure/Migrations/20251028_AddAttendanceLogTable.cs`
- `HRService.Infrastructure/Migrations/20251028_AddWorkplaceLocationTable.cs`

---

## 📱 iOS Missing Components

### ❌ TODO: Add to Localizable.xcstrings

Add these 40+ localization strings:

**Attendance Module:**
```
attendance_title = "Giriş-Çıkış Takibi"
attendance_subtitle = "Konumunuzu takip edin ve giriş-çıkış yapın"
attendance_check_in = "Giriş"
attendance_check_out = "Çıkış"
check_in_successful = "Başarıyla giriş yaptınız"
check_out_successful = "Başarıyla çıkış yaptınız"
not_in_workplace = "Işyeri alanı dışındasınız"
pending_logs = "Senkronize Edilmek Bekleyen Kayıtlar"
pending_logs_count = "%d kayıt senkronize edilmeyi beklemektedir"
sync = "Senkronize Et"
offline_log_saved = "Çevrim dışı - kayıt lokal olarak kaydedildi"
todays_logs = "Bugünün Kayıtları"
attendance_history = "Giriş-Çıkış Geçmişi"
view_history = "Geçmişi Görüntüle"

[... 25+ more strings in the guide ...]
```

### ❌ TODO: Update Info.plist

Add location permissions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Işyerinize girip çıkmanızı takip etmek için konumunuza erişim gereklidir</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Arka planda giriş-çıkış takibini sağlamak için konumunuza her zaman erişim gereklidir</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

### ❌ TODO: Xcode Capabilities

1. Open project in Xcode
2. Select target → Signing & Capabilities
3. Add:
   - Background Modes → Location updates
   - Background Fetch (optional)

---

## 🚀 Run Backend Locally

### Step 1: Start PostgreSQL
```bash
# Mac with Homebrew
brew services start postgresql@15

# Or Docker
docker run -d \
  -e POSTGRES_PASSWORD=c3d3040cf240310a16d8fbf423ccdcff212ede69210c2e95619fdb8a30a87da8 \
  -e POSTGRES_DB=mmo004_hr \
  -p 5432:5432 \
  postgres:15
```

### Step 2: Start Kafka (Optional, can skip)
```bash
# Docker Compose
docker-compose up kafka

# Or manual:
docker run -d \
  -p 9092:9092 \
  -p 9094:9094 \
  confluentinc/cp-kafka:7.5.0
```

### Step 3: Build and Run Backend
```bash
cd /Users/yusufaksoy/Documents/GitHub/backend2/Src/Services/HRService/HRService.API

# Restore dependencies
dotnet restore

# Run migrations (if implemented)
dotnet ef database update

# Run API
dotnet run --configuration Development
```

**Expected Output:**
```
info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
      Request starting HTTP/1.1 GET https://localhost:5053/swagger
```

---

## 📱 Run iOS Locally

### Step 1: Verify Backend Running
```bash
curl -k https://localhost:5053/swagger
```

### Step 2: Open Xcode Project
```bash
cd /Users/yusufaksoy/Documents/GitHub/camlica360
open camlica360.xcodeproj
```

### Step 3: Configure Signing
1. Select camlica360 target
2. Signing & Capabilities
3. Select team (or skip signing)

### Step 4: Add Location Permissions
1. Info tab → Add location descriptions
2. Capabilities → Background Modes → Location updates

### Step 5: Run on Simulator
```bash
# Select iPhone 15 Pro simulator
# Click Play button
```

**Expected First Screen:**
- Permission request dialog
- "Giriş-Çıkış Takibi" title visible

---

## 🧪 Quick Test Endpoints

### Test Attendance API (after implementation)

```bash
# Login first (get JWT token from CRM service)
curl -X POST https://localhost:5053/hr/attendance/log \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Cookie: cc=demo" \
  -d '{
    "crmPersonnelId": "550e8400-e29b-41d4-a716-446655440000",
    "workplaceLocationId": "550e8400-e29b-41d4-a716-446655440001",
    "eventType": 0,
    "timestamp": "2025-10-28T14:30:00Z",
    "latitude": 41.0082,
    "longitude": 28.9784,
    "accuracyInMeters": 20.0,
    "deviceInfo": "iOS 17.0",
    "isManual": false
  }' \
  -k

# Get workplace locations (mock data, before implementation)
curl -X GET https://localhost:5053/hr/workplace-location/getActiveByCompany/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Cookie: cc=demo" \
  -k
```

---

## 🔴 Critical Issues to Fix Now

### Priority 1: Database Setup
- [ ] Verify PostgreSQL accessibility
- [ ] Create `mmo004_hr` database
- [ ] Test connection string

### Priority 2: Service Implementations
- [ ] Implement IAttendanceService
- [ ] Implement IWorkplaceLocationService
- [ ] Implement repositories
- [ ] Create database migrations

### Priority 3: iOS Setup
- [ ] Add localization strings
- [ ] Update Info.plist
- [ ] Add Xcode capabilities
- [ ] Test location permissions

### Priority 4: Integration
- [ ] Register services in DI container
- [ ] Add middleware/auth
- [ ] Test API endpoints
- [ ] Test offline sync logic

---

## 📊 Status Summary

| Component | Status | Action |
|-----------|--------|--------|
| iOS API Config | ✅ Fixed | Use localhost:5053 |
| Backend DB Config | ✅ Fixed | Use localhost:5432 |
| LocationManager | ✅ Done | Ready to use |
| GeofenceManager | ✅ Done | Ready to use |
| AttendanceService | ✅ Done | Ready to use |
| AttendanceViewModel | ✅ Done | Ready to use |
| AttendanceView | ✅ Done | Ready to use |
| **IAttendanceService** | ❌ Pending | **NEEDS IMPLEMENTATION** |
| **AttendanceService (backend)** | ❌ Pending | **NEEDS IMPLEMENTATION** |
| **Repositories** | ❌ Pending | **NEEDS IMPLEMENTATION** |
| **Migrations** | ❌ Pending | **NEEDS IMPLEMENTATION** |
| Localization Strings | ❌ Pending | **NEEDS ADDITION** |
| Info.plist | ❌ Pending | **NEEDS UPDATE** |
| Xcode Capabilities | ❌ Pending | **NEEDS SETUP** |

---

## 🎯 Quick Start (Current State)

### To Run Backend Now:
```bash
1. dotnet run --configuration Development
2. API accessible on https://localhost:5053
3. Swagger UI: https://localhost:5053/swagger
```

### To Run iOS Now:
```bash
1. Update Info.plist with location permissions (see above)
2. Add location strings to Localizable.xcstrings
3. Run on simulator
4. Grant location permission when prompted
```

### What Works Right Now:
✅ Location tracking (LocationManager)
✅ Geofence setup (GeofenceManager)
✅ UI screens (AttendanceView)
✅ ViewModel logic (AttendanceViewModel)
✅ Offline queue persistence
✅ Background sync scheduling

### What Doesn't Work Yet:
❌ API calls (services not implemented)
❌ Database operations (migrations missing)
❌ Localization strings (not added)
❌ Permissions prompt (Info.plist missing)

---

## 📞 Next Immediate Actions

1. **Start PostgreSQL** on localhost:5432
2. **Implement backend services** (copy-paste templates available in docs)
3. **Create database migrations**
4. **Add localization strings** to Localizable.xcstrings
5. **Update Info.plist** with location permissions
6. **Test API endpoints** with curl/Postman
7. **Test iOS app** on simulator with real permission prompts

---

**Generated:** October 28, 2025
**Status:** Local development setup in progress
**Next Phase:** Backend service implementations

