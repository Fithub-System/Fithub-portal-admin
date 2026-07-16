import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Observes device connectivity and exposes online/offline transitions.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Stream<bool> get onStatusChanged => _controller.stream;

  Future<void> start() async {
    final initial = await _connectivity.checkConnectivity();
    _emit(initial);

    _subscription = _connectivity.onConnectivityChanged.listen(_emit);
  }

  void _emit(List<ConnectivityResult> results) {
    final online = _isConnected(results);
    if (online == _isOnline) {
      return;
    }
    _isOnline = online;
    _controller.add(online);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
