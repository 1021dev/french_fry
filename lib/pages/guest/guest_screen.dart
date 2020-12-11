import 'package:bflutter/bflutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/pages/guest/guest_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_style.dart';

class GuestScreen extends StatefulWidget {
  List<User> listGuests = [];
  GuestScreen({Key key, @required this.listGuests}) : super(key: key);

  @override
  _GuestScreenState createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = GuestBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.redColor,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: GestureDetector(
          child: Column(
            children: <Widget>[
              Hero(tag: 'BODY_HOME', child: _buildHeader(context)),
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
              child: Text('Guests', style: AppStyle.style16RegularWhite),
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
                topLeft: Radius.circular(28), topRight: Radius.circular(28))),
        child: ClipRRect(
          borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          child: Container(
            margin: EdgeInsets.only(top: 0, bottom: 16),
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.listGuests.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItemEvent(
                      context, widget.listGuests[index], index);
                }),
          ),
        ),
      ),
    );
  }

  Widget _buildItemEvent(BuildContext context, User item, int index) {
    return Container(
      margin: EdgeInsets.only(
          top: index == 0 ? 16.0 : 0, left: 16.0, bottom: 16.0, right: 16),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
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
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                    color: index == 0 ? AppColor.redColor : Colors.white,
                    width: 1)),
            child: Hero(
                tag: item.uid + index.toString(),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    Center(
                      child: (item.avatarUrl ?? '') == '' ? Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                        
                      ) : Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: item.avatarUrl ?? '',
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    index == 0
                        ? Container(
                            margin: EdgeInsets.only(right: 0, top: 0),
                            width: 14,
                            height: 14,
                            child: Image.asset(AppImages.icStarGuest,
                                width: 14, height: 14),
                          )
                        : Container(),
                  ],
                ),
              
            ),
          ),

          //NAME
          Expanded(
            child: Container(
              height: 64,
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: index == 0
                  ? Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 0, top: 12, right: 0),
                          height: 24,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item?.username ?? (item?.phone ?? ''),
                            textAlign: TextAlign.left,
                            style: AppStyle.style16RegularGrey,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 0,
                            top: 0,
                          ),
                          alignment: Alignment.centerLeft,
                          height: 16,
                          child: Text(
                            'Hosting',
                            textAlign: TextAlign.left,
                            style: AppStyle.style12RegularRed,
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    )
                  : Container(
                      margin: EdgeInsets.only(left: 0, right: 0),
                      height: 24,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item?.username ?? (item?.phone ?? ''),
                        style: AppStyle.style16RegularGrey,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
