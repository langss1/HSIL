import '../../core/utils/app_result.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class GetMyLeavesUseCase {
  const GetMyLeavesUseCase(this._repository);

  final LeaveRepository _repository;

  Future<AppResult<List<LeaveRequest>>> call(String employeeId) {
    return _repository.getMyLeaveRequests(employeeId);
  }
}
