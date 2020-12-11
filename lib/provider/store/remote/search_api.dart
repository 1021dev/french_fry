

import 'package:french_fry/models/remote/request/restaurant_request.dart';
import 'package:french_fry/provider/store/remote/api.dart';
import 'package:dio/dio.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchApi extends Api {
  Future<Response> searchWithKey(String key) async {
    final header = await getHeader();
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$key&key=AIzaSyATNMhMj6ANj6ElT8EKKFAwVNmbM7zLxs4';
    return wrapE(() => dio.get(url, options: Options(headers: header)));
  }

  Future<Response> searchWithLatLng(LatLng latlng) async {
    final header = await getHeader();
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latlng.latitude},${latlng.longitude}&key=AIzaSyATNMhMj6ANj6ElT8EKKFAwVNmbM7zLxs4';
    return wrapE(() => dio.get(url, options: Options(headers: header)));
  }

  Future<Response> searchRestaurant(RestaurantRequest model) async {
    String url = 'https://api.yelp.com/v3/businesses/search?latitude=${model.latitude}&longitude=${model.longitude}&term=${model.term}&price=${model.price}&radius=${model.radius}&categories=${model.categories}&open_at=${model.timeOpen}';
    return wrapE(() => dio.get(url, options: Options(headers: {"Content-Type" : "application/json", "Authorization" : AppConstant.kRestaurant })));
  }

  Future<Response> getDetailRestaurant(String restaurantId) async {
    String url = 'https://api.yelp.com/v3/businesses/${restaurantId.toString()}';
    return wrapE(() => dio.get(url, options: Options(headers: {"Content-Type" : "application/json", "Authorization" : AppConstant.kRestaurant })));
  }

}
