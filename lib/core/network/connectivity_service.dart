import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectivityService {
  Future<bool> hasConnection();
  StreamSubscription<InternetStatus> listenToConnectionChanges(
    void Function(InternetStatus)? onData,
  );
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connection);
  final InternetConnection _connection;

  @override
  Future<bool> hasConnection() => _connection.hasInternetAccess;

  @override
  StreamSubscription<InternetStatus> listenToConnectionChanges(
    void Function(InternetStatus)? onData,
  ) {
    return _connection.onStatusChange.listen(onData);
  }
}
