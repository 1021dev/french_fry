

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';

class ImageOptions {
  final int width;
  final int height;

  ImageOptions({this.width, this.height})
      : assert(width != null),
        assert(height != null);

  @override
  int get hashCode => hashValues(width, height);

  @override
  bool operator ==(other) {
    return other is ImageOptions &&
        other.width == width &&
        other.height == height;
  }

  @override
  String toString() {
    return '$runtimeType(width: $width, height: $height)';
  }
}

class ImageCrops {

  static Future<bool> requestPermissions() {
    return ImageCrop.requestPermissions().then<bool>((result) => result);
  }

  static Future<File> cropImage({
    File file,
    Rect area,
    double scale,
  }) {
    assert(file != null);
    assert(area != null);
    return ImageCrop.cropImage(file: file, area: area, scale: scale).then<File>((result) => result);
  }

  static Future<File> sampleImage({
    File file,
    int preferredSize,
    int preferredWidth,
    int preferredHeight,
  }) async {
    assert(file != null);
    assert(() {
      if (preferredSize == null &&
          (preferredWidth == null || preferredHeight == null)) {
        throw ArgumentError(
            'Preferred size or both width and height of a resampled image must be specified.');
      }
      return true;
    }());
    return ImageCrop.sampleImage(
      file: file,
      preferredWidth: preferredSize ?? preferredWidth,
      preferredHeight: preferredSize ?? preferredHeight,
    );
  }
}
