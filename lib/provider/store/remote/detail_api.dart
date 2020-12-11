

import 'package:french_fry/provider/store/remote/api.dart';
import 'package:dio/dio.dart';

class DetailApi extends Api {

  Future<Response> getUserInfo(String username) async {
    final header = await getHeader();
    String url = '$apiBaseUrl/users/$username';
    return wrapE(() => dio.get(url, options: Options(headers: header)));
  }
}
