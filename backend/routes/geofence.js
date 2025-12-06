const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');

/**
 * GET /api/geofences
 * Get all geofence definitions
 */
router.get('/geofences', authMiddleware, async (req, res) => {
  try {
    // In a real implementation, you would fetch from database
    // For now, returning a hardcoded office location
    const geofences = [
      {
        id: '1',
        name: 'Main Office',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 100,
        createdAt: new Date('2025-01-01'),
        updatedAt: new Date(),
      },
    ];

    res.json({
      success: true,
      geofences,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch geofences',
    });
  }
});

module.exports = router;
