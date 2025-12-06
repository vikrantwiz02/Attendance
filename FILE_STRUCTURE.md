# 📁 Complete Project Structure

```
/Users/vikrant/Documents/Attendance/
│
├── 📚 Documentation (Root Level)
│   ├── INDEX.md                    # Documentation index (this is your starting point)
│   ├── QUICK_START.md              # 5-minute setup guide
│   ├── PROJECT_OVERVIEW.md         # Complete project documentation
│   ├── ARCHITECTURE.md             # System architecture & diagrams
│   ├── ROADMAP.md                  # Development roadmap & timeline
│   └── SUMMARY.md                  # Project deliverables summary
│
├── 📱 attendance_app/              # FLUTTER MOBILE APPLICATION
│   │
│   ├── 📄 Configuration Files
│   │   ├── pubspec.yaml            # Dependencies & assets
│   │   ├── analysis_options.yaml  # Dart linting rules
│   │   ├── setup.sh               # Automated setup script (chmod +x)
│   │   ├── .gitignore             # Git ignore patterns
│   │   └── README.md              # Flutter app documentation
│   │
│   ├── 📂 lib/
│   │   │
│   │   ├── main.dart              # App entry point
│   │   │
│   │   └── 📂 src/
│   │       │
│   │       ├── 📂 core/           # Core utilities & services
│   │       │   │
│   │       │   ├── 📂 constants/
│   │       │   │   └── app_constants.dart      # API URLs, configs
│   │       │   │
│   │       │   ├── 📂 services/
│   │       │   │   ├── sync_engine.dart        # ⭐ Background sync service
│   │       │   │   ├── location_service.dart   # GPS & geofencing
│   │       │   │   └── notification_service.dart  # Local notifications
│   │       │   │
│   │       │   └── 📂 utils/                   # (Ready for helpers)
│   │       │
│   │       ├── 📂 data/           # Data Layer
│   │       │   │
│   │       │   ├── 📂 models/     # Data models (Freezed)
│   │       │   │   ├── attendance_log.dart     # Clock in/out records
│   │       │   │   ├── user.dart               # User profile
│   │       │   │   ├── geofence.dart           # Geofence zones
│   │       │   │   ├── leave_request.dart      # Leave requests
│   │       │   │   └── sync_response.dart      # Sync API response
│   │       │   │
│   │       │   ├── 📂 datasources/
│   │       │   │   ├── local_data_source.dart  # ⭐ Hive local database
│   │       │   │   └── remote_data_source.dart # ⭐ Dio API client
│   │       │   │
│   │       │   └── 📂 repositories/
│   │       │       ├── attendance_repository_impl.dart
│   │       │       └── auth_repository_impl.dart
│   │       │
│   │       ├── 📂 domain/         # Domain Layer (Business Logic)
│   │       │   │
│   │       │   ├── 📂 entities/   # (Ready for domain entities)
│   │       │   │
│   │       │   ├── 📂 repositories/  # Repository interfaces
│   │       │   │   ├── attendance_repository.dart
│   │       │   │   └── auth_repository.dart
│   │       │   │
│   │       │   └── 📂 usecases/   # Business logic use cases
│   │       │       ├── auth_usecases.dart         # Sign in/out
│   │       │       └── clock_action_usecase.dart  # Clock in/out
│   │       │
│   │       └── 📂 presentation/   # Presentation Layer (UI)
│   │           │
│   │           ├── 📂 pages/      # Full-screen pages
│   │           │   ├── login_page.dart         # Google OAuth login
│   │           │   └── home_page.dart          # Clock in/out screen
│   │           │
│   │           ├── 📂 widgets/    # Reusable UI components
│   │           │   └── sync_status_banner.dart # Online/offline indicator
│   │           │
│   │           └── 📂 providers/  # Riverpod state management
│   │               └── service_providers.dart   # ⭐ DI container
│   │
│   ├── 📂 test/                   # Unit & widget tests (ready)
│   │
│   ├── 📂 assets/                 # App assets (created by setup.sh)
│   │   ├── images/
│   │   ├── icons/
│   │   └── fonts/
│   │
│   ├── 📂 android/                # Android-specific files (Flutter creates)
│   ├── 📂 ios/                    # iOS-specific files (Flutter creates)
│   └── 📂 web/                    # Web support (Flutter creates)
│
└── 🔧 backend/                    # NODE.JS/EXPRESS API SERVER
    │
    ├── 📄 Configuration Files
    │   ├── package.json           # Node dependencies
    │   ├── .env.example           # Environment variables template
    │   ├── .gitignore             # Git ignore patterns
    │   └── README.md              # Backend documentation
    │
    ├── server.js                  # ⭐ Express app entry point
    │
    ├── 📂 models/                 # MongoDB schemas (Mongoose)
    │   ├── User.js                # User model
    │   └── AttendanceLog.js       # Attendance log model
    │
    ├── 📂 routes/                 # API endpoints
    │   ├── auth.js                # POST /api/auth/google-verify
    │   ├── attendance.js          # POST /api/sync-logs, GET /api/attendance-logs
    │   ├── geofence.js            # GET /api/geofences
    │   └── leave.js               # POST /api/leave-requests, GET /api/leave-requests
    │
    ├── 📂 middleware/             # Express middleware
    │   └── auth.js                # ⭐ JWT authentication middleware
    │
    └── 📂 node_modules/           # (Created by npm install)
```

