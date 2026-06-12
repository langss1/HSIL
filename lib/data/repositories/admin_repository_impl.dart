import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/firestore_admin_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl({
    required this.adminDataSource,
  });

  final FirestoreAdminDataSource adminDataSource;

  @override
  Future<AppResult<List<AppUser>>> getAllEmployees() async {
    try {
      final models = await adminDataSource.getAllEmployees();
      return AppSuccess(<AppUser>[...models]);
    } on Failure catch (e) {
      return AppFailure(e);
    } catch (e) {
      return AppFailure(DataFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<AttendanceRecord>>> getTodayAttendance() async {
    try {
      final models = await adminDataSource.getTodayAttendance();
      return AppSuccess(<AttendanceRecord>[...models]);
    } on Failure catch (e) {
      return AppFailure(e);
    } catch (e) {
      return AppFailure(DataFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<AttendanceRecord>>> getEmployeeAttendance(
      String employeeId, DateTime startDate, DateTime endDate) async {
    try {
      final models = await adminDataSource.getEmployeeAttendance(
          employeeId, startDate, endDate);
      return AppSuccess(<AttendanceRecord>[...models]);
    } on Failure catch (e) {
      return AppFailure(e);
    } catch (e) {
      return AppFailure(DataFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<AttendanceRecord>>> getAttendanceRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final models = await adminDataSource.getAttendanceRange(
          startDate, endDate);
      return AppSuccess(<AttendanceRecord>[...models]);
    } on Failure catch (e) {
      return AppFailure(e);
    } catch (e) {
      return AppFailure(DataFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> updateEmployeeRole(
      String employeeId, UserRole newRole) async {
    try {
      await adminDataSource.updateEmployeeRole(employeeId, newRole);
      return const AppSuccess(null);
    } on Failure catch (e) {
      return AppFailure(e);
    } catch (e) {
      return AppFailure(DataFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> deleteEmployee(String employeeId) async {
    try {
      await adminDataSource.deleteEmployeeDoc(employeeId);
      return const AppSuccess(null);
    } on Failure catch (e) {
      return AppFailure(e);
    } catch (e) {
      return AppFailure(DataFailure(e.toString()));
    }
  }
}
