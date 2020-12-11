import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rxdart/subjects.dart';

class BackDrop extends StatefulWidget {
  final BehaviorSubject<double> distanceFromSide;
  final BehaviorSubject<int> index;

  final Widget backLayer;
  final Widget frontLayerPanel;
  final Widget frontLayerHeader;

  BackDrop({
    this.distanceFromSide,
    this.index,
    this.frontLayerHeader,
    this.frontLayerPanel,
    this.backLayer,
  });

  @override
  _BackdropState createState() {
    return _BackdropState();
  }
}

class _BackdropState extends State<BackDrop> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.index,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
          return _builddismissibleBody(context);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _builddismissibleBody(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            child: widget.backLayer,
            margin: EdgeInsets.symmetric(
                horizontal: widget.distanceFromSide.value <= 0
                    ? 0
                    : widget.distanceFromSide.value),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(250, 141, 53, 0.5),
                blurRadius: 16.0,
                spreadRadius: 1.0,
                offset: Offset(
                  8.0,
                  8.0,
                ),
              ),
            ]),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SizedBox.shrink(),
              ),
              _buildFrontWidget()
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrontWidget() {
    return widget.frontLayerHeader;
  }
}
