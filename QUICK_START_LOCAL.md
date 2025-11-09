# 🚀 Local Development Setup - Quick Start Guide

## ⚡ 5-Minute Setup (To Get Running)

### Step 1: Fix Configuration (DONE ✅)
```swift
// iOS: APIConstants.swift - ALREADY FIXED
✅ Environment: .development
✅ Base URL: http://localhost:5000/api
✅ HR Base URL: http://localhost:5053
```

```json
// Backend: appsettings.json - ALREADY FIXED
✅ Database: localhost:5432
✅ CRM Service: https://localhost:5054
```

### Step 2: Start PostgreSQL (REQUIRED)

**Option A: Using Homebrew (macOS)**
```bash
# Install PostgreSQL if not installed
brew install postgresql@15

# Start service
brew services start postgresql@15

# Verify running
psql -U postgres -c "SELECT 1"
```

**Option B: Using Docker**
```bash
docker run -d \
  --name postgres-local \
  -e POSTGRES_PASSWORD=c3d3040cf240310a16d8fbf423ccdcff212ede69210c2e95619fdb8a30a87da8 \
  -e POSTGRES_DB=mmo004_hr \
  -p 5432:5432 \
  postgres:15

# Verify
docker logs postgres-local
```

### Step 3: Start Backend

```bash
cd /Users/yusufaksoy/Documents/GitHub/backend2/Src/Services/HRService/HRService.API

# Install dependencies
dotnet restore

# Run
dotnet run --configuration Development
```

**Expected output:**
```
info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
      Request starting HTTPS GET https://localhost:5053/swagger/index.html
```

**Test Backend:**
```bash
curl -k https://localhost:5053/swagger
# Should return HTML
```

### Step 4: Run iOS App

```bash
cd /Users/yusufaksoy/Documents/GitHub/camlica360

# Open in Xcode
open camlica360.xcodeproj
```

Then:
1. Select iPhone 15 Pro simulator
2. Click ▶ Run button
3. App should launch

---

## ✅ What's Already Done

### Backend
- ✅ AttendanceLog entity created
- ✅ WorkplaceLocation entity created
- ✅ All DTOs created
- ✅ Both Controllers scaffolded
- ✅ API endpoints defined
- ✅ appsettings.json configured for localhost

### iOS
- ✅ LocationManager implemented
- ✅ GeofenceManager implemented
- ✅ AttendanceService implemented
- ✅ AttendanceLocationService implemented
- ✅ AttendanceViewModel implemented
- ✅ AttendanceView UI implemented
- ✅ AttendanceHistoryView UI implemented
- ✅ Background sync (AttendanceBackgroundSync) implemented
- ✅ APIConstants configured for localhost
- ✅ LocalizationKeys updated
- ✅ All models created

---

## ❌ What's Still Needed (In Order of Priority)

### CRITICAL 🔴 (Blocks everything)

#### 1. Backend Service Implementations
**Estimated Time:** 2 hours

Files to create:
- `HRService.Application/Services/AttendanceService.cs`
- `HRService.Application/Services/WorkplaceLocationService.cs`
- `HRService.Application/Services/Abstract/IAttendanceService.cs`
- `HRService.Application/Services/Abstract/IWorkplaceLocationService.cs`

**What they do:**
- Handle database operations
- Validate business rules
- Return DTOs to controllers

#### 2. Repository Implementations
**Estimated Time:** 1 hour

Files to create:
- `HRService.Infrastructure/Repositories/AttendanceLogRepository.cs`
- `HRService.Infrastructure/Repositories/WorkplaceLocationRepository.cs`

**What they do:**
- Execute LINQ queries
- Save/update entities
- Handle pagination

#### 3. Database Migrations
**Estimated Time:** 30 minutes

Files to create:
- `HRService.Infrastructure/Migrations/[timestamp]_AddAttendanceLogTable.cs`
- `HRService.Infrastructure/Migrations/[timestamp]_AddWorkplaceLocationTable.cs`

**What they do:**
- Create database tables
- Add indices
- Define relationships

### IMPORTANT 🟡 (Blocks iOS features)

#### 4. Add Localization Strings to iOS
**Estimated Time:** 15 minutes

File to update:
- `camlica360/Resources/Localization/Localizable.xcstrings`

Add 40+ strings like:
```json
{
  "key": "attendance_title",
  "localizations": {
    "en": { "stringUnit": { "state": "translated", "value": "Attendance Tracking" } },
    "tr": { "stringUnit": { "state": "translated", "value": "Giriş-Çıkış Takibi" } }
  }
}
```

