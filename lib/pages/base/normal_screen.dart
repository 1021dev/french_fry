

import 'package:bflutter/libs/pair.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/widgets/screen_widget.dart';
import 'package:french_fry/widgets/sns_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NormalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenWidget(
      body: Column(children: <Widget>[
        SnSIconAppBar(
          left: Pair(AppImages.icSearch, () {
          }),
          center: 'Home',
          right: Pair(AppImages.icNoti, () {
          }),
        ),
        Expanded(
          child: _body(),
        ),
      ]),
    );
  }

  Widget _body() {
    return Container();
  }
}
