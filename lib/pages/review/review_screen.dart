import 'package:bflutter/bflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:french_fry/models/remote/restaurant_model.dart';
import 'package:french_fry/pages/review/review_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ReviewScreen extends StatefulWidget {
  List<RestaurantModel> listRestaurants;
  Function(List<RestaurantModel>) onReviewAction;
  ReviewScreen(
      {Key key, @required this.listRestaurants, @required this.onReviewAction})
      : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = ReviewBloc();
  bool isYes = true;
  bool isFirst = true;
  ScrollController mainController = ScrollController();
  List<RestaurantModel> listYes = List<RestaurantModel>();
  List<RestaurantModel> listNo = List<RestaurantModel>();

  @override
  void initState() {
    super.initState();

    listYes = (widget.listRestaurants
        .where((i) => i.isLike != null && i.isLike && i.isSwipe)
        .toList());
    listNo = (widget.listRestaurants
        .where((i) => i.isLike != null && !i.isLike && i.isSwipe)
        .toList());
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      bloc.reloadBloc.push(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.reloadBloc.stream,
      builder: (context, data) {
        return Scaffold(
          backgroundColor: AppColor.bgColor,
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
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: 68,
        margin: EdgeInsets.only(top: 0, left: 12, right: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(0),
              height: 68,
              width: (MediaQuery.of(context).size.width - 24) / 2,
              alignment: Alignment.center,
              child: Container(
                height: 44,
                margin: EdgeInsets.only(left: 4, right: 4),
                width: (MediaQuery.of(context).size.width - 24) / 2 - 8,
                decoration: BoxDecoration(
                  color: isYes ? AppColor.redColor : Colors.white,
                  borderRadius: new BorderRadius.circular(12.0),
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
                  padding: EdgeInsets.all(0.0),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  onPressed: () {
                    isYes = true;
                    bloc.reloadBloc.push(true);
                    mainController.animateTo(
                      0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 550),
                    );
                  },
                  child: Text(
                    'YES',
                    style: isYes
                        ? AppStyle.style14BoldWhite
                        : AppStyle.style14BoldRed,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(0),
              height: 68,
              alignment: Alignment.center,
              child: Container(
                height: 44,
                margin: EdgeInsets.only(left: 4, right: 4),
                width: (MediaQuery.of(context).size.width - 24) / 2 - 8,
                decoration: BoxDecoration(
                  color: isYes ? Colors.white : AppColor.redColor,
                  borderRadius: new BorderRadius.circular(12.0),
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
                  padding: EdgeInsets.all(0.0),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  onPressed: () {
                    isYes = false;
                    bloc.reloadBloc.push(true);
                    mainController.animateTo(
                      MediaQuery.of(context).size.width,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 550),
                    );
                  },
                  child: Text(
                    'NO',
                    style: isYes
                        ? AppStyle.style14BoldRed
                        : AppStyle.style14BoldWhite,
                  ),
                ),
              ),
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
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: new NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                controller: mainController,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).padding.bottom +
                                16 +
                                56),
                        itemCount: listYes.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildItem(context, listYes[index], index);
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).padding.bottom +
                                16 +
                                56),
                        itemCount: listNo.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildItem(context, listNo[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              bottom: true,
              child: _buildSwipeButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, RestaurantModel item, int index) {
    String categoryString = '';
    for (var it in item.categories) {
      if (categoryString == '') {
        categoryString = it.title;
      } else {
        categoryString += ', ${it.title}';
      }
    }
    var contain = Container(
      height: 128,
      margin: EdgeInsets.only(
          left: 16, right: 16, bottom: 12, top: index == 0 ? 12 : 0),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(24.0),
        ),
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
        onPressed: () {
          FocusScope.of(context).unfocus();
          
          if (item.isLike) {
            isYes = false;
            isFirst = false;
            mainController.animateTo(
              MediaQuery.of(context).size.width,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 250),
            );
            item.isLike = false;
            listNo.add(item);
            listYes.removeAt(index);
          } else {
            isYes = true;
            isFirst = false;
            mainController.animateTo(
              0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 250),
            );
            item.isLike = true;
            listYes.add(item);
            listNo.removeAt(index);
          }
          bloc.reloadBloc.push(true);
        },
        padding: EdgeInsets.all(0.0),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(24.0),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 32,
                  margin: EdgeInsets.only(left: 20, right: 38, top: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.style20RegularGrey,
                  ),
                ),
                Container(
                  height: 25,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 6),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    categoryString,
                    style: AppStyle.style15MediumBlack60,
                  ),
                ),
                Container(
                  height: 28,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Row(
                    children: <Widget>[
                      //STAR
                      Expanded(
                        child: Container(
                          height: 25,
                          margin: EdgeInsets.only(left: 0),
                          alignment: Alignment.centerLeft,
                          child: SmoothStarRating(
                              allowHalfRating: false,
                              onRatingChanged: (v) {},
                              starCount: 5,
                              rating: item.rating ?? 5,
                              size: 25.0,
                              color: AppColor.bgColor,
                              borderColor: Colors.grey,
                              spacing: 0.0),
                        ),
                      ),

                      Container(
                        height: 28,
                        width: 64,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 0, right: 0),
                        decoration: BoxDecoration(
                            color: AppColor.bgColor.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Text(
                          item.price ?? '', //'\$\$\$',
                          style: AppStyle.style14RegularRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //CHECK
            Container(
              height: 24,
              width: 24,
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 16, right: 16),
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color:
                          item.isLike ? AppColor.redColor : AppColor.bgColor),
                  color: item.isLike
                      ? AppColor.redColor
                      : AppColor.bgColor.withOpacity(0.6),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: item.isLike
                  ? Image.asset(AppImages.icCheckWhite,
                      width: 29 / 2, height: 21 / 2)
                  : Container(),
            ),
          ],
        ),
      ),
    );
    return isFirst
        ? contain
        : AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 600),
            child: SlideAnimation(
              horizontalOffset: item.isLike
                  ? MediaQuery.of(context).size.width
                  : -MediaQuery.of(context).size.width,
              child: FadeInAnimation(
                child: contain,
              ),
            ),
          );
  }

  void checkListYesNo() {
    for (var i = 0; i < widget.listRestaurants.length; i++) {
      for (var j = 0; j < listYes.length; j++) {
        if (listYes[j].id == widget.listRestaurants[i].id &&
            listYes[j].name == widget.listRestaurants[i].name &&
            widget.listRestaurants[i].isSwipe && widget.listRestaurants[i].isLike != null) {
          widget.listRestaurants[i].isLike = true;
          widget.listRestaurants[i].like += 1;
          widget.listRestaurants[i].dislike -= 1;
        }
      }
    }

    for (var i = 0; i < widget.listRestaurants.length; i++) {
      for (var k = 0; k < listNo.length; k++) {
        if (listNo[k].id == widget.listRestaurants[i].id &&
            listNo[k].name == widget.listRestaurants[i].name &&
            widget.listRestaurants[i].isSwipe && widget.listRestaurants[i].isLike != null) {
          widget.listRestaurants[i].isLike = false;
          widget.listRestaurants[i].like -= 1;
          widget.listRestaurants[i].dislike += 1;
        }
      }
    }
  }

  Widget _buildSwipeButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
      height: 56,
      padding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.all(Radius.circular(28)),
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
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width - 32,
        margin: EdgeInsets.all(0.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.all(Radius.circular(28)),
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
          onPressed: () {
            checkListYesNo();
            widget.onReviewAction(widget.listRestaurants);
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(28.0),
          ),
          child: Text(
            'CONTINUE SWIPING',
            style: AppStyle.style14BoldRed,
          ),
        ),
      ),
    );
  }
}
