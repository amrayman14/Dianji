import 'dart:convert';
import 'dart:io';

import 'package:booking_system_flutter/main.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/user_data_model.dart';

class NotificationService {
  Future<void> sendPushNotifications(String title, String content, {String? image, required UserData receiverUser, required UserData senderUserData}) async {
    Map<String, dynamic> data = senderUserData.toJson();

    data.putIfAbsent("is_chat", () => true);

    Map req = {
      'to': "/topics/user_${receiverUser.id.validate()}",
      "collapse_key": "type_a",
      "notification": {
        "body": content,
        "title": "$title sent you a message",
      },
      'data': data,
    };

    log(req);
    var header = {
      HttpHeaders.authorizationHeader: 'key=${appConfigurationStore.firebaseServerKey.validate()}',
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Response res = await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: jsonEncode(req),
      headers: header,
    );

    log(res.statusCode);
    log(res.body);

    if (res.statusCode.isSuccessful()) {
    } else {
      throw errorSomethingWentWrong;
    }
  }
}
