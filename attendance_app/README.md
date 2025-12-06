# Attendance App - Flutter Offline-First Architecture

A professional, production-ready Flutter attendance tracking application with offline-first architecture, GPS tracking, geofencing, and cloud synchronization.

## 🎯 Project Overview

This app provides a robust attendance tracking solution with:
- **Offline-first architecture** - All actions work instantly, even without internet
- **Intelligent synchronization** - Background sync engine with conflict resolution
- **GPS tracking** - Mandatory location capture for every clock action
- **Geofencing** - Validates if users are within authorized work areas
- **Google OAuth** - Secure authentication with JWT tokens
- **Clean Architecture** - Organized into Data, Domain, and Presentation layers

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── src/
│   ├── data/                      # Data Layer
│   │   ├── models/                # Freezed data models
│   │   ├── datasources/           # Local (Hive) and Remote (API)
│   │   └── repositories/          # Repository implementations
│   ├── domain/                    # Domain Layer
│   │   ├── entities/              # Business entities
│   │   ├── repositories/          # Repository interfaces
│   │   └── usecases/              # Business logic use cases
│   ├── presentation/              # Presentation Layer
│   │   ├── pages/                 # UI screens
│   │   ├── widgets/               # Reusable widgets
│   │   └── providers/             # Riverpod providers
│   └── core/                      # Core utilities
│       ├── services/              # Sync, Location, Notifications
│       ├── utils/                 # Helper functions
│       └── constants/             # App constants
└── main.dart                      # App entry point
```

## 📦 Technology Stack

### Core Framework
- **Flutter** (Dart) - Cross-platform mobile development
- **Riverpod** - State management and dependency injection

### Data & Storage
- **Hive** - Fast, lightweight local NoSQL database
- **MongoDB Atlas** - Cloud database (backend)
- **flutter_secure_storage** - Secure JWT token storage

### Networking
- **Dio** - HTTP client for API calls
- **connectivity_plus** - Network status monitoring

### Authentication
- **Google Sign-In** - OAuth 2.0 authentication
- **JWT** - Stateless token-based authentication

### Location & Geofencing
- **geolocator** - GPS location services
- **google_maps_flutter** - Map display
- Haversine formula for distance calculation

### Notifications
- **flutter_local_notifications** - Local push notifications

### Code Generation
- **freezed** - Immutable data classes
- **json_serializable** - JSON serialization
- **build_runner** - Code generation tool

## 🚀 Getting Started

### Prerequisites

1. **Install Flutter SDK** (3.0.0 or higher)
   ```bash
   # macOS (using Homebrew)
   brew install flutter
   
   # Verify installation
   flutter doctor
   ```

2. **Install dependencies**
   ```bash
   cd /Users/vikrant/Documents/Attendance/attendance_app
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Configuration

#### 1. Google Cloud Setup (for OAuth)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable **Google Sign-In API**
4. Create OAuth 2.0 credentials:
   - **iOS**: Add iOS OAuth client ID
   - **Android**: Add Android OAuth client ID
   - Get the SHA-1 fingerprint: `keytool -list -v -keystore ~/.android/debug.keystore`

5. Update configuration files:

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.gms.auth.api.signin.client_id"
    android:value="YOUR_ANDROID_CLIENT_ID" />
```

#### 2. Backend API Configuration

Update the base URL in `lib/src/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-domain.com';
```

#### 3. Location Permissions

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to track attendance</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs your location to track attendance</string>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Build for production
flutter build apk --release          # Android
flutter build ios --release          # iOS
```

## 🔄 Synchronization Engine

### How It Works

1. **Offline Actions**: All clock in/out actions are saved to Hive (local database) immediately
2. **Sync Queue**: Each action is added to a sync queue with:
   - `clientId` (UUID) - Unique identifier
   - `clientTimestamp` - UTC timestamp
   - `syncStatus` - pending/syncing/synced/failed

3. **Automatic Sync Triggers**:
   - Network connectivity restored
   - App launched
   - Periodic interval (every 5 minutes)

4. **Conflict Resolution**:
   - **Last-Write-Wins (LWW)** strategy
   - Server uses `clientTimestamp` to order events
   - Server is the source of truth

