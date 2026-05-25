import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps network status checks so repositories can make offline-aware choices.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
