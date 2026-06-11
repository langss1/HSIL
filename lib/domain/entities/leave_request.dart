enum LeaveType {
  sakit,
  cuti,
  keperluanPribadi
}

enum LeaveStatus {
  pending,
  approved,
  rejected
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    required this.status,
    this.attachmentUrl,
    this.reviewedBy,
    this.reviewerName,
    this.reviewNote,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String startDate;
  final String endDate;
  final LeaveType type;
  final String reason;
  final String? attachmentUrl;
  final LeaveStatus status;
  final String? reviewedBy;
  final String? reviewerName;
  final String? reviewNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
