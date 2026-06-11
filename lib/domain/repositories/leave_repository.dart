import '../../core/utils/app_result.dart';
import '../entities/leave_request.dart';

abstract interface class LeaveRepository {
  Future<AppResult<LeaveRequest>> submitLeaveRequest({
    required String employeeId,
    required String employeeName,
    required String startDate,
    required String endDate,
    required LeaveType type,
    required String reason,
    String? attachmentUrl,
  });

  Future<AppResult<List<LeaveRequest>>> getAllLeaveRequests();

  Future<AppResult<List<LeaveRequest>>> getMyLeaveRequests(String employeeId);

  Future<AppResult<List<LeaveRequest>>> getPendingLeaveRequests();

  Future<AppResult<LeaveRequest>> approveLeaveRequest({
    required String requestId,
    required String adminId,
    required String adminName,
    String? note,
  });

  Future<AppResult<LeaveRequest>> rejectLeaveRequest({
    required String requestId,
    required String adminId,
    required String adminName,
    String? note,
  });
}
