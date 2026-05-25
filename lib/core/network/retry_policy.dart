import 'dart:async';

import '../constants/app_constants.dart';

/// Small exponential retry helper for transient Firebase/network reads.
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = AppConstants.maxRetryAttempts,
    this.baseDelay = AppConstants.authRetryDelay,
  });

  final int maxAttempts;
  final Duration baseDelay;

  Future<T> run<T>(Future<T> Function() action) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await action();
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        if (attempt == maxAttempts - 1) {
          break;
        }
        await Future<void>.delayed(baseDelay * (attempt + 1));
      }
    }

    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }
}
