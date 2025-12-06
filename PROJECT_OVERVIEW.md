# 🎯 Flutter Offline-First Attendance App - Complete Project

## 📋 Project Overview

A professional-grade, production-ready Flutter attendance tracking application with:
- **Offline-first architecture** for instant user feedback
- **Intelligent cloud synchronization** with MongoDB backend
- **GPS tracking and geofencing** for location validation
- **Google OAuth authentication** with JWT tokens
- **Clean architecture** for maintainability and scalability

---

## 🏗️ Project Structure

```
/Users/vikrant/Documents/Attendance/
├── attendance_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   └── src/
│   │       ├── data/           # Data layer (models, datasources, repositories)
│   │       ├── domain/         # Domain layer (entities, use cases)
│   │       ├── presentation/   # UI layer (pages, widgets, providers)
│   │       └── core/           # Core services (sync, location, notifications)
│   ├── pubspec.yaml            # Flutter dependencies
│   ├── README.md               # Flutter app documentation
│   └── setup.sh                # Setup script
│
└── backend/                     # Node.js/Express API server
    ├── server.js               # Express server
    ├── models/                 # MongoDB schemas
    ├── routes/                 # API routes
    ├── middleware/             # Auth middleware
    ├── package.json            # Node dependencies
    └── README.md               # Backend documentation
```

---

## 🚀 Quick Start

### Prerequisites

1. **Flutter SDK** (3.0.0+)
   ```bash
   brew install flutter  # macOS
   flutter doctor        # Verify installation
   ```

2. **Node.js** (18.0.0+)
   ```bash
   brew install node
   ```

3. **MongoDB Atlas** account (free tier available)
   - Sign up at https://www.mongodb.com/cloud/atlas

4. **Google Cloud** account for OAuth setup
   - Create project at https://console.cloud.google.com/

### Flutter App Setup

```bash
cd attendance_app

# Make setup script executable
chmod +x setup.sh

# Run setup (installs dependencies and generates code)
./setup.sh

# OR manually:
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Edit .env with your MongoDB URI, JWT secret, and Google Client ID

# Start development server
npm run dev
```

---

## 🔧 Configuration

### 1. Google OAuth Setup

#### Step 1: Google Cloud Console
1. Go to https://console.cloud.google.com/
2. Create a new project "Attendance App"
3. Enable **Google Sign-In API**
4. Create OAuth 2.0 credentials:
   - **iOS Client ID**
   - **Android Client ID** 
   - **Web Client ID** (for backend verification)

#### Step 2: Get Android SHA-1 Fingerprint
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Production keystore (when you create one)
keytool -list -v -keystore /path/to/release.keystore
```

#### Step 3: Configure Flutter App

**iOS** (`attendance_app/ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSED_IOS_CLIENT_ID</string>
    </array>
  </dict>
</array>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track attendance</string>
```

**Android** (`attendance_app/android/app/src/main/AndroidManifest.xml`):
```xml
<application>
  <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
</application>

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### Step 4: Update Backend `.env`
```bash
GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

### 2. MongoDB Setup

1. Create cluster at https://www.mongodb.com/cloud/atlas
2. Create database user
3. Whitelist IP addresses (0.0.0.0/0 for development)
4. Get connection string
5. Update backend `.env`:
   ```bash
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/attendance?retryWrites=true&w=majority
   ```

### 3. API Configuration

Update Flutter app (`attendance_app/lib/src/core/constants/app_constants.dart`):
```dart
static const String baseUrl = 'https://your-backend-url.com';
// For local development: 'http://10.0.2.2:3000' (Android emulator)
// For local development: 'http://localhost:3000' (iOS simulator)
```

---

## 🎯 Development Workflow

### 1. Run Backend
```bash
cd backend
npm run dev
```
Backend runs on http://localhost:3000

### 2. Run Flutter App
```bash
cd attendance_app

# iOS
flutter run -d ios

# Android
flutter run -d android