#### 5. Update iOS Info.plist
**Estimated Time:** 5 minutes

Add location permissions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>To track your workplace check-ins</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>To enable background attendance tracking</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

#### 6. Add Xcode Capabilities
**Estimated Time:** 2 minutes

1. Open camlica360.xcodeproj in Xcode
2. Target → Signing & Capabilities
3. + Capability → Background Modes
4. Enable "Location updates"

---

## 🧪 Testing Strategy (Current Status)

### ✅ Works Now (No API needed)
```
1. LocationManager
   - Simulating location updates
   - Mock coordinates

2. GeofenceManager
   - Setting up regions
   - Detecting entry/exit

3. ViewModels
   - State management
   - UI updates

4. Offline Queue
   - Saving to UserDefaults
   - Persistence across app restarts
```

### ⏳ Works When Backend Services Implemented
```
1. API Calls
   - POST /hr/attendance/log
   - GET /hr/attendance/log/{id}
   - POST /hr/attendance/log/batch

2. Database Operations
   - Attendance logs saved
   - Workplace locations retrieved
   - History queries work

3. Offline Sync
   - Pending logs uploaded
   - Duplicates detected
   - Sync status updated
```

---

## 🔄 Development Workflow

### Day 1: Database & Repositories
```
1. Create migration files
2. Run: dotnet ef database update
3. Create repository interfaces
4. Implement repositories with EF Core
5. Test CRUD operations
```

### Day 2: Backend Services
```
1. Create service interfaces
2. Implement AttendanceService
3. Implement WorkplaceLocationService
4. Add validation/business logic
5. Register in DI container
```

### Day 3: iOS Integration
```
1. Add localization strings
2. Update Info.plist
3. Add Xcode capabilities
4. Test location permissions
5. Test API integration with mock data
```

### Day 4: Testing & Debug
```
1. Test online scenario
2. Test offline scenario
3. Test background sync
4. Test duplicate detection
5. Fix bugs
```

---

## 🛠️ Troubleshooting

### Backend Won't Start

**Error: "Connection refused" on port 5053**
```
→ Backend not running
→ Check: dotnet run output
→ Fix: Run in right directory
```

**Error: "Database connection failed"**
```
→ PostgreSQL not running
→ Check: psql -U postgres
→ Fix: brew services start postgresql@15
```

**Error: "Services not registered"**
```
→ Service interfaces missing
→ Fix: Create AttendanceService.cs
```

### iOS Won't Connect

**Error: "Cannot connect to server"**
```
→ Backend not running on localhost:5053
→ Check: curl -k https://localhost:5053/swagger
→ Fix: Start backend first
```

**Error: "Location permission denied"**
```
→ Info.plist missing permissions
→ Check: Open Info.plist, search "NSLocation"
→ Fix: Add location description strings
```

**Error: "Background location not working"**
```
→ UIBackgroundModes not enabled
→ Check: Xcode Capabilities → Background Modes
→ Fix: Enable "Location updates"
```

---

## 📊 API Testing with curl

### Test Endpoints (After Service Implementation)

**1. Create Location**
```bash
curl -X POST https://localhost:5053/hr/workplace-location/create \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Cookie: cc=demo" \
  -d '{
    "companyId": "00000000-0000-0000-0000-000000000001",
    "name": "Istanbul Office",
    "address": "Taksim, Istanbul",
    "latitude": 41.0367,
    "longitude": 28.9852,
    "radiusInMeters": 150
  }' \
  -k
```

**2. Log Attendance**
```bash
curl -X POST https://localhost:5053/hr/attendance/log \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Cookie: cc=demo" \
  -d '{
    "crmPersonnelId": "00000000-0000-0000-0000-000000000002",
    "workplaceLocationId": "00000000-0000-0000-0000-000000000001",
    "eventType": 0,
    "timestamp": "2025-10-28T14:30:00Z",
    "latitude": 41.0367,
    "longitude": 28.9852,
    "accuracyInMeters": 20,
    "deviceInfo": "iOS 17.0 - iPhone 15 Pro",
    "isManual": false,
    "note": null
  }' \
  -k
```

**3. Get Active Locations**
```bash
curl -X GET "https://localhost:5053/hr/workplace-location/getActiveByCompany/00000000-0000-0000-0000-000000000001" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Cookie: cc=demo" \
  -k
```

