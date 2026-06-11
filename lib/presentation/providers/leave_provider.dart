import 'package:flutter/foundation.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/usecases/submit_leave_usecase.dart';
import '../../domain/usecases/get_my_leaves_usecase.dart';
import '../../domain/usecases/get_pending_leaves_usecase.dart';
import '../../domain/usecases/get_all_leaves_usecase.dart';
import '../../domain/usecases/review_leave_usecase.dart';

class LeaveProvider extends ChangeNotifier {
  LeaveProvider({
    required this.submitLeaveUseCase,
    required this.getMyLeavesUseCase,
    required this.getPendingLeavesUseCase,
    required this.getAllLeavesUseCase,
    required this.reviewLeaveUseCase,
  });

  final SubmitLeaveUseCase submitLeaveUseCase;
  final GetMyLeavesUseCase getMyLeavesUseCase;
  final GetPendingLeavesUseCase getPendingLeavesUseCase;
  final GetAllLeavesUseCase getAllLeavesUseCase;
  final ReviewLeaveUseCase reviewLeaveUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<LeaveRequest> _myLeaves = [];
  List<LeaveRequest> get myLeaves => _myLeaves;

  List<LeaveRequest> _pendingLeaves = [];
  List<LeaveRequest> get pendingLeaves => _pendingLeaves;

  List<LeaveRequest> _allLeaves = [];
  List<LeaveRequest> get allLeaves => _allLeaves;

  List<LeaveRequest> get approvedLeaves => _allLeaves.where((l) => l.status == LeaveStatus.approved).toList();
  List<LeaveRequest> get rejectedLeaves => _allLeaves.where((l) => l.status == LeaveStatus.rejected).toList();

  Future<bool> submitLeave({
    required String employeeId,
    required String employeeName,
    required String startDate,
    required String endDate,
    required LeaveType type,
    required String reason,
    String? attachmentUrl,
  }) async {
    _setLoading(true);
    _clearMessages();

    final result = await submitLeaveUseCase(
      employeeId: employeeId,
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      type: type,
      reason: reason,
      attachmentUrl: attachmentUrl,
    );

    bool success = false;
    result.when(
      success: (leave) {
        _successMessage = 'Pengajuan izin berhasil dikirim.';
        _myLeaves.insert(0, leave);
        success = true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        success = false;
      },
    );

    _setLoading(false);
    return success;
  }

  Future<void> fetchMyLeaves(String employeeId) async {
    _setLoading(true);
    _clearMessages();

    final result = await getMyLeavesUseCase(employeeId);
    result.when(
      success: (leaves) => _myLeaves = leaves,
      failure: (failure) => _errorMessage = failure.message,
    );

    _setLoading(false);
  }

  Future<void> fetchPendingLeaves() async {
    _setLoading(true);
    _clearMessages();

    final result = await getPendingLeavesUseCase();
    result.when(
      success: (leaves) => _pendingLeaves = leaves,
      failure: (f) => _errorMessage = f.message,
    );

    _setLoading(false);
  }

  Future<void> fetchAllLeaves() async {
    _setLoading(true);
    _clearMessages();

    final result = await getAllLeavesUseCase();
    result.when(
      success: (leaves) => _allLeaves = leaves,
      failure: (f) => _errorMessage = f.message,
    );

    _setLoading(false);
  }

  Future<bool> reviewLeave({
    required String requestId,
    required String adminId,
    required String adminName,
    required bool approved,
    String? note,
  }) async {
    _setLoading(true);
    _clearMessages();

    final result = await reviewLeaveUseCase(
      requestId: requestId,
      adminId: adminId,
      adminName: adminName,
      approved: approved,
      note: note,
    );

    bool success = false;
    result.when(
      success: (leave) {
        _pendingLeaves.removeWhere((l) => l.id == leave.id);
        _successMessage = approved ? 'Izin disetujui.' : 'Izin ditolak.';
        success = true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        success = false;
      },
    );

    _setLoading(false);
    return success;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
