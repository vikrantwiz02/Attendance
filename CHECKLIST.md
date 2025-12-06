# ✅ Setup & Deployment Checklist

## 🎯 Initial Setup Checklist

### Prerequisites Installation
- [ ] **Install Flutter SDK** (3.0.0+)
  ```bash
  brew install flutter
  flutter doctor
  ```
- [ ] **Install Node.js** (18.0.0+)
  ```bash
  brew install node
  node --version
  ```
- [ ] **Install Git** (for version control)
  ```bash
  git --version
  ```
- [ ] **Install VS Code** or Android Studio (recommended)
- [ ] **Install Xcode** (for iOS development, macOS only)
- [ ] **Install Android Studio** (for Android development)

### Flutter Environment Setup
- [ ] Accept Android licenses
  ```bash
  flutter doctor --android-licenses
  ```
- [ ] Verify Flutter installation
  ```bash
  flutter doctor -v
  ```
- [ ] Fix any issues shown by `flutter doctor`

---

## 📱 Flutter App Setup

### Dependencies & Code Generation
- [ ] Navigate to project directory
  ```bash
  cd /Users/vikrant/Documents/Attendance/attendance_app
  ```
- [ ] Install dependencies
  ```bash
  flutter pub get
  ```
- [ ] Run code generation
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- [ ] Verify no errors in terminal

### Project Configuration
- [ ] Update API base URL in `lib/src/core/constants/app_constants.dart`
  - For local development (Android): `http://10.0.2.2:3000`
  - For local development (iOS): `http://localhost:3000`
  - For production: `https://your-api-domain.com`

---

## 🔧 Backend Setup

### Environment Configuration
- [ ] Navigate to backend directory
  ```bash
  cd /Users/vikrant/Documents/Attendance/backend
  ```
- [ ] Install dependencies
  ```bash
  npm install
  ```
- [ ] Copy environment template
  ```bash
  cp .env.example .env
  ```
- [ ] Edit `.env` file with your credentials

### MongoDB Atlas Setup
- [ ] Create MongoDB Atlas account at https://www.mongodb.com/cloud/atlas
- [ ] Create a new cluster (Free M0 tier available)
- [ ] Create database user with username/password
- [ ] Whitelist IP addresses (0.0.0.0/0 for development)
- [ ] Get connection string
- [ ] Update `MONGODB_URI` in `.env`

### JWT Configuration
- [ ] Generate secure JWT secret (32+ characters)
  ```bash
  openssl rand -base64 32
  ```
- [ ] Update `JWT_SECRET` in `.env`

---

## 🔐 Google OAuth Setup

### Google Cloud Console
- [ ] Go to https://console.cloud.google.com/
- [ ] Create new project "Attendance App"
- [ ] Enable **Google Sign-In API**

### Android OAuth Setup
- [ ] Get Android SHA-1 fingerprint
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore \
    -alias androiddebugkey -storepass android -keypass android
  ```
- [ ] Create Android OAuth 2.0 Client ID in Google Cloud Console
- [ ] Copy Client ID
- [ ] Update `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <meta-data
      android:name="com.google.android.gms.auth.api.signin.client_id"
      android:value="YOUR_ANDROID_CLIENT_ID" />
  ```

### iOS OAuth Setup
- [ ] Create iOS OAuth 2.0 Client ID in Google Cloud Console
- [ ] Copy iOS Client ID
- [ ] Update `ios/Runner/Info.plist`:
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
  ```

### Web OAuth Setup (for Backend)
- [ ] Create Web OAuth 2.0 Client ID
- [ ] Copy Web Client ID
- [ ] Update `GOOGLE_CLIENT_ID` in backend `.env`

---

## 📍 Location Permissions

### Android Configuration
- [ ] Verify permissions in `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```