**4. Batch Sync Offline Logs**
```bash
curl -X POST https://localhost:5053/hr/attendance/log/batch \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Cookie: cc=demo" \
  -d '{
    "logs": [
      {
        "crmPersonnelId": "00000000-0000-0000-0000-000000000002",
        "workplaceLocationId": "00000000-0000-0000-0000-000000000001",
        "eventType": 0,
        "timestamp": "2025-10-28T14:30:00Z",
        "latitude": 41.0367,
        "longitude": 28.9852,
        "accuracyInMeters": 20,
        "deviceInfo": "iOS",
        "isManual": false,
        "note": null
      }
    ],
    "clientTimestamp": "2025-10-28T14:35:00Z",
    "deviceId": "iPhone-001"
  }' \
  -k
```

---

## 📱 iOS Simulator Testing

### Location Simulation
```
1. Open Simulator
2. Features → Location → Custom Location...
3. Enter: 41.0367, 28.9852 (Istanbul)
4. App receives location update
```

### Background Testing
```
1. Run app in Simulator
2. Home button (Cmd+H) to background
3. Wait 15 minutes (or modify sync interval)
4. Pending logs should sync
```

### Network Simulation
```
1. Simulator → Develop → Condition...
2. Select "Poor Connection" or "Offline"
3. Offline queue captures logs
4. Switch back to online
5. Background sync triggers
```

---

## 🎯 Success Criteria

### Backend Ready When:
- [ ] All 3 service implementations complete
- [ ] All 2 repository implementations complete
- [ ] All 2 migrations created and run
- [ ] Services registered in DI container
- [ ] curl tests pass
- [ ] Swagger shows all endpoints

### iOS Ready When:
- [ ] All 40+ localization strings added
- [ ] Info.plist updated with location permissions
- [ ] Xcode capabilities enabled
- [ ] App launches without errors
- [ ] Location permission prompt appears
- [ ] Attendance view displays

---

## 📈 Progress Tracking

### Current Status
```
iOS Components:        100% ✅ (Services, ViewModels, Views)
Backend Components:     60% ⏳ (Entities, DTOs, Controllers only)
Database Schema:         0% ❌ (Migrations pending)
Services:               0% ❌ (Implementations pending)
iOS Integration:        70% ⏳ (Config done, strings/perms pending)
```

### Estimated Time to Full Working System
- Services + Repositories: **2 hours**
- Migrations: **30 minutes**
- iOS Localization: **15 minutes**
- Testing + Debugging: **1 hour**
- **Total: 4 hours from now**

---

## 🔗 Key Files Reference

### Configuration Files (ALREADY FIXED)
- `/camlica360/Core/Utils/Constants/APIConstants.swift` ✅ Updated
- `/backend2/.../HRService.API/appsettings.json` ✅ Updated

### Core Implementation Files (COMPLETE)
- `Core/Location/LocationManager.swift` ✅
- `Core/Location/GeofenceManager.swift` ✅
- `Modules/Attendance/Services/AttendanceService.swift` ✅
- `Modules/Attendance/ViewModels/AttendanceViewModel.swift` ✅
- `Modules/Attendance/Views/AttendanceView.swift` ✅

### Pending Implementation Files (TODO)
- `HRService.Application/Services/AttendanceService.cs` ❌
- `HRService.Application/Services/WorkplaceLocationService.cs` ❌
- `HRService.Infrastructure/Repositories/*.cs` ❌
- `HRService.Infrastructure/Migrations/*.cs` ❌

### iOS Configuration Files (TODO)
- `Localizable.xcstrings` - Add 40+ strings ❌
- `Info.plist` - Add location permissions ❌

---

## 📞 Getting Help

### If Backend Won't Run:
1. Check PostgreSQL: `psql -U postgres`
2. Check appsettings.json: localhost:5432
3. Check dotnet version: `dotnet --version`
4. Check service interfaces: AttendanceService.cs exists?

### If iOS Won't Connect:
1. Check backend running: `curl -k https://localhost:5053/swagger`
2. Check API constants: localhost:5053
3. Check network errors in console
4. Try with different network (WiFi vs Ethernet)

### If Permissions Not Working:
1. Check Info.plist has NSLocationWhenInUseUsageDescription
2. Check Xcode capabilities enabled
3. Try on real device (simulator sometimes buggy)
4. Clear app data and reinstall

---

**Last Updated:** October 28, 2025
**Status:** Ready for local development
**Next Step:** Implement backend services (copy-paste templates in docs)
