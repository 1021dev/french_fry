import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/main.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/models/remote/request/notification_request.dart';
import 'package:french_fry/models/remote/restaurant_model.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/pages/review/review_screen.dart';
import 'package:french_fry/pages/swipe/swipable_list.dart';
import 'package:french_fry/pages/swipe/swipe_bloc.dart';
import 'package:french_fry/pages/swipe_success/swipe_success_screen.dart';
import 'package:french_fry/provider/store/remote/notification_api.dart';
import 'package:french_fry/provider/store/store.dart';
import 'package:french_fry/test_swipe.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:french_fry/widgets/transparent_route.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/subjects.dart';

class SwipeScreen extends StatefulWidget {
  EventRequest eventRequest;
  SwipeScreen({Key key, @required this.eventRequest}) : super(key: key);

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> with SingleTickerProviderStateMixin {
  var bloc = SwipeBloc();

  bool isTap = false;
  bool isPhoto = true;
  bool isYes = true;
  int temp = 0;
  bool isSwipe2 = false;
  BehaviorSubject<List<RestaurantModel>> subject = BehaviorSubject.seeded([]);
  BehaviorSubject<SwipeDirection> swipe = BehaviorSubject.seeded(null);
  List<RestaurantModel> filteredList = [];
  BuildContext contextNo;

  @override
  void initState() {
    super.initState();
    checkReloadFromPush(); // LOGIC REFRESH EVENT WHEN OPEN SCREEN
  }

  //CHECK RELOAD FROM PUSH NOTIFICATION
  void checkReloadFromPush() async {
    bloc.loading.push(true);
    final currentUser = await FirebaseAuth.instance.currentUser();
    final dbRef = Firestore.instance;
    var result = await dbRef.collection("events").getDocuments();
    for (var element in result.documents) {
      var item = EventRequest.fromJson(element.data);
      item.nameDB = element.documentID;
      item.isHost = item.host == currentUser.uid;
      if (item.codeQR == widget.eventRequest.codeQR && item.name == widget.eventRequest.name) {
        widget.eventRequest.swipes = item.swipes;
        if (item.nameDB.length > 0) {
          await DefaultStore.instance.saveEventDB(item.nameDB);
        }
        viewDidLoad();
        break;
      }
    }

    Future.delayed(Duration(seconds: 1)).then((value) {
      bloc.loading.push(false);
    });
  }

  //VIEW DID LOAD
  void viewDidLoad() {
    setState(() {
      filteredList =
          (widget.eventRequest?.restaurants ?? []).where((element) => !element.isSwipe).toList();

      subject.value = filteredList.isNotEmpty ? filteredList.take(5).toList().reversed.toList() : [];
      filteredList = filteredList.isNotEmpty
          ? filteredList.length >= 5
              ? filteredList.sublist(5)
              : filteredList.sublist(filteredList.length - 1)
          : [];
    });

    //CHECK LAST GUEST/HOST SWIPE TO PUSH ALL
    checkLastSwipeInGuest();

    Future.delayed(Duration(seconds: 1)).then((value) {
      bloc.reloadBLoc.push(true);
    });

    Future.delayed(Duration(seconds: 1)).then((value) {
      if (subject.value.length > 0) {
        bloc.getRestaurantFromIdBloc.push(subject.value.last.id);
      }
    });

    if (filteredList.length == 0) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        Navigator.of(contextNo).push(
          TransparentRoute(
            builder: (BuildContext context) => SwipeSuccessScreen(),
          ),
        );
      });
    }

    //RELOAD AFTER SWIPE
    eventBus.on().listen((event) {
      if (event == AppConstant.kReloadAfterSwipe) {
        if (subject.value.length > 0) {
          bloc.getRestaurantFromIdBloc.push(subject.value.last.id);
        }
      }
    });
  }

  //CHECK SWIPE LAST IN GUEST/HOST
  void checkLastSwipeInGuest() async {
    if (widget.eventRequest.guests.length > 0) {
      //Check guest > 0, push; because only host not push
      var filterSwipeRestaurant =
          widget.eventRequest.swipes.where((element) => element.restaurants.length > 0).toList();
      //check current user contain widget.eventRequest.swipes
      final currentUser = await FirebaseAuth.instance.currentUser();
      var filterCurrentUser =
          widget.eventRequest.swipes.where((element) => (element.user == currentUser.uid)).toList();
      var filterCurrentUserHost = widget.eventRequest.swipes
          .where((element) => (element.user == currentUser.uid && element.restaurants.length == 0))
          .toList();
      if (widget.eventRequest.guests.length == filterSwipeRestaurant.length &&
          (filterCurrentUser.length == 0 || filterCurrentUserHost.length == 1)) {
        widget.eventRequest.isLast = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    this.contextNo = context;
    var fullHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
      stream: bloc.reloadBLoc.stream,
      builder: (context, data) {
        return Scaffold(
          backgroundColor: AppColor.bgColor,
          body: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: fullHeight * (fullHeight > 700 ? .14 : .12),
                  left: 0.0,
                  right: 0.0,
                  height: fullHeight * .70,
                  child: Container(height: fullHeight * .7, child: _buildBody(context)),
                ),
                Container(
                  margin: EdgeInsets.all(0),
                  child: Column(
                    children: <Widget>[
                      SafeArea(
                        top: true,
                        bottom: false,
                        child: _buildHeader(context),
                      ),
                      Expanded(child: SizedBox.shrink()),
                      SafeArea(
                        bottom: true,
                        top: false,
                        child: _buildFinishButton(context),
                      ),
                    ],
                  ),
                ),
                _buildSwipeGuide(),
              ],
            ),
          ),
        );
      },
    );
  }

  StreamBuilder<bool> _buildSwipeGuide() {
    return StreamBuilder(
      stream: bloc.gotItBloc.stream,
      builder: (context, AsyncSnapshot<bool> data) {
        return !(data.data ?? false)
            ? Container(
                color: Colors.black.withOpacity(0.6),
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(left: 24, right: 24),
                  decoration: BoxDecoration(
                    color: AppColor.bgColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(44),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        blurRadius: 16.0,
                        spreadRadius: 1.0,
                        offset: Offset(
                          0.0,
                          8.0,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: AppHelper.getHeightFromScreenSize(context, 44),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        height: 64,
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Let\’s get you familiar\nwith swiping!',
                          style: AppStyle.style20MediumRed,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: AppHelper.getHeightFromScreenSize(context, 28),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 0, top: 0),
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Swipe right if you like a restaurant,\nand left if you don’t. Swipe up to see\nmore photos of the restaurant and\ntheir menu.',
                          style: AppStyle.style14RegularGrey,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: AppHelper.getHeightFromScreenSize(context, 45),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 0, top: 0),
                        width: AppHelper.getWidthFromScreenSize(context, 280),
                        height: AppHelper.getWidthFromScreenSize(context, 280) * 240 / 326,
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          AppImages.icCard,
                          width: AppHelper.getWidthFromScreenSize(context, 280),
                          height: AppHelper.getWidthFromScreenSize(context, 280) * 240 / 326,
                        ),
                      ),
                      SizedBox(
                        height: AppHelper.getHeightFromScreenSize(context, 40),
                      ),
                      _buildGotItButton(context),
                    ],
                  ),
                ),
              )
            : Container();
      },
    );
  }

  _handleOnSwipe(SwipeDirection direction, int index) {
    var temp = subject.value;
    temp.removeLast();
    if (filteredList.isNotEmpty) {
      temp.insert(0, filteredList.first);
      filteredList = filteredList.sublist(1);
    } else if (temp.isEmpty && filteredList.isEmpty) {
      saveDB(context);
      FocusScope.of(context).unfocus();
      Navigator.of(context).push(
        TransparentRoute(
          builder: (BuildContext context) => SwipeSuccessScreen(),
        ),
      );
    }
    setState(() {});
    if (direction == SwipeDirection.left) {
      _handleSwipeLeft(isTap: false);
    } else if (direction == SwipeDirection.right) {
      handleSwipeRight(isTab: false);
    }
  }

