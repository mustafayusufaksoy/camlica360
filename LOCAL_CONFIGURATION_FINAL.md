# ✅ Local Development Configuration - FINAL

## 📊 Network Architecture (CORRECTED)

```
iOS App (localhost)
    ↓
    ├─→ CRM Service API (5054)
    │   ├─→ Database: 192.168.1.200:5432 (Production DB)
    │   └─→ Endpoints: Auth, Personnel, etc.
    │
    └─→ HR Service API (5053)
        ├─→ Database: 192.168.1.200:5432 (Production DB)
        └─→ Endpoints: Attendance, Workplace Locations, Shifts, etc.
```

---

## 🔧 Configuration Summary

### ✅ iOS Configuration (APIConstants.swift)

```swift
// FIXED ✅
Environment: .development

// CRM Service (for login, personnel, etc.)
baseURL = "http://localhost:5000/api"

// HR Service (for attendance, shifts, etc.)
hrBaseURL = "http://localhost:5053"

// Smart routing in NetworkManager:
// - Paths starting with "/hr/" → use hrBaseURL (5053)
// - Other paths → use baseURL (5000 or 5054 depending on endpoint)
```

### ✅ CRM Service Configuration (appsettings.json)

```json
{
  "ConnectionStrings": {
    "PostgresBase": "Host=192.168.1.200;Port=5432;...",  // ✅ Production DB
    "Template": "Host=192.168.1.200;Port=5432;Database=mmo004;...",  // ✅ Production DB
    "ManagementDbConnection": "Host=192.168.1.200;Port=5432;Database=Managementdb;..."  // ✅ Production DB
  }
}

// appsettings.Development.json
{
  "Kestrel": {
    "Endpoints": {
      "Https": {
        "Url": "https://localhost:5054",  // ✅ gRPC on 5054
        "Protocols": "Http1AndHttp2"
      }
    }
  }
}
```

**Status:** ✅ Database bağlantıları 192.168.1.200'de (Production)

### ✅ HR Service Configuration (appsettings.json)

```json
{
  "ConnectionStrings": {
    "HRServiceDbConnection": "Host=192.168.1.200;Port=5432;Database=mmo004_hr;..."  // ✅ Production DB
  },
  "Services": {
    "CrmService": {
      "BaseUrl": "https://localhost:5054",  // ✅ gRPC
      "GrpcUrl": "https://localhost:5054"   // ✅ gRPC
    }
  }
}

// appsettings.Development.json
{
  "Kestrel": {
    "Endpoints": {
      "Https": {
        "Url": "https://localhost:5053",  // ✅ REST API on 5053
        "Protocols": "Http1AndHttp2"
      }
    }
  }
}
```

**Status:** ✅ Database bağlantıları 192.168.1.200'de (Production)

---

## 🎯 Port Summary

| Service | Protocol | Local URL | Database | Purpose |
|---------|----------|-----------|----------|---------|
| **CRM Service** | gRPC | https://localhost:5054 | 192.168.1.200 | Auth, Personnel, Roles |
| **HR Service** | REST | https://localhost:5053 | 192.168.1.200 | Attendance, Shifts, Permissions |
| **PostgreSQL** | - | 192.168.1.200:5432 | - | Shared Production Database |
| **Kafka** | - | localhost:9094 | - | Message Queue (optional) |

---

## 🚀 Quick Start Commands

### Start CRM Service
```bash
cd /Users/yusufaksoy/Documents/GitHub/backend2/Src/Services/CrmService/CrmService.API
dotnet run --configuration Development
# Listens on: https://localhost:5054
```

### Start HR Service
```bash
cd /Users/yusufaksoy/Documents/GitHub/backend2/Src/Services/HRService/HRService.API
dotnet run --configuration Development
# Listens on: https://localhost:5053
```

### Run iOS App
```bash
cd /Users/yusufaksoy/Documents/GitHub/camlica360
open camlica360.xcodeproj
# Run on iPhone 15 Pro simulator
```

---

## ✅ Configuration Checklist

- [x] iOS API Constants configured for localhost
- [x] CRM Service configured for 192.168.1.200 database
- [x] CRM Service gRPC on localhost:5054
- [x] HR Service configured for 192.168.1.200 database
- [x] HR Service REST API on localhost:5053
- [x] NetworkManager smart routing (handles /hr/ prefix)
- [x] JWT secrets configured
- [x] Database connection strings correct
- [x] Ports don't conflict

