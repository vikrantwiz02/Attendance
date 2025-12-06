const mongoose = require('mongoose');

const attendanceLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  clientId: {
    type: String,
    required: true,
    unique: true, // Ensures no duplicate client IDs
  },
  actionType: {
    type: String,
    enum: ['clockIn', 'clockOut', 'break'],
    required: true,
  },
  clientTimestamp: {
    type: Date,
    required: true,
  },
  serverTimestamp: {
    type: Date,
    default: Date.now,
  },
  latitude: {
    type: Number,
    required: true,
  },
  longitude: {
    type: Number,
    required: true,
  },
  accuracy: {
    type: Number,
    required: true,
  },
  withinGeofence: {
    type: Boolean,
    required: true,
  },
  distanceFromGeofence: Number,
  notes: String,
  deviceId: String,
  networkType: String,
});

// Index for efficient queries
attendanceLogSchema.index({ userId: 1, clientTimestamp: -1 });
attendanceLogSchema.index({ clientId: 1 });

module.exports = mongoose.model('AttendanceLog', attendanceLogSchema);