---

## 📊 File Count Summary

| Category | Count | Status |
|----------|-------|--------|
| **Documentation** | 7 files | ✅ Complete |
| **Flutter Files** | 20+ Dart files | ✅ Core complete |
| **Backend Files** | 10+ JS files | ✅ Core complete |
| **Config Files** | 5 files | ✅ Complete |
| **Total Files** | 42+ files | 🚀 Production-ready foundation |

---

## 🎯 Key Files to Understand

### Essential Flutter Files (Start Here)
1. **`lib/main.dart`** - App entry point, initialization
2. **`lib/src/presentation/providers/service_providers.dart`** - Dependency injection setup
3. **`lib/src/core/services/sync_engine.dart`** - The heart of offline-first
4. **`lib/src/data/datasources/local_data_source.dart`** - Hive database operations
5. **`lib/src/data/datasources/remote_data_source.dart`** - API client

### Essential Backend Files
1. **`server.js`** - Express server setup
2. **`routes/auth.js`** - Google OAuth verification
3. **`routes/attendance.js`** - Sync endpoint (critical!)
4. **`middleware/auth.js`** - JWT verification
5. **`models/AttendanceLog.js`** - Database schema

### Configuration Files (Must Edit)
1. **`backend/.env`** - MongoDB URI, JWT secret, Google Client ID
2. **`attendance_app/lib/src/core/constants/app_constants.dart`** - API base URL
3. **`attendance_app/android/app/src/main/AndroidManifest.xml`** - Android permissions
4. **`attendance_app/ios/Runner/Info.plist`** - iOS permissions

---

## 🔍 File Purpose Quick Reference

### Data Models (`lib/src/data/models/`)
- **attendance_log.dart** - Represents a clock in/out action with GPS data
- **user.dart** - User profile from Google OAuth
- **geofence.dart** - Office location boundaries
- **leave_request.dart** - Leave/vacation requests
- **sync_response.dart** - Server response format

### Services (`lib/src/core/services/`)
- **sync_engine.dart** - Monitors network, syncs pending data, conflict resolution
- **location_service.dart** - GPS access, geofence validation, distance calculation
- **notification_service.dart** - Local push notifications for reminders

### Repositories
- **Interfaces** (`domain/repositories/`) - Define what operations are possible
- **Implementations** (`data/repositories/`) - How operations are performed

### Use Cases (`lib/src/domain/usecases/`)
- **clock_action_usecase.dart** - Business logic for clocking in/out
- **auth_usecases.dart** - Sign in/out, get current user

---

## 📝 Notes

### Files Not Yet Created (Auto-generated)
These will be created when you run `flutter pub run build_runner build`:
- `*.g.dart` files (JSON serialization)
- `*.freezed.dart` files (Immutable models)

### Directories Created by Flutter
When you run `flutter create`, these are auto-generated:
- `android/` - Android app structure
- `ios/` - iOS app structure
- `web/` - Web support files
- `linux/`, `macos/`, `windows/` - Desktop support (optional)

### Not Included (Add as Needed)
- Unit tests in `test/`
- Integration tests
- Widget tests
- Assets (images, fonts) in `assets/`

---

## 🚀 Next Steps

1. **Install Flutter** (if not already)
   ```bash
   brew install flutter
   flutter doctor
   ```

2. **Run setup script**
   ```bash
   cd attendance_app
   ./setup.sh
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Start developing!**
   - Add new pages to `lib/src/presentation/pages/`
   - Create widgets in `lib/src/presentation/widgets/`
   - Add business logic in `lib/src/domain/usecases/`

---

**This structure follows Clean Architecture principles and industry best practices for scalable Flutter applications.**

*Last Updated: December 7, 2025*
