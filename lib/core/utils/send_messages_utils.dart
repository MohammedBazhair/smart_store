import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../errors/exceptions.dart';
import '../constants/log.dart';

Future<void> sendPushNotification({
  required List<String> playerIds,
  required String title,
  required String message,
}) async {
  if (playerIds.isEmpty) {
    return;
  }

  const oneSignalAppId = '4a72759f-2beb-4621-80ed-7ee6b9bfc813';
  const oneSignalRestApiKey =
      'os_v2_app_jjzhlhzl5ndcdahnp3tltp6icm3r4augweku5vnz24nariikfvl4tiwy5fegtvwf6ia47o5xddqdlmaihja6bbald37sutk56oceaii';

  final url = Uri.parse('https://api.onesignal.com/notifications');

  final payload = {
    'app_id': oneSignalAppId,
    'include_aliases': {'external_id': playerIds},
    'target_channel': 'push',
    'contents': {'en': message},
    'headings': {'en': title},
    'data': {
      'type': 'تفعيل حسابك',
    },
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Key $oneSignalRestApiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to send notification: ${response.statusCode} - ${response.body}',
      );
    }
  } catch (e,st) {
    Logger.debugLog(error: e,stackTrace: st);
  }
}

class UrlUtils {
  UrlUtils._();

  static Future<void> sendWhatsApp({
    required String phone,
    required String message,
  }) async {
    final url =
        Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw CannotLaunchWhatsAppException(message);
    }
  }
}