### iOS Configuration
- [ ] Update `ios/Runner/Info.plist`:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>We need your location to track attendance</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>We need your location to track attendance</string>
  ```

---

## 🧪 Testing Local Setup

### Start Backend Server
- [ ] Start backend in development mode
  ```bash
  cd backend
  npm run dev
  ```
- [ ] Verify server is running at http://localhost:3000
- [ ] Test health endpoint: http://localhost:3000/health

### Run Flutter App
- [ ] Connect Android device or start Android emulator
- [ ] OR start iOS simulator
- [ ] Run app
  ```bash
  cd attendance_app
  flutter run
  ```
- [ ] App should build and launch successfully

### Manual Testing
- [ ] Google Sign-In works
- [ ] Can see login screen
- [ ] Click "Sign in with Google"
- [ ] Google OAuth flow completes
- [ ] Redirected to home page
- [ ] Can see clock in/out button
- [ ] Location permission requested
- [ ] Clock in action works
- [ ] Data saved locally (check with debug tools)
- [ ] Sync status banner appears
- [ ] Clock out action works

---

## 🚀 Production Deployment

### Backend Deployment (Choose One)

#### Option A: Heroku
- [ ] Install Heroku CLI
  ```bash
  brew tap heroku/brew && brew install heroku
  ```
- [ ] Login to Heroku
  ```bash
  heroku login
  ```
- [ ] Create Heroku app
  ```bash
  cd backend
  heroku create attendance-backend
  ```
- [ ] Set environment variables
  ```bash
  heroku config:set MONGODB_URI=your-mongodb-uri
  heroku config:set JWT_SECRET=your-jwt-secret
  heroku config:set GOOGLE_CLIENT_ID=your-google-client-id
  ```
- [ ] Deploy
  ```bash
  git push heroku main
  ```
- [ ] Verify deployment
  ```bash
  heroku open
  ```

#### Option B: Railway
- [ ] Sign up at https://railway.app/
- [ ] Connect GitHub repository
- [ ] Add environment variables in Railway dashboard
- [ ] Deploy automatically on push

#### Option C: AWS/GCP/Azure
- [ ] Set up EC2/Compute Engine/VM instance
- [ ] Install Node.js
- [ ] Clone repository
- [ ] Install PM2 for process management
- [ ] Configure Nginx as reverse proxy
- [ ] Set up SSL certificate

### Flutter App Deployment

#### Android (Google Play Store)
- [ ] Create signing key
  ```bash
  keytool -genkey -v -keystore ~/attendance-release-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias attendance
  ```
- [ ] Create `android/key.properties`:
  ```properties
  storePassword=YOUR_PASSWORD
  keyPassword=YOUR_PASSWORD
  keyAlias=attendance
  storeFile=/path/to/attendance-release-key.jks
  ```
- [ ] Update `android/app/build.gradle` with signing config
- [ ] Update app version in `pubspec.yaml`
- [ ] Build release APK/App Bundle
  ```bash
  flutter build appbundle --release
  ```
- [ ] Create Google Play Console account
- [ ] Create app listing
- [ ] Upload app bundle
- [ ] Fill out store listing details
- [ ] Submit for review

#### iOS (App Store)
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Open project in Xcode
  ```bash
  open ios/Runner.xcworkspace
  ```
- [ ] Configure signing & capabilities
- [ ] Set up provisioning profiles
- [ ] Update app version
- [ ] Build archive
  ```bash
  flutter build ios --release
  ```
- [ ] Open Xcode Organizer
- [ ] Upload to App Store Connect
- [ ] Fill out app information
- [ ] Submit for review

---

## 🔒 Security Checklist

### Pre-Production Security
- [ ] Change all default secrets in `.env`
- [ ] Use strong JWT secret (32+ characters)
- [ ] Enable HTTPS on backend (SSL certificate)
- [ ] Restrict CORS to specific origins
- [ ] Implement refresh token rotation
- [ ] Add request logging and monitoring
- [ ] Set up error tracking (Sentry, etc.)
- [ ] Implement backup strategy for MongoDB
- [ ] Regular security audits scheduled
- [ ] Keep all dependencies updated

### Code Security
- [ ] No hardcoded secrets in code
- [ ] API keys in environment variables
- [ ] Sensitive data encrypted
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (MongoDB parameterized queries)
- [ ] XSS protection
- [ ] CSRF protection

---

## 📊 Performance Checklist

### App Performance
- [ ] Profile app with Flutter DevTools
- [ ] Optimize images and assets
- [ ] Implement lazy loading for lists
- [ ] Use `const` constructors where possible
- [ ] Minimize widget rebuilds
- [ ] Test on low-end devices
- [ ] Check battery usage
- [ ] Optimize database queries

### Backend Performance
- [ ] Add database indexes (already done)
- [ ] Implement caching (Redis)
- [ ] Use connection pooling
- [ ] Compress responses (gzip)
- [ ] Monitor with APM tools
- [ ] Load testing
- [ ] Set up auto-scaling

---

## 📈 Analytics & Monitoring

### Setup Analytics
- [ ] Create Firebase project
- [ ] Add Firebase to Flutter app
- [ ] Install Firebase Analytics
- [ ] Set up custom events:
  - Clock in/out events
  - Login events
  - Sync events
  - Error events
- [ ] Configure Firebase Crashlytics
- [ ] Test crash reporting

### Backend Monitoring
- [ ] Set up logging (Winston, etc.)
- [ ] Monitor API response times
- [ ] Track error rates
- [ ] Set up alerts for:
  - Server downtime
  - High error rates
  - Slow response times
  - Database issues

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] Write tests for use cases
- [ ] Test repository implementations
- [ ] Test services (sync, location)
- [ ] Achieve 80%+ code coverage
- [ ] Run tests before each commit
  ```bash
  flutter test
  ```

### Widget Tests
- [ ] Test all major screens
- [ ] Test custom widgets
- [ ] Test user interactions
- [ ] Test error states

### Integration Tests
- [ ] Test complete user flows
- [ ] Test offline scenarios
- [ ] Test sync scenarios
- [ ] Test authentication flow

### Manual Testing
- [ ] Test on multiple devices
- [ ] Test on different Android versions
- [ ] Test on different iOS versions
- [ ] Test with poor network
- [ ] Test airplane mode
- [ ] Test location disabled
- [ ] Test permissions denied

---

## 📚 Documentation Checklist

### Code Documentation
- [ ] All public APIs documented
- [ ] Complex logic explained
- [ ] README files up to date
- [ ] API endpoints documented
- [ ] Environment variables documented

### User Documentation
- [ ] User manual created
- [ ] FAQ section
- [ ] Video tutorials (optional)
- [ ] Privacy policy
- [ ] Terms of service

---

## ✅ Pre-Launch Checklist

### Final Verification
- [ ] All features working as expected
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Security review completed
- [ ] Privacy policy in place
- [ ] Terms of service in place
- [ ] App Store/Play Store listing complete
- [ ] Support email set up
- [ ] Analytics configured
- [ ] Crash reporting active
- [ ] Backup and recovery tested

### Post-Launch
- [ ] Monitor crash reports
- [ ] Monitor user reviews
- [ ] Respond to user feedback
- [ ] Plan first update
- [ ] Track key metrics:
  - Daily active users
  - Retention rate
  - Crash-free rate
  - Average session duration

---

## 🎉 Success Criteria

Your app is ready when:
- ✅ All setup checklists completed
- ✅ Backend deployed and accessible
- ✅ App builds without errors
- ✅ Google OAuth working
- ✅ Offline mode functional
- ✅ Sync working reliably
- ✅ Location tracking accurate
- ✅ No critical bugs
- ✅ Acceptable performance
- ✅ Passed internal testing

---

**Estimated Setup Time:**
- **Initial Setup**: 2-4 hours
- **Testing**: 4-8 hours  
- **Production Deployment**: 1-2 days
- **App Store Approval**: 1-7 days

**Good luck with your launch! 🚀**

*Last Updated: December 7, 2025*