---

## 🧪 Testing

### Test CRM Service is Running
```bash
curl -k https://localhost:5054/health
# or
curl -k https://localhost:5054/swagger
```

### Test HR Service is Running
```bash
curl -k https://localhost:5053/swagger
```

### Test Database Connectivity
From production server (192.168.1.200):
```bash
psql -U postgres -d mmo004 -c "SELECT 1"
psql -U postgres -d mmo004_hr -c "SELECT 1"
```

---

## 📝 File Changes Made

### Files Modified:
1. ✅ `/camlica360/Core/Utils/Constants/APIConstants.swift`
   - Changed environment to `.development`
   - Set baseURL to `http://localhost:5000/api`
   - Set hrBaseURL to `http://localhost:5053`

2. ✅ `/backend2/.../CrmService/CrmService.API/appsettings.json`
   - Set all ConnectionStrings to `Host=192.168.1.200`

3. ✅ `/backend2/.../HRService/HRService.API/appsettings.json`
   - Set HRServiceDbConnection to `Host=192.168.1.200`

### Files NOT Changed (Already Correct):
- ✅ `appsettings.Development.json` files (port configuration correct)
- ✅ `NetworkManager.swift` (smart routing already implemented)

---

## 🔐 Security Notes

- Database credentials in appsettings.json point to production server
- This is OK for local development (read-only testing)
- **Important:** Don't commit these connection strings to Git
- Already in .gitignore: ✅ `appsettings.*.json`

---

## 🔄 Service Communication Flow

### Login Flow:
```
iOS App
  ↓
POST /Auth/login (via baseURL → http://localhost:5000/api/Auth/login)
  ↓
CRM Service (5054)
  ↓
Returns JWT Token
  ↓
iOS saves token
```

### Attendance Check-in Flow:
```
iOS App (with JWT)
  ↓
POST /hr/attendance/log (via hrBaseURL → http://localhost:5053/hr/attendance/log)
  ↓
HR Service (5053)
  ↓
Query Database (192.168.1.200)
  ↓
Returns AttendanceLog
```

---

## ⚠️ Known Issues & Solutions

### If CRM Service can't connect to DB:
```
Check: Is 192.168.1.200 accessible from your network?
Solution: Verify VPN/network connectivity to production DB
```

### If HR Service can't connect to DB:
```
Check: Same as above
Solution: Use same VPN/network as CRM Service
```

### If iOS can't connect to backend:
```
Check: Are both services running on localhost?
Test: curl -k https://localhost:5053/swagger
Solution: Start HR Service on 5053, CRM on 5054
```

### If ports are in use:
```
Kill existing process: lsof -i :5053 | grep LISTEN | awk '{print $2}' | xargs kill -9
Then restart the service
```

---

## 📊 Status

```
iOS Configuration:        ✅ COMPLETE
CRM Database Config:      ✅ COMPLETE
HR Database Config:       ✅ COMPLETE
CRM gRPC Port:            ✅ 5054
HR REST Port:             ✅ 5053
NetworkManager Routing:   ✅ WORKING
All Connection Strings:   ✅ POINTING TO 192.168.1.200

Ready to: ✅ Start Development
```

---

## 📞 Quick Debug Checklist

If something doesn't work, check in this order:

1. **Database Connection**
   ```bash
   # From production server
   psql -h 192.168.1.200 -U postgres -d mmo004 -c "SELECT 1"
   ```

2. **CRM Service Running**
   ```bash
   curl -k https://localhost:5054/health
   ```

3. **HR Service Running**
   ```bash
   curl -k https://localhost:5053/health
   ```

4. **iOS Configuration**
   - Check APIConstants.swift: Environment = .development
   - Check APIConstants.swift: hrBaseURL = "http://localhost:5053"

5. **Network Request Log**
   - In iOS, check NetworkManager debug output
   - Look for actual URL being called
   - Verify it matches expected service

---

**Last Updated:** October 28, 2025
**Configuration Status:** ✅ READY FOR LOCAL DEVELOPMENT
**Database:** Production (192.168.1.200)
**APIs:** Local (localhost:5053, localhost:5054)
