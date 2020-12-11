
import 'package:french_fry/utils/app_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {

  static SharedPrefService _instance = new SharedPrefService.internal();
  SharedPrefService.internal();
  factory SharedPrefService() => _instance;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //DEVICE TOKEN
  Future<String> getDeviceToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(AppConstant.kDeviceToken) ?? '';
  }

  Future<bool> saveDeviceToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(AppConstant.kDeviceToken, token);
  }

}