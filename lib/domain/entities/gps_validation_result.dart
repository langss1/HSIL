/// Result of a GPS location validation against the office geofence.
class GPSValidationResult {
  const GPSValidationResult({
    required this.isInArea,
    required this.distanceMeters,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.timestamp,
    this.accuracy,
  });

  /// Whether the user is within the office geofence radius.
  final bool isInArea;

  /// Distance in meters from the office location.
  final double distanceMeters;

  /// User's current latitude.
  final double latitude;

  /// User's current longitude.
  final double longitude;

  /// Validation status: 'IN_AREA' or 'OUTSIDE_AREA'.
  final String status;

  /// Timestamp when this validation was performed.
  final DateTime timestamp;

  /// GPS accuracy in meters, if available.
  final double? accuracy;

  /// Creates a copy with optional field overrides.
  GPSValidationResult copyWith({
    bool? isInArea,
    double? distanceMeters,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? timestamp,
    double? accuracy,
  }) {
    return GPSValidationResult(
      isInArea: isInArea ?? this.isInArea,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}
