import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:french_fry/utils/app_style.dart';

class NotificationPopup extends StatefulWidget {
  final Function() onYes;
  final String errorText;
  final BuildContext contextLanguage;
  NotificationPopup(
      {Key key,
      @required this.onYes,
      @required this.errorText,
      @required this.contextLanguage})
      : super(key: key);

  @override
  _NotificationPopupState createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup> {
  bool isTap = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HapticFeedback.vibrate();
    Future.delayed(Duration(seconds: 4)).then((value) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.0),
      body: GestureDetector(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SafeArea(
            top: true,
            bottom: false,
            child: Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.all(0.0),
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 10),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 16),
                      alignment: Alignment.centerLeft,
                      width: 45,
                      height: 45,
                      child: Image.asset(
                        'assets/base/icons/FrenchFry_Icon_Yellow.png',
                        width: 45,
                        height: 45,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        alignment: Alignment.centerLeft,
                        child: MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaleFactor: 1.0),
                          child: Text(
                            widget.errorText,
                            textAlign: TextAlign.left,
                            style: AppStyle.style14RegularGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          if (isTap) {
          } else {
            isTap = true;
            Future.delayed(Duration(seconds: 1)).then((value) {
              isTap = false;
            });
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
