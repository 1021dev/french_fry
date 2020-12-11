import 'dart:async';
import 'package:flutter/material.dart';
import 'package:french_fry/utils/app_color.dart';

class ShowErrorPopup extends StatelessWidget {
  final Function() onYes;
  final String errorText;
  final BuildContext contextLanguage;

  ShowErrorPopup(
      {Key key,
      @required this.onYes,
      @required this.errorText,
      @required this.contextLanguage})
      : super(key: key);

  bool isTap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(0.0),
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaleFactor: 1.0),
                        child: Text(
                          "ALERT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 15, bottom: 0),
                      child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaleFactor: 1.0),
                        child: Text(
                          errorText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      bottom: false,
                      child: Container(
                        padding: EdgeInsets.only(top: 40, bottom: 30),
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 44,
                          width: 155,
                          decoration: BoxDecoration(
                            color: AppColor.redColor,
                            borderRadius: new BorderRadius.circular(22.0),
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
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(22.0)),
                            padding: EdgeInsets.all(0),
                            child: MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaleFactor: 1.0),
                              child: Text(
                                "OK",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (isTap) {
                              } else {
                                isTap = true;
                                Future.delayed(Duration(seconds: 1))
                                    .then((value) {
                                  isTap = false;
                                });
                                var name = ModalRoute.of(contextLanguage)
                                    .settings
                                    .name;
                                if (name == null) {
                                  Navigator.of(contextLanguage).pop();
                                } else {
                                  Navigator.of(contextLanguage).popUntil(
                                      ModalRoute.withName(name.contains("/")
                                          ? name
                                          : "/${name.toString()}"));
                                }
                                onYes();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }
}
