


import 'package:bflutter/bflutter.dart';
import 'package:bflutter/provider/app_bloc.dart';
import 'package:bflutter/provider/main_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/main.dart';
import 'package:french_fry/models/remote/country.dart';
import 'package:french_fry/pages/signup/code/signup_code_screen.dart';
import 'package:french_fry/provider/store/remote/account_api.dart';
import 'package:french_fry/provider/store/remote/auth_api.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:page_transition/page_transition.dart';

class LoginBloc with AppBloc {
  final usernameInput = Bloc<String, bool>();
  final validInput = BlocDefault<bool>();
  final loginTrigger = BlocDefault<bool>();

  final authApi = AuthApi();
  final accountApi = AccountApi();
  final mainBloc = MainBloc.instance;

  var firebaseAuth = FirebaseAuth.instance;

  var countryBloc = BlocDefault<List<Country>>();
  var listFullCountries = List<Country>();
  var countrySelectedBloc = BlocDefault<Country>();
  String numberPhone = '';
  static String actualCode = '';
  BuildContext context;
  static BuildContext contextPopup;

  LoginBloc() {
    initLogic();
  }

  @override
  void initLogic() {
    // Logic check not empty
    usernameInput.logic = (input) => input.map((d) => d.isNotEmpty);

    eventBus.on().listen((value) {
      if (value == AppConstant.kNavigateConfirmLogin) {
        //NAVIGATE HOME
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: SignUpCodeScreen(
              phone: this.numberPhone,
              actualCode: actualCode,
              isLogin: true,
            ),
          ),
        );
      }
    });

  }

  //SEARCH COUNTRIES
  void searchCountries(String query) {
    if (query.length == 0) {
      countryBloc.push(listFullCountries);
    } else if (query.length >= 1 && query.length <= 5) {
      List<Country> searchResults = [];
      for (var c in listFullCountries) {
        if (c.name.toString().toLowerCase().contains(query.toLowerCase()))
          searchResults.add(c);
      }
      countryBloc.push(searchResults);
    } else {
      List<Country> searchResults = [];
      countryBloc.push(searchResults);
    }
  }

  //GET LIST COUNTRY
  void getListCountries(BuildContext context) async {
    List<Country> countries = await accountApi.loadCountriesJson(context);
    listFullCountries = countries;
    countryBloc.push(countries);
  }

  //VALIDATE BUTTON
  void checkInput(BuildContext context, String str) {
    var phone = str
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll(" ", "")
        .replaceAll("-", "");
    validInput.push(phone.length >= 9 && phone.length <= 16);
  }

  //ACTION PHONE
  void checkPhoneSignUp(BuildContext context, String phone) async {
    this.context = context;
    contextPopup = context;
    this.numberPhone = phone;
    validInput.push(false);
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  PhoneCodeSent codeSent =
      (String verificationId, [int forceResendingToken]) async {
    actualCode = verificationId;
    eventBus.fire(AppConstant.kNavigateConfirmLogin);
    print("verificationId : ${verificationId}");
  };

  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
      (String verificationId) {
    AppHelper.showMyDialog(contextPopup, 'Auto retrieval time out');
  };
  final PhoneVerificationFailed verificationFailed =
      (AuthException authException) {
    if (authException.message.contains('not authorized'))
      AppHelper.showMyDialog(contextPopup, 'Something has gone wrong, please try later');
    else if (authException.message.contains('Network'))
      AppHelper.showMyDialog(contextPopup, 'Please check your internet connection and try again');
    else
      AppHelper.showMyDialog(contextPopup, '${authException.message}');
  };

  PhoneVerificationCompleted verificationCompleted = (AuthCredential auth) {
    FirebaseAuth.instance.signInWithCredential(auth).then((AuthResult value) {
      if (value.user != null) {
        print('Authentication successful');
      } else {
        AppHelper.showMyDialog(contextPopup, 'Invalid code/invalid authentication');
      }
    }).catchError((error) {
      AppHelper.showMyDialog(contextPopup, '${error.message}');
    });
  };

  @override
  void dispose() {
    usernameInput.dispose();
    loginTrigger.dispose();
  }
}
