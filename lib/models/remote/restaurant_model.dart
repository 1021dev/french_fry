import 'dart:convert' as js;

class RestaurantModel {
  String id;
  String alias;
  String name;
  String imageUrl;
  int reviewCount;
  List<CategoryModel> categories;
  CoordinateModel coordinates;
  String price;
  String phone;
  String displayPhone;
  double distance;
  LocationRestaurantModel location;
  bool isLike;
  bool isDislike;
  int like = 0;
  int dislike = 0;
  bool isSwipe = false;
  double rating;
  List<String> photos = List<String>();

  RestaurantModel(this.id, this.alias, this.name, this.imageUrl,
      this.reviewCount, this.categories, this.coordinates, this.price, this.phone, this.displayPhone
      ,this.distance, this.location, this.rating, this.photos, this.like, this.dislike );

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      json['id'] as String,
      json['alias'] as String,
      json['name'] as String,
      json['image_url'] as String,
      json['review_count'] as int,
      (json['categories'] == null
          ? List<CategoryModel>()
          : (json['categories']  as List)
              .map((i) => new CategoryModel.fromJson(i))
              .toList()),
      new CoordinateModel.fromJson(json['coordinates']),
      json['price'] as String, 
      json['phone'] as String,
      json['display_phone'] as String,
      json['distance'] == null ? 0.0 : json['distance'].toDouble(),
      new LocationRestaurantModel.fromJson(json['location']),
      json['rating'] == null ? 0.0 : json['rating'].toDouble(),
      ((json['photos'] ?? []) as List<dynamic>).cast<String>(),
      json['like'] ?? 0,
      json['dislike'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alias': alias,
        'name': name,
        'image_url': imageUrl,
        'review_count': reviewCount,
        'categories' : categories,
        'coordinates' : coordinates, 
        'price' : price,
        'phone' : phone,
        'display_phone' : displayPhone,
        'distance' : distance,
        'location' : location,
        'rating' : rating,
        'photos' : photos,
        'like' : like,
        'dislike' : dislike,
      };
}

class CategoryModel {
  String title;
  String alias;

  CategoryModel(
    this.title,
    this.alias,
  );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      (json['title'] ?? '') as String,
      (json['alias'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'alias': alias,
      };
}

class CoordinateModel {
  double latitude;
  double longitude;

  CoordinateModel(
    this.latitude,
    this.longitude,
  );

  factory CoordinateModel.fromJson(Map<String, dynamic> json) {
    return CoordinateModel(
      json['latitude'] as double,
      json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class LocationRestaurantModel {
  String address1;
  String address2;
  String address3;
  String city;
  String zipCode;
  String country;
  String state;

  LocationRestaurantModel(
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.zipCode,
    this.country,
    this.state,
  );

  factory LocationRestaurantModel.fromJson(Map<String, dynamic> json) {
    return LocationRestaurantModel(
      json['address1'] as String,
      json['address2'],
      json['address3'],
      json['city'],
      json['zip_code'],
      json['country'],
      json['state'],
    );
  }

  Map<String, dynamic> toJson() => {
        'address1': address1,
        'address2': address2,
        'address3': address3,
        'city' : city,
        'zip_code' : zipCode,
        'country' : country,
        'state' : state,
      };
}
