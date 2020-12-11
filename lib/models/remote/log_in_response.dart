

import 'base_response.dart';

class LoginResponse extends BaseResponse {
  String tokenType;
  int expiresIn;
  String accessToken;
  String refreshToken;

  LoginResponse(Map<String, dynamic> fullJson) : super(fullJson) {
    tokenType= fullJson["token_type"];
    expiresIn= fullJson["expires_in"];
    accessToken= fullJson["access_token"];
    refreshToken= fullJson["refresh_token"];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "token_type": tokenType,
      "expires_in": expiresIn,
      "access_token": accessToken,
      "refresh_token": refreshToken,
    };
  }

  @override
  Map<String, dynamic> dataToJson(data) {
    return null;
  }

  @override
  jsonToData(Map<String, dynamic> fullJson) {
    return null;
  }
}
