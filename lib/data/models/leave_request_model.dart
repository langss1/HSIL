import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leave_request.dart';

class LeaveRequestModel extends LeaveRequest {
  const LeaveRequestModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.startDate,
    required super.endDate,
    required super.type,
    required super.reason,
    required super.status,
    super.attachmentUrl,
    super.reviewedBy,
    super.reviewerName,
    super.reviewNote,
    super.createdAt,
    super.updatedAt,
  });

  factory LeaveRequestModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return LeaveRequestModel.fromJson({...data, 'id': doc.id});
  }

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      type: _typeFromString(json['type'] as String?),
      reason: json['reason'] as String? ?? '',
      status: _statusFromString(json['status'] as String?),
      attachmentUrl: json['attachmentUrl'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      reviewerName: json['reviewerName'] as String?,
      reviewNote: json['reviewNote'] as String?,
      createdAt: _dateFromJson(json['createdAt']),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'startDate': startDate,
      'endDate': endDate,
      'type': type.name,
      'reason': reason,
      'status': status.name,
      'attachmentUrl': attachmentUrl,
      'reviewedBy': reviewedBy,
      'reviewerName': reviewerName,
      'reviewNote': reviewNote,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static LeaveType _typeFromString(String? value) {
    switch (value) {
      case 'cuti':
        return LeaveType.cuti;
      case 'keperluanPribadi':
        return LeaveType.keperluanPribadi;
      case 'sakit':
      default:
        return LeaveType.sakit;
    }
  }

  static LeaveStatus _statusFromString(String? value) {
    switch (value) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      case 'pending':
      default:
        return LeaveStatus.pending;
    }
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }
}
