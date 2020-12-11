import 'dart:convert';
import 'dart:convert' as js;
import 'package:french_fry/models/remote/restaurant_model.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';

class EventRequest {
  String name;
  double latitude;
  double longitude;
  String distance;
  List<String> prices;
  List<String> cuisines;
  String eventTime;
  String swipeTime;
  bool allowFriend;
  bool allowQR;
  List<RestaurantModel> restaurants;
  DateTime createDate;
  String codeQR;
  RestaurantModel chooseRestaurant;
  List<SwipeModel> swipes;
  List<String> guests = List<String>();
  String host;
  bool isFromQRScreen = false;
  List<User> listUser = List<User>();
  String nameDB = '';
  bool isHost = false;
  bool isLast = false;

  EventRequest(
    this.name,
    this.latitude,
    this.longitude,
    this.distance,
    this.prices,
    this.cuisines,
    this.eventTime,
    this.swipeTime,
    this.allowFriend,
    this.allowQR,
    this.restaurants,
    this.codeQR,
    this.swipes,
    this.guests,
    this.host,
  );

  EventRequest.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      name = json['name'] == null ? "" : json['name'];
      latitude = json['latitude'] == null ? 0.0 : json['latitude'].toDouble();
      longitude =
          json['longitude'] == null ? 0.0 : json['longitude'].toDouble();
      distance = json['distance'] ?? '';
      prices = ((json['prices'] ?? []) as List<dynamic>).cast<String>();
      cuisines = ((json['cuisines'] ?? []) as List<dynamic>).cast<String>();
      eventTime = json['eventTime'] ?? '';
      swipeTime = json['swipeTime'] ?? '';
/*
      allowFriend = json['allowFriend'] == null ? true : (json['allowFriend'] == "true");
      allowQR = json['allowQR'] == null ? true : (json['allowQR'] == "true");
*/
      allowFriend = json['allowFriend'] != null && (json['allowFriend'] == 'true' || json['allowFriend'] == true);
      allowQR = json['allowQR'] != null && (json['allowQR'] == 'true' || json['allowQR'] == true);
      restaurants = (json['restaurants'] == null
          ? List<RestaurantModel>()
          : (js.jsonDecode(json['restaurants']) as List)
              .map((i) => new RestaurantModel.fromJson(i))
              .toList());
      createDate = json['createDate'] == null
          ? DateTime.now()
          : AppHelper.convertStringToDateWithFormat(
              json['createDate'], AppConstant.formatTime);
      codeQR = json['codeQR'] ?? '';
      swipes = (json['swipes'] == null
          ? List<SwipeModel>()
          : (js.jsonDecode(json['swipes']) as List)
              .map((i) => new SwipeModel.fromJson(i))
              .toList());
      guests = ((json['guests'] ?? []) as List<dynamic>).cast<String>();
      host = json['host'] ?? '';
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        // 'latitude' : latitude.toString(),
        // 'longitude' : longitude.toString(),
        // 'distance' : distance,
        // 'prices' : json.encode(prices),
        // 'cuisines' : json.encode(cuisines),
        'eventTime': eventTime,
        'swipeTime': swipeTime,
        'allowFriend' : allowFriend.toString(),
        'allowQR' : allowQR.toString(),
        'restaurants': json.encode(restaurants),
        'createDate': AppHelper.convertDatetoStringWithFormat(
            DateTime.now(), AppConstant.formatTime),
        'chooseRestaurant': json.encode(chooseRestaurant),
        'codeQR': codeQR,
        'swipes': json.encode(swipes),
        'guests' : guests,
        'host' : host,
      };
}

class SwipeModel {
  String user;
  List<SwipeRestaurantModel> restaurants;

  SwipeModel({this.user, this.restaurants});

  factory SwipeModel.fromJson(Map<String, dynamic> json) {
    return SwipeModel(
        user: json['user'] ?? '',
        restaurants: json['restaurants'] != null
            ? (js.jsonDecode(json['restaurants']) as List).map((e) => SwipeRestaurantModel.fromJson(e)).toList()
            : []);
  }

  Map<String, dynamic> toJson() =>
      {'user': user, 'restaurants': json.encode(restaurants)};
}

class SwipeRestaurantModel {
  String restaurantId;
  bool isLike;

  SwipeRestaurantModel({this.restaurantId, this.isLike});

  factory SwipeRestaurantModel.fromJson(Map<String, dynamic> json) {
    return SwipeRestaurantModel(
        restaurantId: json['restaurantId'] ?? '',
        isLike: json['isLike'] ?? false,);
  }

  Map<String, dynamic> toJson() =>
      {'restaurantId': restaurantId, 'isLike': isLike};
}
