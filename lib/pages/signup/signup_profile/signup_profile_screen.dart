import 'dart:io';
import 'package:bflutter/bflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/pages/base/crop_image/crop_image_screen.dart';
import 'package:french_fry/pages/signup/signup_profile/signup_profile_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

class SignUpProfileScreen extends StatefulWidget {
  FirebaseUser authUser;
  SignUpProfileScreen({Key key, this.authUser}) : super(key: key);

  @override
  _SignUpProfileScreenState createState() => _SignUpProfileScreenState();
}

class _SignUpProfileScreenState extends State<SignUpProfileScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = SignUpProfileBloc();
  TextEditingController usernameController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  File _image;
  String username = '';
  bool isSetUserName = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.redColor,
      resizeToAvoidBottomInset: false,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: GestureDetector(
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              _buildBody(context),
            ],
          ),
          onTap: () {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: 45,
        margin: EdgeInsets.only(top: 0, left: 0, right: 0),
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: 0, top: 0, bottom: 0),
          width: 50,
          height: 45,
          child: FlatButton(
            padding: EdgeInsets.all(0.0),
            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                  ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              AppImages.icBackWhite,
              width: 9,
              height: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(0),
        decoration: new BoxDecoration(
          color: AppColor.bgColor,
          borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(44), topRight: Radius.circular(44)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 44)),
              Container(
                height: 34,
                margin: EdgeInsets.only(
                  top: 0,
                ),
                alignment: Alignment.topCenter,
                child: Text(
                  'Sign Up',
                  style: AppStyle.style24MediumRed,
                ),
              ),
              Container(
                height: 28,
                margin: EdgeInsets.only(
                  top: 16,
                ),
                alignment: Alignment.topCenter,
                child: Text(
                  'Complete your profile.',
                  style: AppStyle.style14RegularGrey,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.0),
              _buildAvatar(context),
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 28)),
              Container(
                height: 64,
                margin: EdgeInsets.only(top: 0, left: 16, right: 16),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppHelper.fromHex('FA8D35').withOpacity(0.5),
                      blurRadius: 35.0,
                      spreadRadius: 1.0,
                      offset: Offset(
                        2.0,
                        2.0,
                      ),
                    )
                  ],
                  borderRadius: new BorderRadius.all(Radius.circular(12)),
                ),
                child: Column(
                  children: <Widget>[
                    _buildUserName(context),
                    _buildLine(context),
                  ],
                ),
              ),
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 32)),
              _buildFinish(context),
            ],
          ),
        ),
      ),
    );
  }

  _buildAvatar(BuildContext context) {
    return StreamBuilder(
      stream: bloc.reloadBloc.stream,
      builder: (context, data) {
        return Container(
          margin: EdgeInsets.only(top: 0),
          child: Container(
            margin: EdgeInsets.only(top: 0),
            alignment: Alignment.topCenter,
            width: 104,
            height: 104,
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                margin: EdgeInsets.only(top: 0),
                width: 104,
                alignment: Alignment.topCenter,
                height: 104,
                decoration: new BoxDecoration(
                  color: AppColor.whiteOpacity, //Colors.white.withOpacity(0.4),
                  borderRadius: new BorderRadius.all(
                    Radius.circular(52),
                  ),
                ),
                child: FlatButton(
                  padding: EdgeInsets.all(0.0),
                  shape: CircleBorder(),
                  onPressed: () {
                    //ACTION CHANGE AVATAR
                    FocusScope.of(context).unfocus();
                    _buildBottomSheetAvatar(context);
                  },
                  child: isSetUserName
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            AppHelper.getNameAlpha(username),
                            style: AppStyle.style36MediumRed,
                          ))
                      : (_image == null
                          ? Container(
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.icPhoto,
                                width: 48,
                                height: 36,
                              ),
                            )
                          : Container(
                              width: 104,
                              height: 104,
                              margin: EdgeInsets.all(0.0),
                              decoration: BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                  Radius.circular(52),
                                ),
                                image: new DecorationImage(
                                  image: new FileImage(_image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _buildBottomSheetAvatar(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return new Container(
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 14),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16.0,
                        spreadRadius: 1.0,
                        offset: Offset(
                          0.0,
                          8.0,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                        height: 56,
                        width: MediaQuery.of(context).size.width - 32,
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(28.0)),
                          padding: EdgeInsets.all(0.0),
                          onPressed: () async {
                            //CHOOSE PHOTO
                            isSetUserName = false;
                            Navigator.pop(context);
                            await getGallery(context);
                          },
                          child: Text(
                            'CHOOSE PHOTO',
                            textAlign: TextAlign.center,
                            style: AppStyle.style14BoldGrey,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                        height: 56,
                        width: MediaQuery.of(context).size.width - 32,
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(28.0)),
                          padding: EdgeInsets.all(0.0),
                          onPressed: () async {
                            //TAKE PHOTO
                            isSetUserName = false;
                            Navigator.pop(context);
                            await getTakePhoto(context);
                          },
                          child: Text(
                            'TAKE PHOTO',
                            textAlign: TextAlign.center,
                            style: AppStyle.style14BoldGrey,
                          ),
                        ),
                      ),
                      username.replaceAll(' ', '').length <= 1
                          ? Opacity(
                              opacity: 0.4,
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 0, right: 0, bottom: 0),
                                height: 56,
                                width: MediaQuery.of(context).size.width - 32,
                                alignment: Alignment.center,
                                child: Text(
                                  'USE INITIALS',
                                  textAlign: TextAlign.center,
                                  style: AppStyle.style14BoldBlack,
                                ),
                              ),
                            )
                          : Container(
                              margin:
                                  EdgeInsets.only(left: 0, right: 0, bottom: 0),
                              height: 56,
                              width: MediaQuery.of(context).size.width - 32,
                              child: FlatButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(28.0)),
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  //USE INITIALS
                                  isSetUserName = true;
                                  bloc.reloadBloc.push(true);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'USE INITIALS',
                                  textAlign: TextAlign.center,
                                  style: AppStyle.style14BoldGrey,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                //CANCEL
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 21),
                  height: 56,
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: new BoxDecoration(
                    color: AppHelper.fromHex('FFC857'),
                    borderRadius: new BorderRadius.all(Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16.0,
                        spreadRadius: 1.0,
                        offset: Offset(
                          0.0,
                          8.0,
                        ),
                      ),
                    ],
                  ),
                  child: FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(28.0)),
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      //CANCEL
                      Navigator.pop(context);
                    },
                    child: Text(
                      'CANCEL',
                      textAlign: TextAlign.center,
                      style: AppStyle.style14BoldRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future getTakePhoto(BuildContext context) async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);

    if (_image != null) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (BuildContext context) => CropImageScreen(
            args: {'image': _image},
            cropAction: (File file) async {
              _image = file;
              bloc.reloadBloc.push(true);
              bloc.upload(context, _image, false, username, widget.authUser);
            },
          ),
        ),
      );
    }
  }

  Future getGallery(BuildContext context) async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (_image != null) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (BuildContext context) => CropImageScreen(
            args: {'image': _image},
            cropAction: (File file) async {
              _image = file;
              bloc.reloadBloc.push(true);
              bloc.upload(context, _image, false, username, widget.authUser);
            },
          ),
        ),
      );
    }
  }

  Widget _buildUserName(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 12.5, left: 24, right: 24),
        height: 39,
        child: TextField(
          style: AppStyle.style16RegularBlack,
          decoration: InputDecoration(
            hintText: 'Your Name',
            hintStyle: AppStyle.style16RegularBlack60,
            border: InputBorder.none,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          controller: usernameController,
          obscureText: false,
          onChanged: (text) {
            username = text;
            bloc.validInput.push(text.replaceAll(' ', '').length > 1);
          },
          onSubmitted: (text) {
            username = text;
            if (text.replaceAll(' ', '').length > 1) {
              //API UPLOAD USER
              if (isSetUserName || _image == null) {
                isSetUserName = true;
                bloc.reloadBloc.push(true);
                Future.delayed(Duration(milliseconds: 500)).then((value) {
                  screenshotController
                      .capture(pixelRatio: 2.5)
                      .then((File image) {
                    _image = image;
                    bloc.upload(
                        context, _image, true, username, widget.authUser);
                  }).catchError((onError) {
                    print(onError);
                  });
                });
              } else {
                bloc.uploadUser(context, username, widget.authUser);
              }
            }
          },
        ));
  }

  Widget _buildLine(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 24, right: 24),
      color: Colors.black.withOpacity(0.4),
      height: 0.5,
    );
  }

  Widget _buildFinish(BuildContext context) {
    return StreamBuilder(
      stream: bloc.validInput.stream,
      builder: (context, AsyncSnapshot<bool> data) {
        if (data.data ?? false) {
          return Container(
            width: 168,
            height: 44,
            padding: EdgeInsets.all(0.0),
            alignment: Alignment.topCenter,
            decoration: new BoxDecoration(
              color: AppColor.redColor,
              borderRadius: new BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(250, 141, 53, 0.5),
                  blurRadius: 16.0,
                  spreadRadius: 1.0,
                  offset: Offset(
                    0.0,
                    8.0,
                  ),
                ),
              ],
            ),
            child: Container(
              width: 168,
              height: 44,
              margin: EdgeInsets.all(0.0),
              decoration: new BoxDecoration(
                color: AppColor.redColor,
                borderRadius: new BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(250, 141, 53, 0.5),
                    blurRadius: 16.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0.0,
                      8.0,
                    ),
                  ),
                ],
              ),
              child: FlatButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  //API UPLOAD USER
                  if (isSetUserName || _image == null) {
                    isSetUserName = true;
                    bloc.reloadBloc.push(true);
                    Future.delayed(Duration(milliseconds: 500)).then((value) {
                      screenshotController
                          .capture(pixelRatio: 2.5)
                          .then((File image) {
                        _image = image;
                        bloc.upload(
                            context, _image, true, username, widget.authUser);
                      }).catchError((onError) {
                        print(onError);
                      });
                    });
                  } else {
                    bloc.uploadUser(context, username, widget.authUser);
                  }
                },
                padding: EdgeInsets.all(0.0),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                child: Text(
                  'FINISH',
                  style: AppStyle.style14BoldWhite,
                ),
              ),
            ),
          );
        }
        return Opacity(
          opacity: 0.6,
          child: Container(
            width: 168,
            height: 44,
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              color: AppColor.redColor,
              borderRadius: new BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(250, 141, 53, 0.5),
                  blurRadius: 16.0,
                  spreadRadius: 1.0,
                  offset: Offset(
                    0.0,
                    8.0,
                  ),
                ),
              ],
            ),
            child: Text(
              'FINISH',
              style: AppStyle.style14BoldWhite,
            ),
          ),
        );
      },
    );
  }
}
