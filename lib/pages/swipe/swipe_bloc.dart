import 'package:bflutter/bflutter.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/restaurant_model.dart';
import 'package:french_fry/provider/store/remote/search_api.dart';
import 'package:rxdart/rxdart.dart';

class SwipeBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var gotItBloc = BlocDefault<bool>();
  var reloadBLoc = BlocDefault<bool>();
  var getRestaurantFromIdBloc = Bloc<String, RestaurantModel>();
  var restaurantDetailBloc = BlocDefault<RestaurantModel>();
  var searchApi = SearchApi();
  var loading = BlocDefault<bool>();
  BuildContext context;

  SwipeBloc() {
    initLogic();
  }

    void initContext(BuildContext context) {
    this.context = context;
  }

  @override
  void dispose() {
    gotItBloc.dispose();
    reloadBLoc.dispose();
  }

  @override
  void initLogic() {
    getRestaurantFromIdBloc.logic = (Observable<String> input) => input
            .distinct()
            .debounceTime(Duration(milliseconds: 500))
            .flatMap((input) {
          loading.push(false);
          return Observable.fromFuture(searchApi.getDetailRestaurant(input))
              .asyncMap((data) async {
            return RestaurantModel.fromJson(data.data);
          });
        }).handleError((error) {
          loading.push(false);
        }).doOnData((data) {
          loading.push(false);
          restaurantDetailBloc.push(data);
        });
  }
}