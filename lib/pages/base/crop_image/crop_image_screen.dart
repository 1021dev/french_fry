import 'dart:io';
import 'package:flutter/material.dart';
import 'package:french_fry/pages/base/crop_image/image_crop.dart';

class CropImageScreen extends StatefulWidget {
  Map<dynamic, dynamic> args;
  Function(File) cropAction;
  CropImageScreen({@required this.args, @required this.cropAction});
  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final cropKey = GlobalKey<ImgCropState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: Container(
          margin: EdgeInsets.only(left: 10),
          alignment: Alignment.center,
          width: 80,
          height: 45,
          child: new FlatButton(
            padding: EdgeInsets.all(0.0),
            child: new Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 65,
            height: 45,
            child: new FlatButton(
              padding: EdgeInsets.all(0.0),
              child: new Text(
                'Apply',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final crop = cropKey.currentState;
                final croppedFile = await crop.cropCompleted(widget.args['image'],
                    pictureQuality: 600);
                widget.cropAction(croppedFile);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: ImgCrop(
          key: cropKey,
          maximumScale: 3,
          image: FileImage(widget.args['image']),
        ),
      ),
    );
  }
}