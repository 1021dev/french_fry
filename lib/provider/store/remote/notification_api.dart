import 'dart:convert';

import 'package:french_fry/models/remote/request/notification_request.dart';
import 'package:french_fry/provider/store/remote/api.dart';
import 'package:dio/dio.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NotificationApi extends Api {
  Future<Response> sendMessage(NotificationRequest model) async {
    final header = await getHeader();
    String url = 'https://fcm.googleapis.com/fcm/send';
    return wrapE(
      () => dio.post(
        url,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": AppConstant.kKeyServerFireBase
        }),
        data: json.encode(
          {
            "notification": {
              "title": model.title,
              "body": model.body,
              "content_available": true
            },
            "to": model.to,
            "data": {
              "type": "news",
              "id": "2",
              "click_action": "FLUTTER_NOTIFICATION_CLICK"
            }
          },
        ),
      ),
    );
  }
}
