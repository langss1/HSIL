/// Failure hierarchy returned by repositories/use cases.
sealed class Failure {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class DataFailure extends Failure {
  const DataFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
