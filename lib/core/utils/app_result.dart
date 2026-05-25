import '../errors/failures.dart';

/// Tiny result type to avoid leaking exceptions into the presentation layer.
sealed class AppResult<T> {
  const AppResult();

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    return switch (self) {
      AppSuccess<T>(:final value) => success(value),
      AppFailure<T>(:final error) => failure(error),
    };
  }
}

class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.value);

  final T value;
}

class AppFailure<T> extends AppResult<T> {
  const AppFailure(this.error);

  final Failure error;
}