5. **Retry Logic**:
   - Max 3 retry attempts
   - 5-second delay between retries
   - Failed records marked for manual review

### Sync Flow Diagram

```
User Action → Save to Hive (instant) → Add to Sync Queue
                    ↓
              Update UI (optimistic)
                    ↓
          Wait for network connection
                    ↓
         Batch upload to MongoDB (API)
                    ↓
    Server validates & applies LWW conflict resolution
                    ↓
         Update local records as "synced"
                    ↓
         Remove from sync queue
```

## 📱 Features Implementation

### 1. Clock In/Out
- GPS location mandatory
- Geofence validation
- Instant local save
- Background sync

### 2. GPS Tracking
- High accuracy mode
- Accuracy validation (< 50m recommended)
- Fallback to last known location

### 3. Geofencing
- Haversine formula for distance calculation
- Configurable radius (default: 100m)
- Visual feedback for out-of-zone actions

### 4. Dashboard
- Real-time sync status indicator
- Today's work hours
- Weekly summary
- Attendance history

### 5. Leave Management
- Submit leave requests
- View request status
- Approval workflow

### 6. Notifications
- Clock-out reminders
- Sync status updates
- Error notifications

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🚢 Deployment

### Android (Play Store)

1. **Update version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1
   ```

2. **Generate signing key**:
   ```bash
   keytool -genkey -v -keystore ~/attendance-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias attendance
   ```

3. **Configure signing** (`android/key.properties`):
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=attendance
   storeFile=<path-to-key>
   ```

4. **Build release**:
   ```bash
   flutter build appbundle --release
   ```

5. **Upload** to [Google Play Console](https://play.google.com/console)

### iOS (App Store)

1. **Configure Xcode** with provisioning profiles
2. **Build**:
   ```bash
   flutter build ios --release
   ```
3. **Archive and upload** via Xcode

## 📊 Backend API Endpoints

Your Node.js/Express backend should implement:

```
POST   /api/auth/google-verify       - Verify Google token, return JWT
GET    /api/users/profile             - Get user profile
POST   /api/sync-logs                 - Batch sync attendance logs
GET    /api/attendance-logs           - Get attendance history
GET    /api/geofences                 - Get geofence definitions
POST   /api/leave-requests            - Submit leave request
GET    /api/leave-requests            - Get leave requests
```

### Example Sync Request

```json
{
  "logs": [
    {
      "clientId": "uuid-v4",
      "actionType": "clockIn",
      "clientTimestamp": "2025-12-07T10:30:00.000Z",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "accuracy": 15.0,
      "withinGeofence": true
    }
  ],
  "clientTimestamp": "2025-12-07T10:30:05.000Z"
}
```

### Example Sync Response

```json
{
  "success": true,
  "syncedRecords": [
    {
      "clientId": "uuid-v4",
      "serverId": "mongo-object-id",
      "serverTimestamp": "2025-12-07T10:30:06.000Z"
    }
  ],
  "failedRecordIds": [],
  "serverTimestamp": "2025-12-07T10:30:06.000Z"
}
```

## 🔒 Security Best Practices

1. **JWT Tokens**: Stored in `flutter_secure_storage`
2. **HTTPS Only**: All API calls use TLS
3. **Token Refresh**: Implement refresh token logic
4. **Input Validation**: Server-side validation
5. **Rate Limiting**: Prevent API abuse

## 📈 Performance Optimization

- **Hive**: Fast local database (microsecond reads)
- **Lazy Loading**: Load data on demand
- **Pagination**: For large history lists
- **Image Optimization**: Compress user photos
- **Background Isolates**: For heavy computation

## 🐛 Debugging

Enable verbose logging:
```dart
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
  ),
);
```

View logs:
```bash
flutter logs
```

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Guide](https://riverpod.dev/)
- [Hive Database](https://docs.hivedb.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

MIT License - See LICENSE file for details

## 👨‍💻 Author

Built with ❤️ using Flutter

---

**Note**: This project structure is ready for development. You'll need to:
1. Install Flutter SDK
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build` to generate code
4. Configure Google OAuth credentials
5. Set up your backend API
6. Update API base URL in constants
