import '../../core/errors/failures.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/admin_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/registration_request.dart';
import '../datasources/firestore_admin_data_source.dart';
import '../datasources/firestore_user_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl({
    required this.adminDataSource,
    this.userDataSource,
  });

  final FirestoreAdminDataSource adminDataSource;
  final FirestoreUserDataSource? userDataSource;

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

  @override
  Future<AppResult<void>> addEmployee(RegistrationRequest request) async {
    if (userDataSource == null) {
      return const AppFailure(NetworkFailure('Firebase belum siap.'));
    }

    final normalizedNik = request.nik.trim();
    final normalizedName = request.name.trim();
    final normalizedEmail = request.email.trim();
    
    // Cross-check duplicates directly via userDataSource
    try {
      final existingNik = await userDataSource!.getUserByNik(normalizedNik);
      if (existingNik != null) {
        return const AppFailure(AuthFailure('NIK sudah terdaftar.', code: 'nik-already-in-use'));
      }
      final existingEmail = await userDataSource!.getUserByEmail(normalizedEmail);
      if (existingEmail != null) {
        return const AppFailure(AuthFailure('Email sudah terdaftar.', code: 'email-already-in-use'));
      }
    } catch (e) {
      return AppFailure(DataFailure('Gagal memvalidasi data: $e'));
    }

    // Secondary App trick to create Auth user without logging out Admin
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: request.password,
      );
      
      final uid = credential.user?.uid;
      if (uid == null) {
        return const AppFailure(AuthFailure('Gagal mendapatkan UID dari Firebase Auth.'));
      }

      final normalizedRequest = RegistrationRequest(
        nik: normalizedNik,
        name: normalizedName,
        email: normalizedEmail,
        password: request.password,
        department: request.department.trim(),
        position: request.position.trim(),
        phone: request.phone?.trim().isNotEmpty == true ? request.phone!.trim() : null,
      );

      // Create document in Firestore
      await userDataSource!.createEmployeeProfile(
        userId: uid,
        request: normalizedRequest,
      );
      
      return const AppSuccess(null);
    } on FirebaseAuthException catch (e) {
      return AppFailure(AuthFailure(e.message ?? 'Gagal membuat akun.', code: e.code));
    } catch (e) {
      return AppFailure(UnknownFailure('Terjadi kesalahan tidak terduga: $e'));
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }
}