# Both
flutter run
```

### 3. Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart

---

## 📱 Features Checklist

### ✅ Implemented

#### Core Architecture
- [x] Clean architecture (Data/Domain/Presentation layers)
- [x] Offline-first with Hive local database
- [x] Riverpod state management
- [x] Repository pattern
- [x] Use case pattern

#### Authentication
- [x] Google OAuth integration
- [x] JWT token storage (secure)
- [x] Auto-login on app launch
- [x] Backend token verification

#### Synchronization Engine
- [x] Network connectivity monitoring
- [x] Automatic sync on network restore
- [x] Periodic sync (5-minute interval)
- [x] Batch upload to server
- [x] Last-Write-Wins conflict resolution
- [x] Retry logic (3 attempts)
- [x] Sync status indicators

#### Location Services
- [x] GPS position capture
- [x] Location permissions handling
- [x] Geofence validation
- [x] Distance calculation (Haversine formula)
- [x] Accuracy validation

#### UI Components
- [x] Login page with Google Sign-In
- [x] Home page with clock in/out
- [x] Sync status banner
- [x] Optimistic UI updates
- [x] Error handling

#### Backend API
- [x] Express server with MongoDB
- [x] Google token verification
- [x] JWT authentication middleware
- [x] Batch sync endpoint
- [x] Attendance history endpoint
- [x] Rate limiting
- [x] Security headers (Helmet)
- [x] CORS configuration

### 🚧 To Implement (Next Steps)

#### Frontend
- [ ] Attendance history page with calendar view
- [ ] Google Maps integration for location display
- [ ] Dashboard with statistics (hours worked, weekly summary)
- [ ] Leave request submission form
- [ ] User profile page
- [ ] Settings page (geofence radius, notifications)
- [ ] Dark mode support
- [ ] Localization (multiple languages)

#### Features
- [ ] Clock-out reminder notifications (scheduled)
- [ ] Offline map caching
- [ ] Export attendance reports (PDF/CSV)
- [ ] Face recognition for additional verification
- [ ] Team attendance view (for managers)
- [ ] Shift scheduling

#### Backend
- [ ] Geofence CRUD operations
- [ ] Leave request approval workflow
- [ ] Admin dashboard API
- [ ] Analytics and reporting
- [ ] Email notifications
- [ ] Webhook support for integrations

#### Testing
- [ ] Unit tests (Flutter)
- [ ] Widget tests
- [ ] Integration tests
- [ ] API tests (Jest)
- [ ] E2E tests

---

## 🧪 Testing

### Flutter Tests
```bash
cd attendance_app

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Backend Tests
```bash
cd backend

# Run tests
npm test

# Run with coverage
npm test -- --coverage
```

---

## 📦 Deployment

### Flutter App

#### Android (Google Play Store)

1. **Create signing key**:
   ```bash
   keytool -genkey -v -keystore ~/attendance-release-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias attendance
   ```

2. **Configure signing** (`android/key.properties`):
   ```properties
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=attendance
   storeFile=/path/to/attendance-release-key.jks
   ```

3. **Build release**:
   ```bash
   flutter build appbundle --release
   ```

4. **Upload** to Google Play Console

#### iOS (App Store)

1. **Configure in Xcode**:
   - Open `ios/Runner.xcworkspace`
   - Set up signing & capabilities
   - Configure provisioning profiles

2. **Build**:
   ```bash
   flutter build ios --release
   ```

3. **Archive and submit** via Xcode

### Backend Deployment

#### Option 1: Heroku
```bash
heroku create attendance-backend
heroku config:set MONGODB_URI=xxx
heroku config:set JWT_SECRET=xxx
heroku config:set GOOGLE_CLIENT_ID=xxx
git push heroku main
```

#### Option 2: Railway
1. Connect GitHub repository
2. Set environment variables
3. Deploy automatically on push

#### Option 3: AWS EC2
1. Launch EC2 instance
2. Install Node.js
3. Clone repository
4. Set up PM2 for process management
5. Configure Nginx as reverse proxy

---

## 🔐 Security Considerations

### Production Checklist

- [ ] Change all default secrets in `.env`
- [ ] Use strong JWT secret (min 32 characters)
- [ ] Enable HTTPS on backend
- [ ] Restrict CORS to specific origins
- [ ] Implement refresh token rotation
- [ ] Add request logging and monitoring
- [ ] Set up error tracking (Sentry)
- [ ] Implement backup strategy for MongoDB
- [ ] Regular security audits
- [ ] Keep dependencies updated

---

## 📊 Performance Optimization

### Flutter App
- Use `const` constructors where possible
- Implement pagination for long lists
- Cache images and assets
- Use `ListView.builder()` for dynamic lists
- Profile with Flutter DevTools

### Backend
- Add database indexes (already done for common queries)
- Implement caching (Redis)
- Use connection pooling
- Compress responses (gzip)
- Monitor with APM tools

---

## 🐛 Troubleshooting

### Flutter Issues

**Issue**: Google Sign-In not working
```bash
# Solution: Check OAuth configuration
flutter clean
flutter pub get
# Verify SHA-1 fingerprint in Google Cloud Console
```

**Issue**: Location permissions denied
```bash
# Solution: Check Info.plist and AndroidManifest.xml
# Uninstall and reinstall app to trigger permission prompt
```

**Issue**: Build fails with freezed errors
```bash
# Solution: Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Backend Issues

**Issue**: MongoDB connection failed
```bash
# Solution: Check connection string and IP whitelist
# Verify MongoDB Atlas cluster is running
```

**Issue**: JWT verification fails
```bash
# Solution: Check JWT_SECRET matches between client and server
# Verify token hasn't expired
```

---

## 📚 Resources

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Guide](https://riverpod.dev/)
- [Hive Database](https://docs.hivedb.dev/)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Manual](https://docs.mongodb.com/)

### Tutorials
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Offline-First Apps](https://www.raywenderlich.com/books/flutter-apprentice/v1.0.ea1/chapters/16-offline-first-apps)

---

## 🤝 Support

For issues or questions:
1. Check the README files in each directory
2. Review the troubleshooting section
3. Search GitHub issues
4. Create a new issue with details

---

## 📄 License

MIT License - Feel free to use for personal or commercial projects

---

**Built with ❤️ using Flutter, Node.js, and MongoDB**

Last Updated: December 7, 2025
