import 'dart:math';

import 'package:bflutter/bflutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:french_fry/main.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/models/remote/request/notification_request.dart';
import 'package:french_fry/models/remote/restaurant_model.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/pages/contact/contact_screen.dart';
import 'package:french_fry/pages/event_detail/event_detail_bloc.dart';
import 'package:french_fry/pages/guest/guest_screen.dart';
import 'package:french_fry/pages/swipe/swipe_screen.dart';
import 'package:french_fry/pages/swipe_success/swipe_success_screen.dart';
import 'package:french_fry/provider/store/remote/notification_api.dart';
import 'package:french_fry/provider/store/store.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:french_fry/widgets/transparent_route.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

enum TypeEvent {
  Normal,
  QR,
  Invite,
  SwipeMore,
  SwipeMoreInvite,
}

class EventDetailScreen extends StatefulWidget {
  EventRequest event;
  TypeEvent type = TypeEvent.Normal;
  EventDetailScreen({Key key, @required this.event, @required this.type})
      : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = EventDetailBloc();
  String image = 'https://source.unsplash.com/1600x900/?nature,water';
  List<User> listAvatars = List<User>();
  bool isFinishSwipe = false;
  bool isHost = false;
  bool isAvailable = false; // CONDITION VALIDATE 'INVITE FRIENDS'
  bool isEnableSwipeButton = false;
  bool isShowSwipeMore = false; // USER SWIPED BUT NOT SWIPED ALL

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveDatabaseName();
    //checkEventRequest();
    checkReloadFromPush();

