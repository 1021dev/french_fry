
import 'package:bflutter/bflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/pages/home/home_screen.dart';
import 'package:french_fry/pages/swipe_success/swipe_success_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';

class SwipeSuccessScreen extends StatefulWidget {
  SwipeSuccessScreen({Key key}) : super(key: key);

  @override
  _SwipeSuccessScreenState createState() => _SwipeSuccessScreenState();
}

class _SwipeSuccessScreenState extends State<SwipeSuccessScreen> {
  var bloc = SwipeSuccessBloc();
  var mainBloc = MainBloc.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: AppHelper.getHeightFromScreenSize(context, 114),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 0, top: 0),
                width: AppHelper.getWidthFromScreenSize(context, 326),
                height:
                    AppHelper.getWidthFromScreenSize(context, 326) * 240 / 326,
                alignment: Alignment.topCenter,
                child: Image.asset(
                  AppImages.icLogoSuccess,
                  width: AppHelper.getWidthFromScreenSize(context, 326),
                  height: AppHelper.getWidthFromScreenSize(context, 326) *
                      240 /
                      326,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 12),
                height: 64,
                alignment: Alignment.topCenter,
                child: Text(
                  'Thanks for swiping!',
                  style: AppStyle.style29MediumRed,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: AppHelper.getHeightFromScreenSize(context, 16),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 0, top: 0),
                alignment: Alignment.topCenter,
                child: Text(
                  'We will notify you after all guests finish\ntheir selection or deadline has been\nreached.',
                  style: AppStyle.style14RegularGreyHeight,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(child: Container()),
              _buildFinishButton(context),
            ],
          ),
        ),
      ),
    );
  }

//BUTTON
  Widget _buildFinishButton(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
        height: 72,
        padding: EdgeInsets.all(0.0),
        alignment: Alignment.bottomCenter,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.all(Radius.circular(36)),
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
          height: 72,
          width: MediaQuery.of(context).size.width - 32,
          margin: EdgeInsets.all(0.0),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(Radius.circular(36)),
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
            onPressed: () async {
              final currentUser = await FirebaseAuth.instance.currentUser();
              FocusScope.of(context).unfocus();
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => HomeScreen(user: currentUser,)));
            },
            padding: EdgeInsets.all(0.0),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(36.0),
            ),
            child: Text(
              'RETURN HOME',
              style: AppStyle.style14BoldRed,
            ),
          ),
        ),
      ),
    );
  }
}
