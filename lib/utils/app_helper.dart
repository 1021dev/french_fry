import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:french_fry/pages/popup/show_error_popup.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class AppHelper {
  static void showPopup(Widget child, BuildContext context,
      {Function onAction}) {
    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: child,
          );
        });
  }

  static Widget buildLoading(bool isLoading) {
    if (isLoading) {
      return Container(
        color: Color.fromRGBO(40, 42, 62, 0),
        child: SpinKitCircle(color: Color.fromRGBO(204, 155, 117, 1)),
        alignment: Alignment.center,
      );
    } else {
      return SizedBox();
    }
  }

  static void showMyDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShowErrorPopup(
            errorText: message,
            onYes: () {},
            contextLanguage: context,
          );
        });
  }

  static void showToast(String text, BuildContext contextx) {
    if ((text).toLowerCase().contains("please log in")) {
    } else {
      Navigator.of(contextx).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext ct, _, __) => ShowErrorPopup(
            errorText: text,
            onYes: () {},
            contextLanguage: contextx,
          ),
        ),
      );
    }
  }

  static showToaster(String text, BuildContext contextx) {
    Toast.show(text, contextx,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        backgroundRadius: 10,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.8),
        textColor: Colors.white);
  }

  static String emailValidate(String email) {
    String error = '';
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (email.isEmpty || email == '' || email == null) {
      error = 'Email is required.';
    } else if (!regex.hasMatch(email)) {
      error = 'Your email format is invalid. Please check again';
    }
    return error;
  }

  static String random4Number() {
    Random random = new Random();
    String randomString = '';
    for (var i = 0; i < 4; i ++) {
      randomString +=  random.nextInt(10).toString();
    }
    return randomString;
  }

  static Future<bool> internetConnectionChecking() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static double getHeightFromScreenSize(
      BuildContext context, double heightDesign) {
    return MediaQuery.of(context).size.height * heightDesign / 812; //Iphone X
  }

  static double getWidthFromScreenSize(
      BuildContext context, double widthDesign) {
    return MediaQuery.of(context).size.width * widthDesign / 375; //Iphone X
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String getNameAlpha(String name) {
    var listName =
        name.split(' ').where((i) => i.replaceAll(' ', '').length > 0).toList();
    if (listName.length >= 2) {
      return listName.first.substring(0, 1).toUpperCase() +
          listName.last.substring(0, 1).toUpperCase();
    } else {
      return name.replaceAll(' ', '').substring(0, 2).toUpperCase();
    }
  }

  static String getPhoneNumberUS(String textPhone) {
    if (textPhone.length >= 9 && textPhone[0] == '+') {
      return '${textPhone.substring(0, 2)} (${textPhone.substring(2, 5)}) ${textPhone.substring(5, 8)}-${textPhone.substring(8, textPhone.length)}';
    } else {
      return '${textPhone.substring(0, 3)} (${textPhone.substring(3, 6)}) ${textPhone.substring(6, 9)}-${textPhone.substring(9, textPhone.length)}';
    }
  }

  static String convertDatetoStringWithFormat(DateTime date, String format) {
    var _fm = DateFormat(format);
    return _fm.format(date) ?? '';
  }

  static DateTime convertStringToDateWithFormat(String date, String format) {
    var _fm = DateFormat(format);
    return _fm.parse(date) ?? '';
  }

  static String checkKeyCuisine(String key) {
    if (key.toLowerCase() == 'american') {
      return 'tradamerican';
    } else if (key.toLowerCase() == 'steakhouse') {
      return 'steak';
    } else if (key.toLowerCase() == 'breakfast') {
      return 'breakfast_brunch';
    } else if (key.toLowerCase() == 'dessert') {
      return 'desserts';
    } else if (key.toLowerCase() == 'buffet') {
      return 'buffets';
    } else if (key.toLowerCase() == 'fusion') {
      return 'asianfusion';
    } else if (key.toLowerCase() == 'indian') {
      return 'indpak';
    }
    return key.toLowerCase();
  }
}
