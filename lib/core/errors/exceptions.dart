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
