/// Base app exception for known, user-facing failure states.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class FirebaseDataException extends AppException {
  const FirebaseDataException(super.message, {super.code});
}

class UserNotFoundException extends AppException {
  const UserNotFoundException(super.message, {super.code});
}

class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException(super.message, {super.code});
}

class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException([
    String message = 'Izin lokasi ditolak. Aplikasi membutuhkan akses GPS.',
  ]) : super(message);
}

class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException([
    String message = 'Layanan lokasi tidak aktif. Nyalakan GPS di pengaturan.',
  ]) : super(message);
}

class AlreadyClockedInException extends AppException {
  const AlreadyClockedInException([
    String message = 'Anda sudah melakukan clock-in hari ini.',
  ]) : super(message);
}

class NotClockedInException extends AppException {
  const NotClockedInException([
    String message = 'Anda belum melakukan clock-in hari ini.',
  ]) : super(message);
}

class OutsideRadiusException extends AppException {
  const OutsideRadiusException([
    String message = 'Anda berada di luar radius kantor.',
  ]) : super(message);
}
