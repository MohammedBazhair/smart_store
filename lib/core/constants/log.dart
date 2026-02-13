import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void debugLog({String? message, Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('------------------[LOGGER]------------------');
   if(message!=null) debugPrint( 'Message: $message');
    if(error!=null) debugPrint('Error: $error');
    if(stackTrace!=null) debugPrint(stackTrace.toString());
  }
}
