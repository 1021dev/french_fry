import 'package:bflutter/bflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/pages/home/home_screen.dart';
import 'package:french_fry/pages/signup/signup_profile/signup_profile_screen.dart';
import 'package:french_fry/provider/store/remote/auth_api.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:page_transition/page_transition.dart';

class SignUpCodeBloc with AppBloc {
  final usernameInput = Bloc<String, bool>();
  final validInput = BlocDefault<bool>();
  final signUpTrigger = BlocDefault<bool>();

  final authApi = AuthApi();
  final mainBloc = MainBloc.instance;
  var firebaseAuth = FirebaseAuth.instance;
  BuildContext context;
  static BuildContext contextPopup;

  SignUpCodeBloc() {
    initLogic();
  }

  @override
  void initLogic() {
    // Logic check not empty
    usernameInput.logic = (input) => input.map((d) => d.isNotEmpty);
  }

  void checkInput(BuildContext context, String str) {
    validInput.push(str.length > 0);
  }

  void checkConfirmOTP(BuildContext context, String first, String second,
      String third, String four, String five, String six, bool isLogin,
      {String actualCode}) async {
    this.context = context;
    contextPopup = context;
    if (first.replaceAll(' ', '').isEmpty ||
        second.replaceAll(' ', '').isEmpty ||
        third.replaceAll(' ', '').isEmpty ||
        four.replaceAll(' ', '').isEmpty ||
        five.replaceAll(' ', '').isEmpty ||
        six.replaceAll(' ', '').isEmpty) {
      return;
    }
    String smsCode = first.replaceAll(' ', '') +
        second.replaceAll(' ', '') +
        third.replaceAll(' ', '') +
        four.replaceAll(' ', '') +
        five.replaceAll(' ', '') +
        six.replaceAll(' ', '');
    var auth = PhoneAuthProvider.getCredential(
        verificationId: actualCode, smsCode: smsCode);
    firebaseAuth.signInWithCredential(auth).catchError((error) {
      AppHelper.showMyDialog(
          contextPopup, 'Something has gone wrong, please try later');
    }).then((AuthResult value) async {
      if (value.user != null) {
        print('Authentication successful');
        // if (isLogin || (value?.user?.displayName ?? '').length > 0) {
        if ((value?.user?.displayName ?? '').length > 0) {
          //CHANGE 29-05-2020
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                user: value.user,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: SignUpProfileScreen(authUser: value.user),
            ),
          );
        }
      } else {
        AppHelper.showMyDialog(
            contextPopup, 'Invalid code/invalid authentication');
      }
    });
  }

  //ACTION PHONE
  void checkPhoneSignUp(BuildContext context, String phone) async {
    this.context = context;
    contextPopup = context;
    validInput.push(false);
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  final PhoneCodeSent codeSent =
      (String verificationId, [int forceResendingToken]) async {
    print("verificationId : ${verificationId}");
  };

  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
      (String verificationId) {
    AppHelper.showMyDialog(contextPopup, 'Auto retrieval time out');
  };
  final PhoneVerificationFailed verificationFailed =
      (AuthException authException) {
    if (authException.message.contains('not authorized'))
      AppHelper.showMyDialog(
          contextPopup, 'Something has gone wrong, please try later');
    else if (authException.message.contains('Network'))
      AppHelper.showMyDialog(
          contextPopup, 'Please check your internet connection and try again');
    else
      AppHelper.showMyDialog(contextPopup, '${authException.message}');
  };

  PhoneVerificationCompleted verificationCompleted = (AuthCredential auth) {
    FirebaseAuth.instance.signInWithCredential(auth).then((AuthResult value) {
      if (value.user != null) {
        print('Authentication successful');
      } else {
        AppHelper.showMyDialog(
            contextPopup, 'Invalid code/invalid authentication');
      }
    }).catchError((error) {
      AppHelper.showMyDialog(contextPopup, '${error.message}');
    });
  };

  @override
  void dispose() {
    usernameInput.dispose();
    signUpTrigger.dispose();
    validInput.dispose();
  }
}
