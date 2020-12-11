import 'package:bflutter/bflutter.dart';
// import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/main.dart';
import 'package:french_fry/pages/join_event/join_event_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import 'package:qrcode/qrcode.dart';

class JoinEventScreen extends StatefulWidget {
  JoinEventScreen({Key key}) : super(key: key);

  @override
  _JoinEventScreenState createState() => _JoinEventScreenState();
}

class _JoinEventScreenState extends State<JoinEventScreen>
    with SingleTickerProviderStateMixin {
  final mainBloc = MainBloc.instance;
  final bloc = JoinEventBloc();
  QRCaptureController _captureController = QRCaptureController();
  TextEditingController firstController = TextEditingController(text: '');
  TextEditingController secondController = TextEditingController(text: '');
  TextEditingController thirdController = TextEditingController(text: '');
  TextEditingController fourController = TextEditingController(text: '');
  FocusNode focusFirst = FocusNode();
  FocusNode focusSecond = FocusNode();
  FocusNode focusThird = FocusNode();
  FocusNode focusFour = FocusNode();
  int index2 = 0;
  int index3 = 0;
  int index4 = 0;
  BuildContext contextx;
  AnimationController _controller;
  Animation<double> animation;
  bool isShowCamera = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0, 0, 0.2, 1),
      reverseCurve: const Cubic(0, 0, 1, 0.2),
    );

    _captureController.onCapture((data) {
      if (data.length > 0) {
        print('onCapture----$data');
        if (data.replaceAll(' ', '').length == 4 && isNumeric(data)) {
          _captureController.pause();
          firstController.text = data[0];
          secondController.text = data[1];
          thirdController.text = data[2];
          fourController.text = data[3];

          index2 = 1;
          index3 = 1;
          index4 = 1;
          //CALL API
          // AppHelper.showToaster('Code: $data', contextx);
          FocusScope.of(context).unfocus();
          Future.delayed(Duration(milliseconds: 1000)).then((val) {
            bloc.checkQR(
              context,
              firstController.text,
              secondController.text,
              thirdController.text,
              fourController.text,
            );
          });
        } else {
          _captureController.pause();
          FocusScope.of(context).unfocus();
          AppHelper.showToaster('Invalid code.', contextx);
          Future.delayed(Duration(milliseconds: 1500)).then((val) {
            _captureController.resume();
          });
        }
      }
    });

    eventBus.on().listen((data) {
      if (data == AppConstant.kBackDetailEvent) {
        _captureController.resume();
      }
    });

    Future.delayed(Duration(milliseconds: 300)).then((val) {
      // permissionRequest(contextx);
      isShowCamera = true;
      bloc.reloadBloc.push(true);
    });
  }

  // void permissionRequest(BuildContext context) async {
  //   final permissionValidator = EasyPermissionValidator(
  //     context: context,
  //     appName: 'FrenchFry',
  //     appNameColor: AppColor.redColor,
  //     cancelText: 'Cancel',
  //     enableLocationMessage:
  //         'You must enable the camera permission to use the action',
  //     goToSettingsText: 'Go Settings',
  //     permissionSettingsMessage:
  //         'You must enable the camera permission for the app to work properly',
  //   );
  //   permissionValidator.camera().then((value) {
  //     if (value) {
  //       isShowCamera = true;
  //     } else {
  //       isShowCamera = false;
  //     }
  //     bloc.reloadBloc.push(true);
  //   }).catchError((error) {
  //     print(error.toString());
  //     isShowCamera = false;
  //     bloc.reloadBloc.push(true);
  //   });
  // }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    contextx = context;
    return StreamBuilder(
      stream: bloc.reloadBloc.stream,
      builder: (context, data) {
        return Scaffold(
          backgroundColor: AppColor.redColor,
          body: StreamBuilder(
            stream: bloc.loading.stream,
            builder: (context, AsyncSnapshot<bool> loading) {
              return Stack(
                children: <Widget>[
                  FooterLayout(
                    footer: KeyboardAttachable(
                      backgroundColor: AppColor.bgColor,
                      child: Container(color: AppColor.bgColor),
                    ),
                    child: MediaQuery(
                      data:
                          MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: GestureDetector(
                        child: Column(
                          children: <Widget>[
                            Hero(
                                tag: 'BODY_HOME', child: _buildHeader(context)),
                            _buildBody(context),
                          ],
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  AppHelper.buildLoading(loading.data ?? false),
                ],
              );
            },
          ),
        );
      },
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
        child: Row(
          children: <Widget>[
            Container(
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
                child: Image.asset(AppImages.icBackWhite, width: 9, height: 16),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 0),
              child: Text('Join Event', style: AppStyle.style16RegularWhite),
            ),
          ],
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
                topLeft: Radius.circular(44), topRight: Radius.circular(44))),
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: new BorderRadius.only(
                topLeft: Radius.circular(44), topRight: Radius.circular(44)),
            child: Column(
              children: <Widget>[
                SizedBox(
                    height: AppHelper.getHeightFromScreenSize(context, 44)),
                Container(
                  height: 32,
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Scan QR Code',
                    style: AppStyle.style24MediumRed,
                  ),
                ),
                SizedBox(
                    height: AppHelper.getHeightFromScreenSize(context, 28)),
                Container(
                  margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 592 / 750,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(28.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(28.0)),
                    child: Stack(
                      children: <Widget>[
                        isShowCamera
                            ? Container(
                                margin: EdgeInsets.all(0.0),
                                child: QRCaptureView(
                                    controller: _captureController),
                              )
                            : Container(),
                        Container(
                          margin: EdgeInsets.all(0.0),
                          child: Image.asset(
                            AppImages.icQR,
                            width: MediaQuery.of(context).size.width,
                            height:
                                MediaQuery.of(context).size.width * 592 / 750,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: AppHelper.getHeightFromScreenSize(context, 28),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: AppHelper.getHeightFromScreenSize(context, 16),
                  ),
                  alignment: Alignment.center,
                  height: 56,
                  child: Text(
                    'Don\'t have a QR? Enter code\nmanually here.',
                    textAlign: TextAlign.center,
                    style: AppStyle.style14RegularGreyHeight,
                  ),
                ),
                SizedBox(
                  height: AppHelper.getHeightFromScreenSize(context, 16),
                ),
                _buildCodeField(context),
                SizedBox(
                  height: AppHelper.getHeightFromScreenSize(context, 26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(BuildContext context) {
    return Container(
      height: AppHelper.getWidthFromScreenSize(context, 56),
      alignment: Alignment.topCenter,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTextField(context, firstController, focusFirst),
            _buildTextField(context, secondController, focusSecond),
            _buildTextField(context, thirdController, focusThird),
            _buildTextField(context, fourController, focusFour),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, TextEditingController controller, FocusNode focus) {
    return Container(
      width: AppHelper.getWidthFromScreenSize(context, 56),
      height: AppHelper.getWidthFromScreenSize(context, 56),
      margin: EdgeInsets.symmetric(
          horizontal: AppHelper.getWidthFromScreenSize(context, 6),
          vertical: 0),
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        color: controller.text.replaceAll(" ", "").length > 0
            ? Colors.white
            : Colors.white.withOpacity(0.6),
        borderRadius: new BorderRadius.all(Radius.circular(12)),
      ),
      child: TextField(
        focusNode: focus,
        enabled: true,
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
          checkInput(context, text, controller);
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
        secondController.text = ' ';
      }
    } else if (controller == secondController) {
      if (code.length > 0) {
        index2 = 1;
        FocusScope.of(context).requestFocus(focusThird);
        thirdController.text = ' ';
      } else {
        if (index2 <= 0) {
          // controller.text = '';
          FocusScope.of(context).requestFocus(focusFirst);
          if (firstController.text.replaceAll(' ', '') == '') {
            firstController.text = ' ';
          }
        } else {
          controller.text = ' ';
          index2 -= 1;
        }
      }
    } else if (controller == thirdController) {
      if (code.length > 0) {
        index3 = 1;
        FocusScope.of(context).requestFocus(focusFour);
        fourController.text = ' ';
        index2 -= 1;
      } else {
        if (index3 <= 0) {
          // controller.text = '';
          FocusScope.of(context).requestFocus(focusSecond);
          if (secondController.text.replaceAll(' ', '') == '') {
            secondController.text = ' ';
          }
        } else {
          controller.text = ' ';
          index3 -= 1;
        }
      }
    } else if (controller == fourController) {
      if (code.length > 0) {
        index4 = 1;
        FocusScope.of(context).unfocus();
        Future.delayed(Duration(milliseconds: 1200)).then((val) {
          bloc.checkQR(context, firstController.text, secondController.text,
              thirdController.text, fourController.text);
        });
      } else {
        if (index4 <= 0) {
          // controller.text = '';
          FocusScope.of(context).requestFocus(focusThird);
          if (thirdController.text.replaceAll(' ', '') == '') {
            thirdController.text = ' ';
          }
          index3 -= 1;
        } else {
          controller.text = ' ';
          index4 -= 1;
        }
      }
    }
    bloc.reloadBloc.push(true);
  }
}
