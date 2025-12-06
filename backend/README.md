# Attendance App Backend

Node.js/Express backend with MongoDB for the Flutter Attendance App.

## Features

- ✅ Google OAuth verification
- ✅ JWT authentication
- ✅ Batch attendance log sync with Last-Write-Wins conflict resolution
- ✅ Geofence management
- ✅ Leave request handling
- ✅ Security best practices (Helmet, CORS, Rate limiting)

## Setup

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Required environment variables**:
   - `MONGODB_URI`: MongoDB connection string
   - `JWT_SECRET`: Secret key for JWT tokens
   - `GOOGLE_CLIENT_ID`: Google OAuth client ID
   - `PORT`: Server port (default: 3000)

4. **Start the server**:
   ```bash
   # Development (with auto-reload)
   npm run dev

   # Production
   npm start
   ```

## API Endpoints

### Authentication
- `POST /api/auth/google-verify` - Verify Google token and get JWT

### Attendance
- `POST /api/sync-logs` - Batch sync attendance logs
- `GET /api/attendance-logs?from=DATE&to=DATE` - Get attendance history

### User
- `GET /api/users/profile` - Get user profile

### Geofencing
- `GET /api/geofences` - Get geofence definitions

### Leave Management
- `POST /api/leave-requests` - Submit leave request
- `GET /api/leave-requests` - Get leave requests

### Health Check
- `GET /health` - Server health status

## Database Schema

### User
```javascript
{
  email: String,
  displayName: String,
  photoUrl: String,
  googleId: String (unique),
  isActive: Boolean,
  createdAt: Date,
  lastSyncAt: Date
}
```

### AttendanceLog
```javascript
{
  userId: ObjectId,
  clientId: String (unique),
  actionType: 'clockIn' | 'clockOut' | 'break',
  clientTimestamp: Date,
  serverTimestamp: Date,
  latitude: Number,
  longitude: Number,
  accuracy: Number,
  withinGeofence: Boolean,
  distanceFromGeofence: Number,
  notes: String,
  deviceId: String,
  networkType: String
}
```

## Security Features

- Helmet.js for security headers
- CORS configuration
- Rate limiting (100 requests per 15 minutes)
- JWT token authentication
- Input validation
- Environment-based error handling

## Deployment

### Deploy to Heroku
```bash
heroku create attendance-backend
heroku config:set MONGODB_URI=your-mongodb-uri
heroku config:set JWT_SECRET=your-jwt-secret
heroku config:set GOOGLE_CLIENT_ID=your-google-client-id
git push heroku main
```

### Deploy to Railway/Render
1. Connect your GitHub repository
2. Set environment variables
3. Deploy

## License

MIT
