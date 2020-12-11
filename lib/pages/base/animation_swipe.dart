import 'dart:async';

import 'package:flutter/material.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';

class AnimationSwipe extends StatefulWidget {
  bool isLeft = false;
  AnimationSwipe({Key key, @required this.isLeft}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AnimationSwipeState();
}

class _AnimationSwipeState extends State<AnimationSwipe>
    with TickerProviderStateMixin {
  AnimationController animation;
  Animation<double> _fadeInFadeOut;
  double sizeWidth = 140;
  double sizeBigWidth = 160;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeInFadeOut = Tween<double>(begin: 0.2, end: 1.4).animate(animation);
    /*_offsetAnimation = Tween<Offset>(
      begin: Offset(widget.isLeft ? (-1.0) : (1.0), 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
    ));*/

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animation.forward();
      }
    });
    animation.forward();

    Future.delayed(Duration(milliseconds: 300)).then((value) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 1), () {
      setState(() {
        sizeWidth = 180;
        sizeBigWidth = 200;
      });
    });
    return
        /*
    SlideTransition(
                position: _offsetAnimation,
                child:*/
        Container(
      child: AnimatedSize(
        vsync: this,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: Container(
          child: Container(
            child: FadeTransition(
              opacity: _fadeInFadeOut,
              child: _buildLeftRight(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftRight(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AnimatedContainer(
        width: widget.isLeft ? sizeBigWidth : sizeWidth,
        height: widget.isLeft ? sizeBigWidth : sizeWidth,
        duration: Duration(milliseconds: 300),
        alignment: Alignment.center,
        child: !widget.isLeft
            ? Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  AnimatedContainer(
                    width: sizeWidth,
                    height: sizeWidth,
                    duration: Duration(milliseconds: 250),
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppImages.icCircleShadow,
                      color: AppColor.bgColor,
                      width: 180,
                      height: 180,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15),
                    width: 89 / 2,
                    height: 66 / 2,
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppImages.icButtonCheckRed,
                      width: 89 / 2,
                      height: 66 / 2,
                    ),
                  ),
                ],
              )
            : AnimatedContainer(
                width: sizeBigWidth,
                height: sizeBigWidth,
                duration: Duration(milliseconds: 250),
                alignment: Alignment.center,
                child: Image.asset(
                  AppImages.icCloseButton,
                  width: 200,
                  height: 200,
                ),
              ),
      ),
    );
  }
}
