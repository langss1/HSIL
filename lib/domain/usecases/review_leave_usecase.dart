import '../../core/utils/app_result.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class ReviewLeaveUseCase {
  const ReviewLeaveUseCase(this._repository);

  final LeaveRepository _repository;

  Future<AppResult<LeaveRequest>> call({
    required String requestId,
    required String adminId,
    required String adminName,
    required bool approved,
    String? note,
  }) {
    if (approved) {
      return _repository.approveLeaveRequest(
        requestId: requestId,
        adminId: adminId,
        adminName: adminName,
        note: note,
      );
    } else {
      return _repository.rejectLeaveRequest(
        requestId: requestId,
        adminId: adminId,
        adminName: adminName,
        note: note,
      );
    }
  }
}