//HEADER
  Widget _buildHeader(BuildContext context) {
    List<RestaurantModel> listReviews = List<RestaurantModel>();
    for (RestaurantModel item in (widget.eventRequest?.restaurants ?? [])) {
      var filterDuplicate = listReviews.where((element) => element.id == item.id).toList();
      if (filterDuplicate.length == 0 && item.isSwipe) {
        listReviews.add(item);
      }
    }
    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
      alignment: Alignment.center,
      height: 96.0,
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        width: MediaQuery.of(context).size.width - 16,
        height: 96.0,
        child: Row(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 0, bottom: 0, left: 0),
                width: 96.0,
                height: 96.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(96.0 / 2),
                  child: Image.asset(
                    AppImages.icCloseButton,
                    width: 96.0,
                    height: 96.0,
                  ),
                  onTap: () {
                    swipe.add(SwipeDirection.left);
                  },
                )),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16.5, right: 16.5, top: 19),
                    height: 44,
                    width: MediaQuery.of(context).size.width - (96.0 * 2 + 16 + 16.5 * 2),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColor.redColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(21.5))),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(21.5),
                      onTap: handleReview,
                      child: Container(
                        margin: EdgeInsets.all(0.0),
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          listReviews.length > 0 ? 'REVIEW (${listReviews.length})' : 'REVIEW',
                          style: AppStyle.style14BoldRed,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 0, bottom: 0, left: 0),
              width: 96.0,
              height: 96.0,
              child: InkWell(
                borderRadius: BorderRadius.circular(96.0 / 2),
                child: Image.asset(
                  AppImages.icCheckButton,
                  width: 96.0,
                  height: 96.0,
                ),
                onTap: () {
                  swipe.add(SwipeDirection.right);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //BODY
  Widget _buildBody(BuildContext context) {
    bloc.initContext(context);
    return Container(
      child: StreamBuilder<List<RestaurantModel>>(
          stream: subject,
          builder: (context, list) {
            if (list.hasData && list.data != null) {
              return SwipeableList(
                  fullHeight: MediaQuery.of(context).size.height,
                  fullWidth: MediaQuery.of(context).size.width,
                  swipe: swipe,
                  stream: bloc.restaurantDetailBloc.stream,
                  isPhoto: isPhoto,
                  onImageTab: () {
                    isPhoto = true;
                    bloc.reloadBLoc.push(true);
                  },
                  items: subject,
                  onSwipe: _handleOnSwipe);
            } else {
              return SizedBox.shrink();
            }
          }),
    );
  }

  //REMOVE ITEM
  void removeItemSlidder(BuildContext context, RestaurantModel item, int index) async {
    item.isLike = isYes;
    item.isDislike = !isYes;
    // listReviews.add(item);
    for (var i = 0; i < widget.eventRequest.restaurants.length; i++) {
      if (widget.eventRequest.restaurants[i].id == item.id &&
          widget.eventRequest.restaurants[i].phone == item.phone) {
        if (item.isLike) {
          widget.eventRequest.restaurants[i].like = (widget.eventRequest.restaurants[i].like ?? 0) + 1;
        } else {
          widget.eventRequest.restaurants[i].dislike =
              (widget.eventRequest.restaurants[i].dislike ?? 0) + 1;
        }
      }
    }

    //Logic add id restaurant when swipe
    final currentUser = await FirebaseAuth.instance.currentUser();
    var filterHaveUser =
        widget.eventRequest.swipes.where((element) => element.user == currentUser.uid).toList();
    if (filterHaveUser.length > 0) {
      // USER HAVE IN SYSTEM
      for (var i = 0; i < widget.eventRequest.swipes.length; i++) {
        if (widget.eventRequest.swipes[i].user == currentUser.uid) {
          var model = SwipeRestaurantModel(isLike: item.isLike, restaurantId: item.id);
          widget.eventRequest.swipes[i].restaurants.add(model);
        }
      }
    } else {
      //USER NOT HAVE IN SYSTEM
      var model = SwipeRestaurantModel(isLike: item.isLike, restaurantId: item.id);
      widget.eventRequest.swipes.add(SwipeModel(user: currentUser.uid, restaurants: [model]));
    }
    widget.eventRequest.restaurants
        .where((element) => element.id == item.id && !element.isSwipe)
        .forEach((element) {
      element.isSwipe = true;
    });

    eventBus.fire(AppConstant.kReloadAfterSwipe);
    bloc.reloadBLoc.push(true);
  }

  //BUTTON
  Widget _buildFinishButton(BuildContext context) {
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
            if (widget.eventRequest.isLast) {
              //check last send push
              pushNotificationAllUser(context);
            }
            saveDB(context);
            FocusScope.of(context).unfocus();
            Navigator.of(context).push(
              TransparentRoute(
                builder: (BuildContext context) => SwipeSuccessScreen(),
              ),
            );
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(28.0),
          ),
          child: Text(
            'FINISH SWIPING',
            style: AppStyle.style14BoldRed,
          ),
        ),
      ),
    );
  }

  //PUSH NOTIFICATION ALL USER
  void pushNotificationAllUser(BuildContext context) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    List<String> listUserId = List<String>();
    listUserId.addAll(widget.eventRequest.guests);
    listUserId.add(widget.eventRequest.host);
    User host;
    List<User> listUsers = List<User>();
    final dbRef = Firestore.instance;
    var result = await dbRef.collection("users").getDocuments();
    for (var element in result.documents) {
      for (var item in listUserId) {
        if (element.data['uid'] == (item)) {
          var user = User.fromJson(element.data);
          if (user.uid == widget.eventRequest.host) {
            //check host
            host = user;
          }
          var filterDuplicate = listUsers.where((element) => element.uid == user.uid).toList();
          if (filterDuplicate.length == 0) {
            listUsers.add(user);
          }
        }
      }
    }
    //CHECK HAD SWIPED TO SEND PUSH
    var filterHadSwiped = widget.eventRequest.restaurants.where((element) => element.isSwipe).toList();

    if (listUsers.length > 0 && filterHadSwiped.length > 0) {
      for (var item in listUsers) {
        if (item.uid != currentUser.uid) {
          var api = NotificationApi();
          var model = NotificationRequest(
              '',
              'Yum! A winning restaurant has been selected for ${widget.eventRequest?.name ?? ''} hosted by ${host?.username ?? ''}.'
                  .replaceAll('  ', ' ')
                  .replaceAll('   ', ' ')
                  .replaceAll(' .', '.')
                  .replaceAll('  .', '.'),
              item.deviceToken);
          var result = await api.sendMessage(model);
          print("NOTIFICATION SWIPE LAST: ${result.data.toString()}");
        }
      }
    }
  }

  //SAVE EVENT TO DB
  void saveDB(BuildContext context) async {
    final nameDB = await DefaultStore.instance.getEventDB();
    final dbRef = Firestore.instance;
    await dbRef.collection("events").document(nameDB).updateData(widget.eventRequest.toJson()).then((_) {
      print("success update event!");
    });
  }

  Widget _buildGotItButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
            FocusScope.of(context).unfocus();
            bloc.gotItBloc.push(true);
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(28.0),
          ),
          child: Text(
            'GOT IT',
            style: AppStyle.style14BoldRed,
          ),
        ),
      ),
    );
  }

  _handleSwipeLeft({bool isTap = true}) {
    isYes = false;
    if (!isTap && (subject.value.length > 0)) {
      bloc.reloadBLoc.push(true);
      isTap = isTap;
      Future.delayed(Duration(seconds: 1)).then((val) {
        isTap = false;
      });
    }
    Future.delayed(Duration(milliseconds: 200)).then((val) {
      removeItemSlidder(
          context, (subject.value)[(subject.value).length - 1], (subject.value).length - 1);
      bloc.reloadBLoc.push(true);
    });
  }

  void handleSwipeRight({bool isTab = false}) {
    isYes = true;
    if (!isTap && (subject.value.length > 0)) {
      bloc.reloadBLoc.push(true);
      isTap = isTab;
      Future.delayed(Duration(milliseconds: 200)).then((val) {
        removeItemSlidder(
            context, (subject.value)[(subject.value).length - 1], (subject.value).length - 1);
        bloc.reloadBLoc.push(true);
      });
      Future.delayed(Duration(seconds: 1)).then((val) {
        isTap = false;
      });
    }
  }

  handleReview() {
    Navigator.of(context).push(
      PageTransition(
          type: PageTransitionType.upToDown,
          child: ReviewScreen(
            listRestaurants: widget.eventRequest?.restaurants ?? [],
            onReviewAction: (List<RestaurantModel> listUpdate) async {
              widget.eventRequest.restaurants = listUpdate;

              final currentUser = await FirebaseAuth.instance.currentUser();
              for (var i = 0; i < widget.eventRequest.swipes.length; i++) {
                if (widget.eventRequest.swipes[i].user == currentUser.uid) {
                  for (RestaurantModel item in widget.eventRequest.restaurants ?? []) {
                    for (var k = 0; k < widget.eventRequest.swipes[i].restaurants.length; k++) {
                      if (item.id == widget.eventRequest.swipes[i].restaurants[k].restaurantId) {
                        widget.eventRequest.swipes[i].restaurants[k].isLike = item.isLike;
                      }
                    }
                  }
                }
              }
            },
          ),
          duration: Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn),
    );
  }
}
