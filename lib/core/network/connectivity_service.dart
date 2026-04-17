import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityService {
  Future<bool> hasConnection();
  StreamSubscription<List<ConnectivityResult>> listenToConnectionChanges(
    void Function(List<ConnectivityResult>)? onData,
  );
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connection);
  final Connectivity _connection;

  @override
  Future<bool> hasConnection() async {
    final connectionResult = await _connection.checkConnectivity();

    if (connectionResult.contains(ConnectivityResult.none)) return false;

    try {
      final lookup = await InternetAddress.lookup('example.com');

      if (lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty) return true;

      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  StreamSubscription<List<ConnectivityResult>> listenToConnectionChanges(
    void Function(List<ConnectivityResult>)? onData,
  ) {
    return _connection.onConnectivityChanged.listen(onData);
  }
}
