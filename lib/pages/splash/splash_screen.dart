import 'package:bflutter/provider/main_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/pages/congratulation/congratulation_screen.dart';
import 'package:french_fry/pages/home/home_screen.dart';
import 'package:french_fry/pages/signup/signup_profile/signup_profile_screen.dart';
import 'package:french_fry/pages/swipe/swipe_screen.dart';
import 'package:french_fry/pages/welcome/welcome_screen.dart';
import 'package:french_fry/utils/app_helper.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final mainBloc = MainBloc.instance;
  BuildContext contextNo;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500)).then((value) {
      checkAuth(context);
    });
  }

  void checkAuth(BuildContext context) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    mainBloc.navigateReplace(currentUser != null ? HomeScreen(user: currentUser) : WelcomeScreen());
    // mainBloc.navigateReplace(currentUser != null ? SignUpProfileScreen() : WelcomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    contextNo = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.all(0.0),
      ),
    );
  }
}
