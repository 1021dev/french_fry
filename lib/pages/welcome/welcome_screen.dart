import 'package:bflutter/bflutter.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/pages/login/login_screen.dart';
import 'package:french_fry/pages/signup/signup_screen.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:page_transition/page_transition.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key key}) : super(key: key);
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final mainBloc = MainBloc.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.all(0),
          color: AppColor.bgColor,
          child: Column(
            children: <Widget>[
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 202)),
              Container(
                alignment: Alignment.topCenter,
                width: AppHelper.getWidthFromScreenSize(context, 326),
                height:
                    AppHelper.getWidthFromScreenSize(context, 326) * 240 / 326,
                child: Image.asset(
                  AppImages.icLogo,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 32)),
              _buildButton(context, isSignUp: true),
              SizedBox(height: 12),
              _buildButton(context, isSignUp: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {bool isSignUp}) {
    return Container(
      alignment: Alignment.topCenter,
      height: 72,
      width: AppHelper.getWidthFromScreenSize(context, 343),
      padding: EdgeInsets.all(0.0),
      decoration: new BoxDecoration(
        color: isSignUp ? AppColor.redColor : Colors.white,
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
        borderRadius: new BorderRadius.all(Radius.circular(35)),
      ),
      child: Container(
        margin: EdgeInsets.all(0.0),
        height: 72,
        width: AppHelper.getWidthFromScreenSize(context, 343),
        child: FlatButton(
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: isSignUp ? SignUpScreen() : LoginScreen()));
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(35.0)),
          child: Text(
            isSignUp ? 'SIGN UP' : 'LOG IN',
            style:
                isSignUp ? AppStyle.style14BoldWhite : AppStyle.style14BoldRed,
          ),
        ),
      ),
    );
  }
}