    eventBus.on().listen((event) {
      if (event == AppConstant.kHavePushNotiffication) {
        checkReloadFromPush();
      }
    });
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
      if (item.codeQR == widget.event.codeQR &&
          item.name == widget.event.name) {
        widget.event = item;
        checkEventRequest();
        break;
      }
    }
  }

  //SAVE DATABASE
  void saveDatabaseName() async {
    if (widget.event.nameDB.length > 0) {
      await DefaultStore.instance.saveEventDB(widget.event.nameDB);
    }
  }

  void checkEventRequest() async {
    listAvatars = List<User>();
    bloc.loading.push(true);
    final currentUser = await FirebaseAuth.instance.currentUser();
    if (currentUser.uid == widget.event.host) {
      isHost = true;
    }
    if (widget.event != null) {
      //CHECK DUPLICATE
      final seenCards = Set<String>();
      widget.event.restaurants =
          widget.event.restaurants.where((e) => seenCards.add(e.id)).toList();
      //Check restaurant which current user has swiped on
      for (var i = 0; i < widget.event.swipes.length; i++) {
        if (currentUser.uid == widget.event.swipes[i].user) {
          for (var j = 0; j < widget.event.restaurants.length; j++) {
            for (var k = 0;
                k < widget.event.swipes[i].restaurants.length;
                k++) {
              if (widget.event.swipes[i].restaurants[k].restaurantId ==
                  widget.event.restaurants[j].id) {
                widget.event.restaurants[j].isSwipe = true;
                widget.event.restaurants[j].isLike =
                    widget.event.swipes[i].restaurants[k].isLike;
              }
            }
          }
        }
      }
      var filter = widget.event.restaurants
          .where((element) => !element.isSwipe)
          .toList(); // NOT SWIPED
      var filterSwiped = widget.event.restaurants
          .where((element) => element.isSwipe)
          .toList(); //SWIPED

      isShowSwipeMore = filter.length > 0 && filterSwiped.length > 0;

      //CHECK ALL GUEST FINISH/ TIME SWIPE MUST > TODAY
      var swipeDate = AppHelper.convertStringToDateWithFormat(
          widget.event.swipeTime, AppConstant.formatTime);
      var today = AppHelper.convertStringToDateWithFormat(
          AppHelper.convertDatetoStringWithFormat(
              DateTime.now(), AppConstant.formatTime),
          AppConstant.formatTime);

      // ISWIPE IS FALSE, LENGTH RESTAURANT == 0, SWIPE ALL => FINISH SWIPE
      // isFinishSwipe = filter.length == 0 || today.isAfter(swipeDate);

      //TIME SWIPE MUST > TODAY, CONDITION SHOW INVITES FRIEND
      isAvailable = !today.isAfter(swipeDate);

      //LOGIC SHOW GUESTS LIST
      final dbRef = Firestore.instance;
      var result = await dbRef.collection("users").getDocuments();
      var filterHost = result.documents
          .where((element) => element['uid'] == widget.event.host)
          .toList();
      if (filterHost.length > 0) {
        listAvatars.add(User.fromJson(filterHost.first.data));
      }
      for (var element in result.documents) {
        var user = User.fromJson(element.data);
        for (var item in widget.event.guests) {
          if (user.uid == item && item != widget.event.host) {
            listAvatars.add(user);
          }
        }
      }

      //LOGIC FINISH SWIPE, SHOW UI IN EVENT DETAIL

      var filterAllSwipe = widget.event.swipes
          .where((element) => element.restaurants.length > 0)
          .toList();
      // if (!isFinishSwipe) {
      var filterCurrent = widget.event.swipes
          .where((element) => element.user == currentUser.uid)
          .toList();
      if (today.isAfter(swipeDate)) {
        // PAST EVENT
        isFinishSwipe = true;
      } else if (widget.event.guests.length > 0) {
        //GUEST > 0
        isFinishSwipe = filterAllSwipe.length == widget.event.swipes.length &&
            filterCurrent.length > 0 &&
            (widget.event.guests.length + 1) == filterAllSwipe.length;
      }
      // else if (widget.event.guests.length == 0 &&
      //     widget.event.swipes.length > 0) {
      //   //GUEST == 0 && event.swipes.length > 0 => HOST
      //   isFinishSwipe = widget.event.swipes.first.restaurants.length > 0 && widget.event.restaurants.length > 0 && filter.length == 0;
      // }
      else {
        // GUEST == 0
        isFinishSwipe = filterAllSwipe.length > 0 &&
            filterCurrent.length > 0 &&
            (widget.event.guests.length + 1) == filterAllSwipe.length;
      }
      // } else {
      if (isFinishSwipe) {
        // ISFINISHSWIPE, FOUND RESTAURANT
        List<RestaurantModel> listMostRetaurant = List<RestaurantModel>();
        listMostRetaurant.addAll(widget.event.restaurants);
        if (listMostRetaurant.length > 0) {
          listMostRetaurant
              .sort((a, b) => a.like.compareTo(b.like)); // MAX is LAST
          var filterLike = listMostRetaurant
              .where((element) => element.like == listMostRetaurant.last.like)
              .toList();
          if (filterLike.length == 1) {
            // ONLY 1 LIKE MAX
            widget.event.chooseRestaurant = filterLike.first;
          } else {
            //A LOT LIKE MOST DUPLICATE
            List<RestaurantModel> listMostRating = List<RestaurantModel>();
            listMostRating.addAll(filterLike);
            listMostRating.sort((a, b) => a.rating.compareTo(b.rating));
            var filterRating = listMostRating
                .where(
                    (element) => element.rating == listMostRating.last.rating)
                .toList();
            if (filterRating.length == 1) {
              // ONLY 1 RATING MAX
              widget.event.chooseRestaurant = filterRating.first;
            } else {
              // RAMDOM A LOT OF RATING
              Random random = new Random();
              var index = random.nextInt(filterRating.length - 1);
              widget.event.chooseRestaurant = filterRating[index];
            }
          }
        } else {
          isFinishSwipe = false;
        }
      }

      //LENGTH RESTAURANTS HAS IS SWIPE FALSE > 0, ENABLE BUTTON SWIPE
      if (filter.length > 0 && !isFinishSwipe) {
        isEnableSwipeButton = filter.length > 0;
      }

      //SHOW TYPE IN EVENT
      if (filterAllSwipe.length == 0 && widget.event.restaurants.length > 0) {
        widget.type = isHost ? TypeEvent.SwipeMoreInvite : TypeEvent.QR;
      } else if (!isFinishSwipe || widget.event.chooseRestaurant == null) {
        widget.type = isHost ? TypeEvent.SwipeMoreInvite : TypeEvent.QR;
      } else {
        widget.type = TypeEvent.Normal;
      }

      //RELOAD ALL SCREEN
      bloc.loading.push(false);
      bloc.reloadBloc.push(true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  MediaQuery(
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
        height: 52,
        margin: EdgeInsets.only(top: 0, left: 0, right: 0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 0, top: 0, bottom: 0),
              width: 50,
              height: 52,
              child: FlatButton(
                padding: EdgeInsets.all(0.0),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  // eventBus.fire(AppConstant.kBackDetailEvent);
                  Future.delayed(Duration(milliseconds: 100)).then((val) {
                    Navigator.of(context).pop(false);
                    if (widget.event.isFromQRScreen ?? false) {
                      Navigator.of(context).pop(true);
                    }
                  });
                },
                child: Image.asset(AppImages.icBackWhite, width: 9, height: 16),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 50),
                alignment: Alignment.center,
                child: Text(
                    isHost || isFinishSwipe ? (widget.event?.name ?? '') : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.style24MediumWhite),
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
        decoration: new BoxDecoration(
            color: AppColor.bgColor,
            borderRadius: new BorderRadius.only(
                topLeft: Radius.circular(28), topRight: Radius.circular(28))),
        child: ClipRRect(
          borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          child: _buildCheckType(context, widget.type),
        ),
      ),
    );
  }

  Widget _buildCheckType(BuildContext context, TypeEvent type) {
    if (type == TypeEvent.QR) {
      return MediaQuery.of(context).size.height > 667
          ? Column(
              children: <Widget>[
                _buildNameEvent(context),
                _buildEventTime(context),
                _buildSwipeDealine(context),
                _buildListUser(context),
                isHost ? _buildDeleteEvent(context) : Container(),
                isEnableSwipeButton && !isFinishSwipe
                    ? _buildRestaurantNotYet(context)
                    : Container(height: 1),
                Expanded(
                  child: isEnableSwipeButton
                      ? Column(
                          children: <Widget>[
                            Expanded(child: Container()),
                            SafeArea(
                              top: false,
                              bottom: true,
                              child: _buildButton(context),
                            ),
                          ],
                        )
                      : Container(),
                )
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildNameEvent(context),
                  _buildEventTime(context),
                  _buildSwipeDealine(context),
                  _buildListUser(context),
                  isHost ? _buildDeleteEvent(context) : Container(),
                  isEnableSwipeButton && !isFinishSwipe
                      ? _buildRestaurantNotYet(context)
                      : Container(height: 1),
                  isEnableSwipeButton
                      ? SafeArea(
                          top: false,
                          bottom: true,
                          child: _buildButton(context),
                        )
                      : Container(height: 0),
                ],
              ),
            );
    } else if (type == TypeEvent.Normal) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildRestaurant(context),
            _buildEventTime(context),
            _buildSwipeDealine(context),
            _buildListUser(context),
            isHost ? _buildDeleteEvent(context) : Container(),
            isEnableSwipeButton && !isFinishSwipe
                ? _buildRestaurantNotYet(context)
                : Container(height: 1)
          ],
        ),
      );
    } else if (type == TypeEvent.Invite) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildRestaurant(context),
            _buildEventTime(context),
            _buildSwipeDealine(context),
            _buildListUser(context),
            isHost ? _buildDeleteEvent(context) : Container(),
            isEnableSwipeButton && !isFinishSwipe
                ? _buildRestaurantNotYet(context)
                : Container(height: 1)
          ],
        ),
      );
    } else if (type == TypeEvent.SwipeMore) {
      return MediaQuery.of(context).size.height > 667
          ? Column(
              children: <Widget>[
                _buildEventTime(context),
                _buildSwipeDealine(context),
                _buildListUser(context),
                isHost ? _buildDeleteEvent(context) : Container(),
                isEnableSwipeButton && !isFinishSwipe
                    ? _buildRestaurantNotYet(context)
                    : Container(height: 1),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(child: Container()),
                      isEnableSwipeButton
                          ? SafeArea(
                              top: false,
                              bottom: true,
                              child: _buildSwipeMoreRestaurantButton(context),
                            )
                          : Container()
                    ],
                  ),
                )
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildEventTime(context),
                  _buildSwipeDealine(context),
                  _buildListUser(context),
                  isHost ? _buildDeleteEvent(context) : Container(),
                  isEnableSwipeButton && !isFinishSwipe
                      ? _buildRestaurantNotYet(context)
                      : Container(height: 1),
                  isEnableSwipeButton
                      ? SafeArea(
                          top: false,
                          bottom: true,
                          child: _buildSwipeMoreRestaurantButton(context),
                        )
                      : Container(height: 0)
                ],
              ),
            );
    } else if (type == TypeEvent.SwipeMoreInvite) {
      return MediaQuery.of(context).size.height > 667
          ? Column(
              children: <Widget>[
                _buildEventTime(context),
                _buildSwipeDealine(context),
                _buildListUser(context),
                isHost ? _buildDeleteEvent(context) : Container(),
                isEnableSwipeButton && !isFinishSwipe
                    ? _buildRestaurantNotYet(context)
                    : Container(height: 1),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(child: Container()),
                      isEnableSwipeButton
                          ? SafeArea(
                              top: false,
                              bottom: true,
                              child: _buildSwipeMoreRestaurantButton(context),
                            )
                          : Container(),
                    ],
                  ),
                )
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildEventTime(context),
                  _buildSwipeDealine(context),
                  _buildListUser(context),
                  isHost ? _buildDeleteEvent(context) : Container(),
                  isEnableSwipeButton && !isFinishSwipe
                      ? _buildRestaurantNotYet(context)
                      : Container(height: 1),
                  isEnableSwipeButton
                      ? SafeArea(
                          top: false,
                          bottom: true,
                          child: _buildSwipeMoreRestaurantButton(context),
                        )
                      : Container(height: 0),
                ],
              ),
            );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildRestaurant(context),
            _buildEventTime(context),
            _buildSwipeDealine(context),
            _buildListUser(context),
            isHost ? _buildDeleteEvent(context) : Container(),
            isEnableSwipeButton && !isFinishSwipe
                ? _buildRestaurantNotYet(context)
                : Container(height: 1)
          ],
        ),
      );
    }
  }

  Widget _buildDeleteEvent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 20),
      height: 45,
      child: FlatButton(
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.all(0.0),
        onPressed: () {
          //DELETE ACTION
          deleteEventAction(context);
        },
        child: Text(
          'Delete Event',
          style: AppStyle.style16MediumRed,
        ),
      ),
    );
  }

  void deleteEventAction(BuildContext context) async {
    bloc.loading.push(true);
    final dbRef = Firestore.instance;
    var result = await dbRef.collection("users").getDocuments();
    List<User> listUser = List<User>();
    for (var element in result.documents) {
      for (var item in widget.event.guests) {
        if (element.data['uid'] == (item) &&
            element.data['deviceToken'] != null) {
          listUser.add(User.fromJson(element.data));
        }
      }
    }
    final currentUser = await FirebaseAuth.instance.currentUser();
    for (var item in listUser) {
      if (item.uid != currentUser.uid) {
        var api = NotificationApi();
        var model = NotificationRequest(
            '',
            '${currentUser.displayName} has deleted the event for ${widget.event.name}.'
                .replaceAll('  ', ' ')
                .replaceAll('   ', ' ')
                .replaceAll(' .', '.')
                .replaceAll('  .', '.'),
            item.deviceToken);
        var result = await api.sendMessage(model);
        print("NOTIFICATION: ${result.data.toString()}");
      }
    }

    //DELETE FROM DB
    await dbRef.collection('events').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        var item = EventRequest.fromJson(ds.data);
        if (item.codeQR == widget.event.codeQR &&
            item.host == widget.event.host) {
          ds.reference.delete();
        }
      }
    });

    Future.delayed(Duration(milliseconds: 100)).then((val) {
      bloc.loading.push(false);
      Navigator.of(context).pop(widget.event.codeQR);
      if (widget.event.isFromQRScreen ?? false) {
        Navigator.of(context).pop(widget.event.codeQR);
      }
    });
  }

  Widget _buildRestaurantNotYet(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              top: AppHelper.getHeightFromScreenSize(context, 28),
              left: 5,
              right: 5),
          alignment: Alignment.center,
          height: 31,
          child: Text('Restaurant Not Yet Chosen',
              style: AppStyle.style21MediumRed),
        ),
        Container(
          margin: EdgeInsets.only(
            top: AppHelper.getHeightFromScreenSize(context, 5),
          ),
          alignment: Alignment.center,
          height: 79,
          child: Text(
            'The restaurant will be chosen when the\ndeadline is reached or all guests have\nswiped.',
            style: AppStyle.style14RegularGreyHeight,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
      height: 56,
      padding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      decoration: new BoxDecoration(
        color: AppColor.redColor,
        borderRadius: new BorderRadius.all(Radius.circular(36)),
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
          color: AppColor.redColor,
          borderRadius: new BorderRadius.all(Radius.circular(36)),
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
            Navigator.of(context).push(
              CupertinoPageRoute(
                //TransparentSlideRoute
                builder: (BuildContext context) => isFinishSwipe
                    ? SwipeSuccessScreen()
                    : SwipeScreen(
                        eventRequest: widget.event,
                      ),
              ),
            );
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(36.0),
          ),
          child: Text(
            isShowSwipeMore ? 'SWIPE MORE RESTAURANTS' : 'START SWIPING',
            style: AppStyle.style14BoldWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeMoreRestaurantButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
      height: 56,
      padding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      decoration: new BoxDecoration(
        color: AppColor.redColor,
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
          color: AppColor.redColor,
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
            Navigator.of(context).push(
              CupertinoPageRoute(
                //TransparentSlideRoute
                builder: (BuildContext context) => isFinishSwipe
                    ? SwipeSuccessScreen()
                    : SwipeScreen(
                        eventRequest: widget.event,
                      ),
              ),
            );
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(28.0),
          ),
          child: Text(
            isShowSwipeMore ? 'SWIPE MORE RESTAURANTS' : 'START SWIPING',
            style: AppStyle.style14BoldWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildNameEvent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: AppHelper.getHeightFromScreenSize(context, 44),
        bottom: AppHelper.getHeightFromScreenSize(context, 28),
        left: 5,
        right: 5,
      ),
      height: 32,
      child: Text(
        'Welcome to ${widget.event?.name ?? ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppStyle.style24MediumRed,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildListUser(BuildContext context) {
    return Container(
      height: (isHost && isAvailable) ||
              (widget.event.allowFriend && isAvailable)
          ? 149
          : 96, //widget.type == TypeEvent.Invite || widget.type == TypeEvent.SwipeMoreInvite
      margin: EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 12),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
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
      child: Column(
        children: <Widget>[
          Container(
            height: 16,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text('Guests', style: AppStyle.style14RegularBlack60),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 44,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: listAvatars.length > 3
                      ? _buildPlus(context)
                      : ListView.builder(
                          itemCount: listAvatars.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildItemAvatar(
                                context, listAvatars[index], index);
                          }),
                ),
              ),
              widget.type == TypeEvent.SwipeMore
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(left: 0, right: 8),
                      child: FlatButton(
                        padding: EdgeInsets.all(0.0),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            TransparentRoute(
                              builder: (BuildContext context) => GuestScreen(
                                listGuests: listAvatars,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 0, top: 0, bottom: 0, right: 0),
                              child: Text('View All',
                                  style: AppStyle.style14RegularRed),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 9, top: 0, bottom: 0),
                              width: 6,
                              height: 10,
                              child: Image.asset(AppImages.icNextRedFat,
                                  width: 6, height: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
          (isHost && isAvailable) || (widget.event.allowFriend && isAvailable)
              ? _buildButtonInvite(context)
              : Container()
        ],
      ),
    );
  }

  Widget _buildPlus(BuildContext context) {
    var listPlus = List<User>();
    for (var i = 0; i < listAvatars.length; i++) {
      if (i > 2) {
        listPlus.add(listAvatars[i]);
      }
    }

    return Stack(
      children: <Widget>[
        ListView.builder(
          itemCount: listAvatars.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return index >= 3
                ? Container()
                : _buildItemAvatar(context, listAvatars[index], index);
          },
        ),
        Container(
          margin: EdgeInsets.only(left: 150.0),
          child: Stack(
            children: _buildListAvatarPlus(context, listPlus),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 150.0),
          child: Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 234, 189, 1),
                  borderRadius: BorderRadius.all(Radius.circular(22))),
              child: Text('+${listPlus.length}',
                  style: AppStyle.style14RegularRed)),
        ),
      ],
    );
  }

  List<Widget> _buildListAvatarPlus(BuildContext context, List<User> listPlus) {
    List<Widget> listWidgets = List<Widget>();
    for (var i = 0; i < listPlus.length; i++) {
      var con = Container(
        margin: EdgeInsets.only(right: 6),
        height: 44,
        width: 44,
        decoration: BoxDecoration(
            color: AppColor.redColor.withOpacity(0.2),
            borderRadius: BorderRadius.all(Radius.circular(22))),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          child: Hero(
            tag: listPlus[i].uid + (3 + i).toString(),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              child: CachedNetworkImage(
                imageUrl: listPlus[i].avatarUrl,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      listWidgets.add(con);
    }
    return listWidgets;
  }

  Widget _buildButtonInvite(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12, right: 12, top: 12),
      height: 41,
      width: MediaQuery.of(context).size.width - (12 + 16) * 2,
      // alignment: Alignment.center,
      decoration: new BoxDecoration(
        color: AppColor.bgColor.withOpacity(0.4),
        borderRadius: new BorderRadius.all(Radius.circular(4)),
      ),
      child: FlatButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          var result = await Navigator.of(context).push(TransparentRoute(
              builder: (BuildContext context) => ContactScreen()));
          if (result != null) {
            var listContact = result as List<Contact>;
            if (listContact.length > 0) {
              logicInviteContact(listContact);
            }
          }
        },
        padding: EdgeInsets.all(0.0),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(4.0),
        ),
        child: Text(
          'INVITE MORE GUESTS',
          style: AppStyle.style14BoldRed,
        ),
      ),
    );
  }

  void logicInviteContact(List<Contact> listContact) async {
    final dbRef = Firestore.instance;
    var result = await dbRef.collection("users").getDocuments();
    for (var element in result.documents) {
      // print(element.data);
      for (var i = 0; i < listContact.length; i++) {
        if (listContact[i].phones.length > 0 &&
            (element.data['phone'] as String).contains(
                (listContact[i].phones?.first?.value ?? '')
                    .replaceAll('-', '')
                    .replaceAll(')', '')
                    .replaceAll('(', '')
                    .replaceAll(' ', '')
                    .toString())) {
          //HAVE PHONE IN BATA BASE
          listContact[i].androidAccountName = "1";
        }
      }
    }
    if (listContact.length > 0) {
      var filterPhoneInDB = listContact
          .where((element) => element.androidAccountName == "1")
          .toList();
      var filterPhoneNormal = listContact
          .where((element) => element.androidAccountName != "1")
          .toList();
      if (filterPhoneNormal.length > 0) {
        // PHONE NOT HAVE DB SEND SMS
        String message = "This is a test message!";
        List<String> recipents = List<String>();
        for (var item in filterPhoneNormal) {
          if (item.phones.length > 0) recipents.add(item.phones.first.value);
        }
        sendMessage(message, recipents);
      } else if (filterPhoneInDB.length > 0) {
        // PHONE HAVE DB SEND NOTIFICATION
        print("Send notification to user have this phone");
        final dbRef = Firestore.instance;
        var result = await dbRef.collection("users").getDocuments();
        List<User> listUser = List<User>();
        for (var element in result.documents) {
          print(element.data);
          for (var item in filterPhoneInDB) {
            if (item.phones.length > 0 &&
                (element.data['phone'] as String).contains(
                    (item.phones?.first?.value ?? '')
                        .replaceAll('-', '')
                        .replaceAll(')', '')
                        .replaceAll('(', '')
                        .replaceAll(' ', '')) &&
                element.data['deviceToken'] != null) {
              listUser.add(User.fromJson(element.data));
            }
          }
        }
        final currentUser = await FirebaseAuth.instance.currentUser();
        for (var item in listUser) {
          if (item.uid != currentUser.uid) {
            var filterUserAdd = widget.event.guests
                .where((element) =>
                    (item.uid == element || item.uid == widget.event.host))
                .toList();
            if (filterUserAdd.length == 0) {
              var filter = widget.event.guests
                  .where((element) => element == item.uid)
                  .toList(); //DUPLICATE CHECK
              if (currentUser.uid != item.uid && filter.length == 0) {
                widget.event.guests.add(item.uid);
              }
            }

            var api = NotificationApi();
            var model = NotificationRequest(
                '',
                'You have been invited to ${widget.event.name.toString()} by ${currentUser.displayName}.This event is now added to your upcoming events.'
                    .replaceAll('  ', ' ')
                    .replaceAll('   ', ' ')
                    .replaceAll(' .', '.')
                    .replaceAll('  .', '.'),
                item.deviceToken);
            var result = await api.sendMessage(model);
            print("NOTIFICATION RESUL ::::::: ${result.data.toString()}");
          }
        }
        //Update database events
        updateDB(widget.event.nameDB);
        listAvatars = [];
        eventBus.fire(AppConstant.kReloadHome);
        checkEventRequest();
      }
    }
  }

  void updateDB(String nameDB) async {
    final dbRef = Firestore.instance;
    await dbRef
        .collection("events")
        .document(nameDB)
        .updateData(widget.event.toJson())
        .then((_) {
      print("success update event!");
    });
  }

  void sendMessage(String message, List<String> recipents) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    for (var i = 0; i < recipents.length; i++) {
      if (recipents[i][0] != '0' && recipents[i][0] != '+') {
        recipents[i] = '+1' + recipents[i];
      }
    }
    await FlutterSms.sendSMS(
            message:
                "${currentUser.displayName} has invited you to ${widget.event.name.toString()} on FrenchFry. Download the app here <link to AppStore>",
            recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
  }

  Widget _buildItemAvatar(BuildContext context, User user, int index) {
    return Container(
      margin: EdgeInsets.only(right: 6),
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: AppColor.redColor.withOpacity(0.2),
          border: Border.all(
              color: index == 0 ? AppColor.redColor : Colors.white, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(22))),
      child: Hero(
        tag: user.uid + index.toString(),
        child: Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl ?? '',
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
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
                    alignment: Alignment.topRight,
                    child: Image.asset(AppImages.icStarGuest,
                        width: 14, height: 14),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTime(BuildContext context) {
    return Container(
      height: 80,
      margin: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 12),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
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
      child: Column(
        children: <Widget>[
          Container(
            height: 16,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text('Event Time', style: AppStyle.style14RegularBlack60),
          ),
          Container(
            height: 32,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 16, right: 16, top: 4),
            child: Text(
                widget.event?.eventTime != null
                    ? AppHelper.convertDatetoStringWithFormat(
                        AppHelper.convertStringToDateWithFormat(
                            widget.event?.eventTime, AppConstant.formatTime),
                        'EEE, MMM dd, h:mm aa')
                    : 'Friday, May 14, 10:30 AM',
                style: AppStyle.style19RegularGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeDealine(BuildContext context) {
    return Opacity(
      opacity: widget.type == TypeEvent.QR || widget.type == TypeEvent.SwipeMore
          ? 1
          : 0.6,
      child: Container(
        height: 80,
        margin: EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 12),
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
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
        child: Column(
          children: <Widget>[
            Container(
              height: 16,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 16, right: 16, top: 16),
              child:
                  Text('Swipe Deadline', style: AppStyle.style14RegularBlack60),
            ),
            Container(
              height: 32,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 16, right: 16, top: 4),
              child: Text(
                  widget.event?.swipeTime != null
                      ? AppHelper.convertDatetoStringWithFormat(
                          AppHelper.convertStringToDateWithFormat(
                              widget.event?.swipeTime, AppConstant.formatTime),
                          'EEE, MMM dd, h:mm aa')
                      : 'Friday, May 14, 10:30 AM',
                  style: AppStyle.style19RegularGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurant(BuildContext context) {
    String categoryString = '';
    for (var it in (widget.event?.chooseRestaurant?.categories ?? [])) {
      if (categoryString == '') {
        categoryString = it.title;
      } else {
        categoryString += ', ${it.title}';
      }
    }
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            height: 208,
            margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(28.0),
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
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(28)),
              child: CachedNetworkImage(
                imageUrl: widget.event?.chooseRestaurant?.imageUrl ?? image,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 128,
            margin: EdgeInsets.only(left: 36, right: 36, top: 128),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(28.0),
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
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 32,
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.event?.chooseRestaurant?.name ??
                                  'Restaurant 1',
                              style: AppStyle.style20MediumGrey,
                            ),
                          ),
                          Container(
                            height: 25,
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 6),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              categoryString.length > 0
                                  ? categoryString
                                  : 'Greek Cuisine',
                              style: AppStyle.style15MediumBlack60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 68 / 2,
                      height: 87 / 2,
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(
                          right: AppHelper.getWidthFromScreenSize(context, 30),
                          top: 10),
                      child: Image.asset(AppImages.icWin,
                          width: 68 / 2, height: 87 / 2),
                    )
                  ],
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
                              rating:
                                  widget.event?.chooseRestaurant?.rating ?? 5,
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
                          widget.event?.chooseRestaurant?.price ?? '\$\$\$',
                          style: AppStyle.style14RegularRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
