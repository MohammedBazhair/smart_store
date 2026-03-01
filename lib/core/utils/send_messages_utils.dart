import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../errors/exceptions.dart';

/// دالة لإرسال إشعار لمجموعة أجهزة باستخدام Edge Function
Future<void> sendPushNotification({
  required List<String> playerIds,
  required String title,
  required String message,
}) async {
  final url = Uri.parse(
    'https://btesmjmzmgkjyljfxsxx.supabase.co/functions/v1/send_notification',
  );

  try {
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0ZXNtam16bWdranlsamZ4c3h4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4NjkyMDYsImV4cCI6MjA4NjQ0NTIwNn0.08YQFFWzFFb43EA1torB_ckO3xw4SgeWVpYraftKpyc', 
      },
      body: jsonEncode({
        'playerIds': playerIds,
        'title': title,
        'message': message,
      }),
    );

    if (res.statusCode == 200) {
      print('Notification sent successfully: ${res.body}');
    } else {
      print(
        'Failed to send notification. Status: ${res.statusCode}, Body: ${res.body}',
      );
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}

class UrlUtils {
  UrlUtils._();

  static Future<void> sendWhatsApp(
      {required String phone, required String message}) async {
    final url =
        Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw CannotLaunchWhatsAppException(message);
    }
  }
}
