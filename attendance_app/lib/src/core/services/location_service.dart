import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

/// Service for GPS location and geofencing operations
class LocationService {
  final Logger logger;

  LocationService({required this.logger});

  /// Initialize location service and request permissions
  Future<bool> init() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.w('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.w('Location permissions are permanently denied');
      return false;
    }

    logger.i('Location permissions granted');
    return true;
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      logger.i(
        'Current position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      logger.e('Failed to get current position: $e');
      rethrow;
    }
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        logger.i(
          'Last known position: ${position.latitude}, ${position.longitude}',
        );
      }
      return position;
    } catch (e) {
      logger.e('Failed to get last known position: $e');
      return null;
    }
  }

  /// Check if a position is within a geofence
  /// Uses Haversine formula to calculate distance between two coordinates
  bool isWithinGeofence({
    required double userLatitude,
    required double userLongitude,
    required double geofenceLatitude,
    required double geofenceLongitude,
    required double radiusMeters,
  }) {
    final distance = _calculateDistance(
      userLatitude,
      userLongitude,
      geofenceLatitude,
      geofenceLongitude,
    );

    final isWithin = distance <= radiusMeters;
    logger.d(
      'Geofence check: distance=${distance.toStringAsFixed(2)}m, '
      'radius=${radiusMeters.toStringAsFixed(2)}m, within=$isWithin',
    );

    return isWithin;
  }

  /// Get distance from geofence center
  double getDistanceFromGeofence({
    required double userLatitude,
    required double userLongitude,
    required double geofenceLatitude,
    required double geofenceLongitude,
  }) {
    return _calculateDistance(
      userLatitude,
      userLongitude,
      geofenceLatitude,
      geofenceLongitude,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; // Earth's radius in meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final c = 2 * math.asin(math.sqrt(a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);
}

// For math operations
import 'dart:math' as math;
