import '../../core/utils/app_result.dart';
import '../../core/errors/failures.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class SubmitLeaveUseCase {
  const SubmitLeaveUseCase(this._repository);

  final LeaveRepository _repository;

  Future<AppResult<LeaveRequest>> call({
    required String employeeId,
    required String employeeName,
    required String startDate,
    required String endDate,
    required LeaveType type,
    required String reason,
    String? attachmentUrl,
  }) async {
    if (reason.trim().length < 10) {
      return const AppFailure(DataFailure('Alasan izin minimal 10 karakter.'));
    }

    return _repository.submitLeaveRequest(
      employeeId: employeeId,
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      type: type,
      reason: reason.trim(),
      attachmentUrl: attachmentUrl,
    );
  }
}
