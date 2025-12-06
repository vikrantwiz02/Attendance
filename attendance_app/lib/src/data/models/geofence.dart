import 'package:freezed_annotation/freezed_annotation.dart';

part 'geofence.freezed.dart';
part 'geofence.g.dart';

/// Represents a geofence zone (e.g., office location)
@freezed
class Geofence with _$Geofence {
  const factory Geofence({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    /// Radius in meters
    required double radiusMeters,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Geofence;

  factory Geofence.fromJson(Map<String, dynamic> json) =>
      _$GeofenceFromJson(json);
}
