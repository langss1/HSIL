/// Represents a single attendance record for an employee.
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.clockInLat,
    this.clockInLng,
    this.clockOutLat,
    this.clockOutLng,
    this.clockInDistance,
    this.clockOutDistance,
    required this.status,
    required this.gpsStatus,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique record identifier.
  final String id;

  /// Firebase Auth UID of the employee.
  final String employeeId;

  /// Display name of the employee.
  final String employeeName;

  /// Date key in 'yyyy-MM-dd' format.
  final String date;

  /// Clock-in timestamp.
  final DateTime? clockIn;

  /// Clock-out timestamp.
  final DateTime? clockOut;

  /// GPS coordinates at clock-in.
  final double? clockInLat;
  final double? clockInLng;

  /// GPS coordinates at clock-out.
  final double? clockOutLat;
  final double? clockOutLng;

  /// Distance from office at clock-in (meters).
  final double? clockInDistance;

  /// Distance from office at clock-out (meters).
  final double? clockOutDistance;

  /// Attendance status: 'hadir', 'telat', 'izin', 'alpha'.
  final String status;

  /// GPS validation status: 'IN_AREA' or 'OUTSIDE_AREA'.
  final String gpsStatus;

  /// Record creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  /// Whether the employee has clocked in today.
  bool get hasClockedIn => clockIn != null;

  /// Whether the employee has clocked out today.
  bool get hasClockedOut => clockOut != null;

  /// Whether this is a complete attendance cycle.
  bool get isComplete => hasClockedIn && hasClockedOut;
}
