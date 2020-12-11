class RestaurantRequest {
  double latitude = 0.0;
  double longitude = 0.0;
  String term = 'restaurants';
  String price = '1,2,3,4';
  int radius = 0;
  String categories = '';
  int timeOpen = 0;

  RestaurantRequest(
    this.latitude,
    this.longitude,
    this.term,
    this.price,
    this.radius,
    this.categories,
    this.timeOpen,
  );
}
