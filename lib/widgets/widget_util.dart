

import 'dart:io';

import 'package:flutter/material.dart';

class WidgetUtil {
  static double resizeByWidth(context, double value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double result = value * screenWidth / 375;
    return result ?? value;
  }

  static double topSpacer(context) {
    double spacer = 22;
    if (Platform.isIOS && (MediaQuery.of(context).size.height > 800)) {
      spacer = 44;
    }
    return spacer;
  }
}