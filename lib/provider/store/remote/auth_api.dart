

import 'dart:convert';
import 'package:french_fry/provider/store/remote/api.dart';
import 'package:dio/dio.dart';

class AuthApi extends Api {

  Future<Response> signIn() async {
    final header = await getHeader();
    return wrapE(() => dio.post("https://nhancv.free.beeceptor.com/login",
        options: Options(headers: header),
        data: json.encode({
          "username": "username",
          "password": "password",
        })));
  }


  Future<Response> signInWithError() async {
    final header = await getHeader();
    return wrapE(() => dio.post("https://nhancv.free.beeceptor.com/login-err",
        options: Options(headers: header),
        data: json.encode({
          "username": "username",
          "password": "password",
        })));
  }
}
