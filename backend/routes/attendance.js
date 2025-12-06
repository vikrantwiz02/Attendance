const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const AttendanceLog = require('../models/AttendanceLog');

/**
 * POST /api/sync-logs
 * Batch sync attendance logs with Last-Write-Wins conflict resolution
 */
router.post('/sync-logs', authMiddleware, async (req, res) => {
  try {
    const { logs, clientTimestamp } = req.body;
    const userId = req.userId;

    if (!logs || !Array.isArray(logs)) {
      return res.status(400).json({
        success: false,
        message: 'Logs array is required',
      });
    }

    const syncedRecords = [];
    const failedRecordIds = [];

    // Process each log
    for (const log of logs) {
      try {
        // Check if record already exists (by clientId)
        const existing = await AttendanceLog.findOne({ clientId: log.clientId });

        if (existing) {
          // Apply Last-Write-Wins strategy
          const clientTime = new Date(log.clientTimestamp);
          const existingTime = new Date(existing.clientTimestamp);

          if (clientTime > existingTime) {
            // Update with newer data
            Object.assign(existing, {
              ...log,
              userId,
              serverTimestamp: new Date(),
            });
            await existing.save();

            syncedRecords.push({
              clientId: log.clientId,
              serverId: existing._id,
              serverTimestamp: existing.serverTimestamp,
            });
          } else {
            // Keep existing record (it's newer)
            syncedRecords.push({
              clientId: log.clientId,
              serverId: existing._id,
              serverTimestamp: existing.serverTimestamp,
            });
          }
        } else {
          // Create new record
          const newLog = new AttendanceLog({
            ...log,
            userId,
            serverTimestamp: new Date(),
          });
          await newLog.save();

          syncedRecords.push({
            clientId: log.clientId,
            serverId: newLog._id,
            serverTimestamp: newLog.serverTimestamp,
          });
        }
      } catch (error) {
        console.error(`Failed to sync log ${log.clientId}:`, error);
        failedRecordIds.push(log.clientId);
      }
    }

    res.json({
      success: true,
      syncedRecords,
      failedRecordIds,
      serverTimestamp: new Date(),
      message: `Synced ${syncedRecords.length}/${logs.length} records`,
    });
  } catch (error) {
    console.error('Sync error:', error);
    res.status(500).json({
      success: false,
      message: 'Sync failed',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * GET /api/attendance-logs
 * Get attendance logs for a date range
 */
router.get('/attendance-logs', authMiddleware, async (req, res) => {
  try {
    const { from, to } = req.query;
    const userId = req.userId;

    const query = { userId };

    if (from || to) {
      query.clientTimestamp = {};
      if (from) query.clientTimestamp.$gte = new Date(from);
      if (to) query.clientTimestamp.$lte = new Date(to);
    }

    const logs = await AttendanceLog.find(query)
      .sort({ clientTimestamp: -1 })
      .limit(1000); // Limit to prevent excessive data transfer

    res.json({
      success: true,
      logs,
      count: logs.length,
    });
  } catch (error) {
    console.error('Get logs error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch logs',
    });
  }
});

/**
 * GET /api/users/profile
 * Get current user profile
 */
router.get('/users/profile', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-__v');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      ...user.toObject(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch profile',
    });
  }
});

module.exports = router;
