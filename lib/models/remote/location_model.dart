class LocationModel {
  List<AddressComponent> addressComponents;
  String formattedAddress;
  String placeId;
  Geometry geometry;
  

  LocationModel(
    this.addressComponents,
    this.formattedAddress,
    this.placeId,
    this.geometry,
  );

  LocationModel.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      addressComponents = json['address_components'] == null ? List<AddressComponent>()
        : (json['address_components'] as List)
            .map((i) => new AddressComponent.fromJson(i))
            .toList();
      formattedAddress = json['formatted_address'] == null ? "" : json['formatted_address'];
      placeId = json['place_id'] == null ? "" : (json['place_id'] as String);
      geometry = json['geometry'] == null ? null : new Geometry.fromJson(json['geometry']);
    }
  }

  Map<String, dynamic> toJson() => {
        'address_components' : addressComponents,
        'formatted_address' : formattedAddress,
        'place_id' : placeId,
        'geometry' : geometry,
      };
}

///////////////////////////////////////////////////////////////////////
///AddressComponent
///////////////////////////////////////////////////////////////////////
class AddressComponent {
  String longName;
  String shortName;
  List<String> types;
  

  AddressComponent(
    this.longName,
    this.shortName,
  );

  AddressComponent.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      longName = json['long_name'] == null ? "" : json['long_name'];
      shortName = json['short_name'] == null ? "" : (json['short_name'] as String);
      types = json['types'] == null ? [] : (json['types'] as List<dynamic>).cast<String>();
    }
  }

  Map<String, dynamic> toJson() => {
        'long_name' : longName,
        'short_name' : shortName,
      };
}

///////////////////////////////////////////////////////////////////////
///Geometry
///////////////////////////////////////////////////////////////////////
class Geometry {
  PositionModel location;

  Geometry(
    this.location,
  );

  Geometry.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      location = json['location'] == null ? null : PositionModel.fromJson(json['location']);
    }
  }

  Map<String, dynamic> toJson() => {
        'location' : location,
      };
}

///////////////////////////////////////////////////////////////////////
//POSITION MODEL
///////////////////////////////////////////////////////////////////////
class PositionModel {
  double lat;
  double lng;
  

  PositionModel(
    this.lat,
    this.lng,
  );

  PositionModel.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      lat = json['lat'] == null ? 0.0 : json['lat'].toDouble();
      lng = json['lng'] == null ? 0.0 : json['lng'].toDouble();
    }
  }

  Map<String, dynamic> toJson() => {
        'lat' : lat,
        'lng' : lng,
      };
}