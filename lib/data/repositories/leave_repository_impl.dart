import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/repositories/leave_repository.dart';
import '../datasources/firestore_attendance_data_source.dart';
import '../datasources/firestore_leave_data_source.dart';
import '../models/attendance_model.dart';
import '../models/leave_request_model.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  LeaveRepositoryImpl({
    required FirestoreLeaveDataSource leaveDataSource,
    required FirestoreAttendanceDataSource attendanceDataSource,
  })  : _leaveDataSource = leaveDataSource,
        _attendanceDataSource = attendanceDataSource;

  final FirestoreLeaveDataSource _leaveDataSource;
  final FirestoreAttendanceDataSource _attendanceDataSource;
  final _uuid = const Uuid();

  @override
  Future<AppResult<LeaveRequest>> submitLeaveRequest({
    required String employeeId,
    required String employeeName,
    required String startDate,
    required String endDate,
    required LeaveType type,
    required String reason,
    String? attachmentUrl,
  }) async {
    try {
      final model = LeaveRequestModel(
        id: _uuid.v4(),
        employeeId: employeeId,
        employeeName: employeeName,
        startDate: startDate,
        endDate: endDate,
        type: type,
        reason: reason,
        status: LeaveStatus.pending,
        attachmentUrl: attachmentUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _leaveDataSource.submitLeave(model);
      return AppSuccess(model);
    } catch (e) {
      return AppFailure(_mapFailure(e));
    }
  }

  @override
  Future<AppResult<List<LeaveRequest>>> getAllLeaveRequests() async {
    try {
      final leaves = await _leaveDataSource.getAll();
      return AppSuccess(leaves);
    } catch (e) {
      return AppFailure(_mapFailure(e));
    }
  }

  @override
  Future<AppResult<List<LeaveRequest>>> getMyLeaveRequests(String employeeId) async {
    try {
      final leaves = await _leaveDataSource.getByEmployee(employeeId);
      return AppSuccess(leaves);
    } catch (e) {
      return AppFailure(_mapFailure(e));
    }
  }

  @override
  Future<AppResult<List<LeaveRequest>>> getPendingLeaveRequests() async {
    try {
      final leaves = await _leaveDataSource.getPending();
      return AppSuccess(leaves);
    } catch (e) {
      return AppFailure(_mapFailure(e));
    }
  }

  @override
  Future<AppResult<LeaveRequest>> approveLeaveRequest({
    required String requestId,
    required String adminId,
    required String adminName,
    String? note,
  }) async {
    try {
      final updated = await _leaveDataSource.updateStatus(requestId, {
        'status': LeaveStatus.approved.name,
        'reviewedBy': adminId,
        'reviewerName': adminName,
        'reviewNote': note,
      });

      final attendanceStatus = (updated.type == LeaveType.sakit) ? 'sakit' : 'izin';
      
      final start = DateTime.parse(updated.startDate);
      final end = DateTime.parse(updated.endDate);
      final diff = end.difference(start).inDays;

      for (int i = 0; i <= diff; i++) {
        final currentDate = start.add(Duration(days: i));
        // Skip Saturday (6) and Sunday (7)
        if (currentDate.weekday == DateTime.saturday || currentDate.weekday == DateTime.sunday) {
          continue;
        }

        final dateString = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
        
        final attendanceModel = AttendanceModel.forLeave(
          employeeId: updated.employeeId,
          employeeName: updated.employeeName,
          date: dateString,
          status: attendanceStatus,
        );
        
        await _attendanceDataSource.saveLeaveAttendance(attendanceModel);
      }

      return AppSuccess(updated);
    } catch (e) {
      return AppFailure(_mapFailure(e));
    }
  }

  @override
  Future<AppResult<LeaveRequest>> rejectLeaveRequest({
    required String requestId,
    required String adminId,
    required String adminName,
    String? note,
  }) async {
    try {
      final updated = await _leaveDataSource.updateStatus(requestId, {
        'status': LeaveStatus.rejected.name,
        'reviewedBy': adminId,
        'reviewerName': adminName,
        'reviewNote': note,
      });
      return AppSuccess(updated);
    } catch (e) {
      return AppFailure(_mapFailure(e));
    }
  }

  Failure _mapFailure(Object error) {
    if (error is FirebaseDataException) {
      return DataFailure(error.message, code: error.code);
    }
    return UnknownFailure('Terjadi kesalahan pengajuan izin: $error');
  }
}
