

import 'dart:async';

import 'package:french_fry/provider/global.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../store.dart';

class Api {
  final String apiBaseUrl = Global.instance.env.apiBaseUrl;
  final Dio dio = new Dio();

  Api() {
    if (!kReleaseMode) {
      dio.interceptors.add(LogInterceptor(responseBody: false));
    }
  }

  Future<Map<String, String>> getHeader() async {
    Map<String, String> header = {'content-type': 'application/json'};
    return header;
  }

  Future<Map<String, String>> getAuthHeader() async {
    Map<String, String> header = await getHeader();

    header.addAll({"CUSTOM-HEADER-KEY": "CUSTOM-HEADER-KEY"});

    final accessToken = await DefaultStore.instance.getAuthToken();
    if (accessToken != null) {
      header.addAll({"Authorization": "Bearer " + accessToken});
    }
    return header;
  }


  Future<Response<dynamic>> wrapE(Function() dioApi) async {
    try {
      return await dioApi();
    } catch (error) {
      var errorMessage = error.toString();
      if (error is DioError && error.type == DioErrorType.RESPONSE) {
        final response = error.response;
        errorMessage =
            'Code ${response.statusCode} - ${response.statusMessage} ${response.data != null ? '\n' : ''} ${response.data}';
        throw new DioError(
            request: error.request,
            response: error.response,
            type: error.type,
            error: errorMessage);
      }
      throw error;
    }
  }
}
