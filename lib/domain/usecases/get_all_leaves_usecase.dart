import '../../core/utils/app_result.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class GetAllLeavesUseCase {
  const GetAllLeavesUseCase(this._repository);

  final LeaveRepository _repository;

  Future<AppResult<List<LeaveRequest>>> call() {
    return _repository.getAllLeaveRequests();
  }
}
