import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:planty_connect/model/send_notification_model.dart';

class MessagingService {
  FirebaseMessaging message = FirebaseMessaging.instance;
  static const String serverToken =
      'AAAAO8fJfiE:APA91bHCn_2_9WnpIiocxMcUKdJgGv9PIpnBGyf15-qS7C5tYxJa8Yvpp8mxGUqzzCw36RoqMP_QzimqRYWrK81Cpn30r2RQhOK441vuj6teLwGB1U9KoroLj0YYnBRi7Kymgy54T2vr';

  Future<String> getFcmToken() async {
    return await message.getToken();
  }

  void sendNotification(SendNotificationModel notification) async {
    print("token = ${notification.fcmTokens}");
    Response response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(notification.toMap()),
    );

    print(response.statusCode);
    print(response.body);
  }
}
