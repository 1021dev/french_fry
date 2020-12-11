import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/country.dart';
import 'package:french_fry/provider/store/remote/api.dart';

class AccountApi extends Api {
  Future<List<Country>> loadCountriesJson(BuildContext context) async {
    List<Country> countries = List<Country>();
    var value = await DefaultAssetBundle.of(context)
        .loadString("assets/json/country_phone_codes.json");
    var countriesJson = json.decode(value);
    for (var country in countriesJson) {
      countries.add(Country.fromJson(country));
    }
    return countries;
  }
}
