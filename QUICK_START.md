# 🚀 Quick Start Guide - Flutter Attendance App

## ⚡ Get Running in 5 Minutes

### Step 1: Install Flutter (if not already installed)

**macOS:**
```bash
brew install flutter
flutter doctor
```

**Note:** Flutter is not currently installed on your system. Install it first before proceeding.

### Step 2: Backend Setup

```bash
cd /Users/vikrant/Documents/Attendance/backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env file with your credentials:
# - MONGODB_URI (get from MongoDB Atlas)
# - JWT_SECRET (any random secure string)
# - GOOGLE_CLIENT_ID (get from Google Cloud Console)

# Start the server
npm run dev
```

Backend will run at: **http://localhost:3000**

### Step 3: Flutter App Setup

```bash
cd /Users/vikrant/Documents/Attendance/attendance_app

# Option 1: Use setup script
chmod +x setup.sh
./setup.sh

# Option 2: Manual setup
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Update Configuration

1. **Update API URL** in `lib/src/core/constants/app_constants.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:3000';
   // For Android emulator: 'http://10.0.2.2:3000'
   // For iOS simulator: 'http://localhost:3000'
   ```

### Step 5: Run the App

```bash
# Connect a device or start an emulator/simulator

# Run the app
flutter run
```

---

## 🔑 Quick Google OAuth Setup (Optional for Testing)

For full OAuth functionality, you'll need to configure Google Sign-In:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable "Google Sign-In API"
4. Create OAuth credentials (Android + iOS + Web)
5. Update configuration files as described in PROJECT_OVERVIEW.md

**For testing without OAuth:** You can temporarily modify the login flow to skip Google authentication.

---

## 📁 Project Structure at a Glance

```
Attendance/
├── attendance_app/          ← Flutter mobile app
│   ├── lib/
│   │   ├── main.dart       ← Start here
│   │   └── src/
│   └── pubspec.yaml
│
├── backend/                 ← Node.js API
│   ├── server.js           ← Express server
│   ├── routes/             ← API endpoints
│   └── models/             ← MongoDB schemas
│
└── PROJECT_OVERVIEW.md      ← Full documentation
```

---

## 🎯 Key Features Ready to Use

✅ **Offline-First Architecture**
- Works without internet
- Auto-syncs when online

✅ **Clean Architecture**
- Data/Domain/Presentation layers
- Easy to maintain and test

✅ **Location Services**
- GPS tracking
- Geofencing validation

✅ **Sync Engine**
- Background synchronization
- Conflict resolution (Last-Write-Wins)

✅ **Authentication**
- Google OAuth (when configured)
- JWT tokens

---

## 🐛 Common First-Run Issues

### Issue: Flutter command not found
**Solution:** Install Flutter SDK (see Step 1)

### Issue: Build fails
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Android/iOS build errors
**Solution:** Run Flutter doctor to check setup
```bash
flutter doctor -v
```

### Issue: Backend won't start
**Solution:** Ensure Node.js is installed and .env is configured
```bash
node --version  # Should show v18+
npm install
```

---

## 📚 Next Steps

1. **Read PROJECT_OVERVIEW.md** for comprehensive setup
2. **Configure Google OAuth** for full authentication
3. **Set up MongoDB Atlas** for cloud database
4. **Customize geofence location** in constants
5. **Add your own features** from the todo list!

---

## 🆘 Need Help?

- Check `PROJECT_OVERVIEW.md` for detailed documentation
- Review `README.md` in each directory
- Ensure all prerequisites are installed

---

**Happy Coding! 🎉**

Built with Flutter, Node.js, Express, and MongoDB
