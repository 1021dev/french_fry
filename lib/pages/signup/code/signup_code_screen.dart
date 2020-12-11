import 'package:bflutter/bflutter.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/pages/signup/code/signup_code_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';

class SignUpCodeScreen extends StatefulWidget {
  String phone = '';
  String actualCode = '';
  bool isLogin = false;
  SignUpCodeScreen({Key key, @required this.phone, @required this.actualCode , @required this.isLogin })
      : super(key: key);

  @override
  _SignUpCodeScreenState createState() => _SignUpCodeScreenState();
}

class _SignUpCodeScreenState extends State<SignUpCodeScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = SignUpCodeBloc();
  TextEditingController firstController = TextEditingController();
  TextEditingController secondController = TextEditingController();
  TextEditingController thirdController = TextEditingController();
  TextEditingController fourController = TextEditingController();
  TextEditingController fiveController = TextEditingController();
  TextEditingController sixController = TextEditingController();
  FocusNode focusFirst = FocusNode();
  FocusNode focusSecond = FocusNode();
  FocusNode focusThird = FocusNode();
  FocusNode focusFour = FocusNode();
  FocusNode focusFive = FocusNode();
  FocusNode focusSix = FocusNode();

  int index2 = 0;
  int index3 = 0;
  int index4 = 0;
  int index5 = 0;
  int index6 = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) {
      FocusScope.of(context).requestFocus(focusFirst);
    });
  }

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
                  widget.isLogin ? 'Log In' : 'Sign Up',
                  style: AppStyle.style24MediumRed,
                ),
              ),
              Container(
                height: 56,
                margin: EdgeInsets.only(
                  top: 16,
                ),
                alignment: Alignment.topCenter,
                child: Text(
                  'We sent you a 6 digit confirmation code.\nPlease enter it below.',
                  style: AppStyle.style14RegularGrey,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 32)),
              _buildCodeField(context),
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 36)),
              _buildResend(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(BuildContext context) {
    return Container(
        height: AppHelper.getWidthFromScreenSize(context, 50),
        alignment: Alignment.topCenter,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(context, firstController, focusFirst),
              _buildTextField(context, secondController, focusSecond),
              _buildTextField(context, thirdController, focusThird),
              _buildTextField(context, fourController, focusFour),
              _buildTextField(context, fiveController, focusFive),
              _buildTextField(context, sixController, focusSix),
            ],
          ),
        ));
  }

  Widget _buildTextField(
      BuildContext context, TextEditingController controller, FocusNode focus) {
    return Container(
      width: AppHelper.getWidthFromScreenSize(context, 50),
      height: AppHelper.getWidthFromScreenSize(context, 50),
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: new BorderRadius.all(Radius.circular(12)),
      ),
      child: TextField(
        focusNode: focus,
        style: AppStyle.style24RegularRed,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
          hintText: '-',
          hintStyle: AppStyle.style24RegularRed,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        controller: controller,
        obscureText: false,
        onChanged: (text) {
          if (text.replaceAll(' ', '').length == 6) {
            //RECEIVE CODE FROM SMS
            var code = text.replaceAll(' ', '');
            firstController.text = code[0];
            secondController.text = code[1];
            thirdController.text = code[2];
            fourController.text = code[3];
            fiveController.text = code[4];
            sixController.text = code[5];

            index2 = 1;
            index3 = 1;
            index4 = 1;
            index5 = 1;
            index6 = 1;
            //CALL API
            FocusScope.of(context).unfocus();
            bloc.checkConfirmOTP(
                context,
                firstController.text,
                secondController.text,
                thirdController.text,
                fourController.text,
                fiveController.text,
                sixController.text,
                widget.isLogin,
                actualCode: widget.actualCode);
          } else {
            checkInput(context, text, controller);
          }
        },
      ),
    );
  }

  void checkInput(
      BuildContext context, String code, TextEditingController controller) {
    if (code.length > 1) {
      if (code[0] == ' ') {
        controller.text = code[1];
      } else {
        controller.text = code[0];
      }
    }
    if (controller == firstController) {
      if (code.length > 0) {
        FocusScope.of(context).requestFocus(focusSecond);
      }
    } else if (controller == secondController) {
      if (code.length > 0) {
        index2 = 1;
        FocusScope.of(context).requestFocus(focusThird);
      } else {
        if (index2 <= 0) {
          controller.text = '';
          FocusScope.of(context).requestFocus(focusFirst);
        } else {
          controller.text = ' ';
          index2 -= 1;
        }
      }
    } else if (controller == thirdController) {
      if (code.length > 0) {
        index3 = 1;
        FocusScope.of(context).requestFocus(focusFour);
      } else {
        if (index3 <= 0) {
          controller.text = '';
          FocusScope.of(context).requestFocus(focusSecond);
        } else {
          controller.text = ' ';
          index3 -= 1;
        }
      }
    } else if (controller == fourController) {
      if (code.length > 0) {
        index4 = 1;
        FocusScope.of(context).requestFocus(focusFive);
      } else {
        if (index4 <= 0) {
          controller.text = '';
          FocusScope.of(context).requestFocus(focusThird);
        } else {
          controller.text = ' ';
          index4 -= 1;
        }
      }
    } else if (controller == fiveController) {
      if (code.length > 0) {
        index5 = 1;
        FocusScope.of(context).requestFocus(focusSix);
      } else {
        if (index5 <= 0) {
          controller.text = '';
          FocusScope.of(context).requestFocus(focusFour);
        } else {
          controller.text = ' ';
          index5 -= 1;
        }
      }
    } else if (controller == sixController) {
      if (code.length > 0) {
        index6 = 1;
        FocusScope.of(context).unfocus();
        bloc.checkConfirmOTP(
            context,
            firstController.text,
            secondController.text,
            thirdController.text,
            fourController.text,
            fiveController.text,
            code[0],
            widget.isLogin,
            actualCode: widget.actualCode);
      } else {
        if (index6 <= 0) {
          controller.text = '';
          FocusScope.of(context).requestFocus(focusFive);
        } else {
          controller.text = ' ';
          index6 -= 1;
        }
      }
    }
  }

  Widget _buildResend(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: 28,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Didn\'t receive a code?',
              style: AppStyle.style14RegularGrey,
            ),
            SizedBox(
              width: 5,
            ),
            InkWell(
              onTap: () {
                //RESEND CODE
                bloc.checkPhoneSignUp(context, widget.phone);
              },
              child: Text(
                'Resend',
                style: AppStyle.style14RegularRedUnderline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
