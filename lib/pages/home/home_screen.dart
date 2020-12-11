import 'dart:io';

import 'package:bflutter/bflutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sidekick/flutter_sidekick.dart';
import 'package:french_fry/main.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/pages/base/crop_image/crop_image_screen.dart';
import 'package:french_fry/pages/create_event/create_event_screen.dart';
import 'package:french_fry/pages/event_detail/event_detail_screen.dart';
import 'package:french_fry/pages/home/home_bloc.dart';
import 'package:french_fry/pages/join_event/join_event_screen.dart';
import 'package:french_fry/pages/past_upcoming_event/past_upcoming_event_screen.dart';
import 'package:french_fry/pages/welcome/welcome_screen.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  FirebaseUser user;
  HomeScreen({Key key, this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final mainBloc = MainBloc.instance;
  final bloc = HomeBloc();
  bool isAvatar = false;
  bool isSetUserName = false;
  SidekickController controller;
  String username = '';
  File _image;
  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController nameController = TextEditingController();
  List<EventRequest> upcomingEvents = List<EventRequest>();
  List<EventRequest> pastEvents = List<EventRequest>();
  BuildContext contextNo;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final String emptyEventText =
      'Here is where your events will be placed,\nonce your start your first event,\nor invited to an event,\nthey will appear here!';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    initFirebaseMessage();

    nameController.text = widget.user?.displayName ?? '';
    username = widget.user?.displayName ?? '';
    controller = SidekickController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    eventBus.on().listen((val) {
      if (val == AppConstant.kReloadUser) {
        reloadAction(context);
      } else if (val == AppConstant.kReloadHome) {
        bloc.getEvents();
      }
    });

    checkListUser();
  }

  //INIT FIREBASE MESSAGE
  void initFirebaseMessage() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        eventBus.fire(AppConstant.kHavePushNotiffication);
        bloc.getEvents();
        var te = message['notification'];
        if (te != null) {
          var text = te['body'];
          if (text != null) {
            /*
            showCupertinoDialog(
              context: context,
              builder: (_) => Theme(
                data: Theme.of(context).copyWith(
                    dialogBackgroundColor: Colors.orange.withOpacity(0)),
                child: NotificationPopup(
                  errorText: text,
                  onYes: () {},
                  contextLanguage: contextNo,
                ),
              ),
            );*/
          }
        }

        var tex = message['aps'];
        if (tex != null) {
          var alert = tex['alert'];
          if (alert != null) {
            var text = alert['body'];
          }
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        eventBus.fire(AppConstant.kHavePushNotiffication);
        bloc.getEvents();
        
      },
    );
  }

  //ONSELECTED NOTIFICATION
  Future onSelectNotification(String payload) async {
    print("Selected notification");
  }

  //CHECK LIST USER
  void checkListUser() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    var deviceToken = await _firebaseMessaging.getToken();
    bool isAdd = false;
    var model = User(
        uid: widget.user.uid,
        avatarUrl: widget.user.photoUrl,
        phone: widget.user.phoneNumber,
        username: widget.user.displayName,
        deviceToken: deviceToken);

    final dbRef = Firestore.instance;
    var result = await dbRef.collection("users").getDocuments();
    for (var element in result.documents) {
      // print(element.data);
      if (element.data['phone'] == widget.user.phoneNumber) {
        isAdd = true;

        dbRef
            .collection("users")
            .document(element.documentID)
            .updateData(model.toJson())
            .then((_) {
          print("success update user Home!");
        });
      }
    }

    if (!isAdd) {
      dbRef.collection('users').add(model.toJson()).then((val) {
        print('RESULT :: ${val.documentID}');
      });
    }

    // dbRef.collection('events').getDocuments().then((snapshot) {
    //   for (DocumentSnapshot ds in snapshot.documents) {
    //     ds.reference.delete();
    //   }
    // });
  }

  void reloadAction(BuildContext context) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    widget.user = currentUser;
    bloc.reloadBloc.push(true);
  }

  @override
  Widget build(BuildContext context) {
    this.contextNo = context;
    username = widget.user?.displayName ?? '';
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: AppColor.bgColor,
        body: StreamBuilder(
          stream: bloc.loading.stream,
          builder: (context, AsyncSnapshot<bool> loading) {
            return Stack(
              children: <Widget>[
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: StreamBuilder(
                    stream: bloc.reloadBloc.stream,
                    builder: (context, data) {
                      return Column(
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * .56),
                            decoration: BoxDecoration(
                              color: AppColor.redColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(44),
                                  bottomRight: Radius.circular(44)),
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                child: AnimatedCrossFade(
                                  firstChild: _header(context),
                                  secondChild: _headerSecond(context),
                                  alignment: Alignment.topCenter,
                                  crossFadeState: isAvatar
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: Duration(milliseconds: 100),
                                  reverseDuration: Duration(milliseconds: 100),
                                  firstCurve: Curves.fastLinearToSlowEaseIn,
                                  secondCurve: Curves.fastLinearToSlowEaseIn,
                                  sizeCurve: Curves.bounceOut,
                                ),
                              ),
                            ),
                          ),
                          Hero(
                            tag: 'BODY_PROFILE',
                            child: _buildBody(context),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                AppHelper.buildLoading(loading.data ?? false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Sidekick(
              tag: 'source',
              targetTag: 'target',
              child: (widget.user?.photoUrl ?? '').length == 0
                  ? Container(
                      margin: EdgeInsets.only(top: 0, right: 24),
                      alignment: Alignment.topRight,
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: new BorderRadius.all(
                          Radius.circular(18),
                        ),
                      ),
                      child: FlatButton(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            isAvatar = true;
                            nameController.text = username;
                            controller.moveToTarget(context);
                            Future.delayed(Duration(milliseconds: 250))
                                .then((value) {
                              bloc.reloadBloc.push(true);
                            });
                          },
                          child: null),
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          isAvatar = true;
                          nameController.text = username;
                          controller.moveToTarget(context);
                          // Future.delayed(Duration(milliseconds: 250))
                          //     .then((value) {
                          //   bloc.reloadBloc.push(true);
                          // });
                          bloc.reloadBloc.push(true);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          child: CachedNetworkImage(
                            imageUrl: widget.user?.photoUrl ?? '',
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        Container(
          child: Image.asset(
            AppImages.icLogoRed,
            width: MediaQuery.of(context).size.height <= 667
                ? (140 * 195 / 177)
                : 195,
            height: MediaQuery.of(context).size.height <= 667
                ? MediaQuery.of(context).size.height / 5
                : MediaQuery.of(context).size.height / 3.5,
          ),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height <= 667 ? 140 : 177),
        ),
        SizedBox(height: 14),
        _buildButton(context, isCreateEvent: false),
        SizedBox(height: 14),
        _buildButton(context, isCreateEvent: true),
      ],
    );
  }

  Widget _headerSecond(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Image.asset(
                AppImages.icBackWhite,
                width: 9,
                height: 16,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                isAvatar = false;
                controller.moveToSource(context);
                bloc.reloadBloc.push(true);
                // Future.delayed(Duration(milliseconds: 350)).then((value) {
                //   bloc.reloadBloc.push(true);
                // });
              },
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                width: 41,
                alignment: Alignment.centerRight,
                child: FlatButton(
                    padding: EdgeInsets.all(0.0),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      //ACTION SIGN OUT
                      FocusScope.of(context).unfocus();
                      await FirebaseAuth.instance.signOut().then((val) {
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => WelcomeScreen()));
                      });
                    },
                    child: Text(
                      'Logout',
                      style: AppStyle.style14RegularWhite,
                    )),
              ),
            ),
          ],
        ),
        Sidekick(
          tag: 'target',
          child: Container(
            height: MediaQuery.of(context).size.height <= 667 ? 137 : 157,
            decoration: isAvatar
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.bgColor, width: 4),
                  )
                : BoxDecoration(),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                //CHANGE AVATAR
                _buildBottomSheetAvatar(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColor.lineColor),
                child: isSetUserName
                    ? Screenshot(
                        controller: screenshotController,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.whiteOpacity),
                          alignment: Alignment.center,
                          child: Text(
                            AppHelper.getNameAlpha(username),
                            style: AppStyle.style55MediumRed,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.user?.photoUrl ?? '',
                        placeholder: (context, url) => CircleAvatar(
                          backgroundColor: Colors.amber,
                          radius: MediaQuery.of(context).size.height <= 667
                              ? 137 / 2
                              : 164 / 2,
                        ),
                        imageBuilder: (context, image) => CircleAvatar(
                          backgroundImage: image,
                          radius: MediaQuery.of(context).size.height <= 667
                              ? 137 / 2
                              : 164 / 2,
                        ),
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 30),
        Column(
          children: <Widget>[
            Hero(
              tag: 'PROFILE_1',
              child: _buildButtonProfile(context, isName: true),
            ),
            SizedBox(height: 16),
            Hero(
              tag: 'PROFILE_2',
              child: _buildButtonProfile(context, isName: false),
            ),
          ],
        ),
      ],
    );
  }

  void _buildBottomSheetAvatar(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return new Container(
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 14),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                        margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                        height: 56,
                        width: MediaQuery.of(context).size.width - 32,
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(28.0)),
                          padding: EdgeInsets.all(0.0),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            //CHOOSE PHOTO
                            isSetUserName = false;
                            Navigator.pop(context);
                            await getGallery(context);
                          },
                          child: Text(
                            'CHOOSE PHOTO',
                            textAlign: TextAlign.center,
                            style: AppStyle.style14BoldGrey,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                        height: 56,
                        width: MediaQuery.of(context).size.width - 32,
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(28.0)),
                          padding: EdgeInsets.all(0.0),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            //TAKE PHOTO
                            isSetUserName = false;
                            Navigator.pop(context);
                            await getTakePhoto(context);
                          },
                          child: Text(
                            'TAKE PHOTO',
                            textAlign: TextAlign.center,
                            style: AppStyle.style14BoldGrey,
                          ),
                        ),
                      ),
                      username.replaceAll(' ', '').length <= 1
                          ? Opacity(
                              opacity: 0.4,
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 0, right: 0, bottom: 0),
                                height: 56,
                                width: MediaQuery.of(context).size.width - 32,
                                alignment: Alignment.center,
                                child: Text(
                                  'USE INITIALS',
                                  textAlign: TextAlign.center,
                                  style: AppStyle.style14BoldBlack,
                                ),
                              ),
                            )
                          : Container(
                              margin:
                                  EdgeInsets.only(left: 0, right: 0, bottom: 0),
                              height: 56,
                              width: MediaQuery.of(context).size.width - 32,
                              child: FlatButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(28.0)),
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  //USE INITIALS
                                  isSetUserName = true;
                                  bloc.reloadBloc.push(true);
                                  Future.delayed(Duration(milliseconds: 500))
                                      .then((value) {
                                    screenshotController
                                        .capture(pixelRatio: 2.5)
                                        .then((File image) async {
                                      _image = image;
                                      var authUser = await FirebaseAuth.instance
                                          .currentUser();
                                      bloc.upload(context, _image, true,
                                          username, authUser);
                                      isSetUserName = false;
                                    }).catchError((onError) {
                                      print(onError);
                                    });
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'USE INITIALS',
                                  textAlign: TextAlign.center,
                                  style: AppStyle.style14BoldGrey,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                //CANCEL
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 21),
                  height: 56,
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: new BoxDecoration(
                    color: AppHelper.fromHex('FFC857'),
                    borderRadius: new BorderRadius.all(Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                        borderRadius: new BorderRadius.circular(28.0)),
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      //CANCEL
                      Navigator.pop(context);
                    },
                    child: Text(
                      'CANCEL',
                      textAlign: TextAlign.center,
                      style: AppStyle.style14BoldRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future getTakePhoto(BuildContext context) async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (_image != null) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (BuildContext context) => CropImageScreen(
            args: {'image': _image},
            cropAction: (File file) async {
              _image = file;
              bloc.reloadBloc.push(true);
              var authUser = await FirebaseAuth.instance.currentUser();
              bloc.upload(context, _image, true, username, authUser);
            },
          ),
        ),
      );
    }
  }

  Future getGallery(BuildContext context) async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (BuildContext context) => CropImageScreen(
            args: {'image': _image},
            cropAction: (File file) async {
              _image = file;
              bloc.reloadBloc.push(true);
              var authUser = await FirebaseAuth.instance.currentUser();
              bloc.upload(context, _image, true, username, authUser);
            },
          ),
        ),
      );
    }
  }

  Widget _buildButtonProfile(BuildContext context, {bool isName}) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 0, left: 24, right: 24),
      height: MediaQuery.of(context).size.height / 12,
      constraints: BoxConstraints(
        maxHeight: 64,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 0, right: 0, bottom: 0),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                    alignment: Alignment.centerLeft,
                    height: 24,
                    child: Text(isName ? 'Name' : 'Phone Number',
                        style: AppStyle.style16RegularWhite),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8, left: 0, right: 0),
                    height: 32,
                    alignment: Alignment.centerLeft,
                    child: isName
                        ? TextField(
                            style: AppStyle.style24MediumWhite,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 0.0, right: 0.0, top: 0.0, bottom: 7.0),
                              hintText: 'Your Name',
                              hintStyle: AppStyle.style24MediumWhite60,
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            controller: nameController,
                            obscureText: false,
                            onChanged: (text) {},
                            onSubmitted: (text) {
                              FocusScope.of(context).unfocus();
                              if (text.replaceAll(' ', '').length > 1) {
                                username = text;
                                bloc.uploadUser(context, username, null);
                              } else {
                                AppHelper.showMyDialog(context,
                                    'The name is a minimum of 2 characters!');
                              }
                            },
                          )
                        : Text(
                            isName
                                ? (widget.user?.displayName ?? '')
                                : (AppHelper.getPhoneNumberUS(
                                    widget.user?.phoneNumber ?? '')),
                            style: AppStyle.style24MediumWhite),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 1),
            alignment: Alignment.centerRight,
            width: 8,
            height: 16,
            child: Image.asset(
              AppImages.icNextWhite,
              width: 8,
              height: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {bool isCreateEvent}) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      constraints: BoxConstraints(maxHeight: 72),
      padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: isCreateEvent ? AppColor.bgColor : Colors.white,
        boxShadow: [],
        borderRadius: new BorderRadius.all(Radius.circular(35)),
      ),
      child: Container(
        margin: EdgeInsets.all(0.0),
        height: MediaQuery.of(context).size.height / 12,
        constraints: BoxConstraints(maxHeight: 72),
        width: MediaQuery.of(context).size.width - 32,
        child: FlatButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.downToUp,
                    duration: Duration(milliseconds: 300),
                    child: isCreateEvent
                        ? CreateEventScreen()
                        : JoinEventScreen()));
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(35.0)),
          child: Text(
            isCreateEvent ? 'CREATE AN EVENT' : 'JOIN AN EVENT',
            style: AppStyle.style14BoldRed,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .44),
      child: Column(
        children: <Widget>[
          _buildEventsListHeader(context),
          _buildEventsList(),
          _buildPastEventsButton(context),
          SizedBox(height: AppHelper.getHeightFromScreenSize(context, 10)),
        ],
      ),
    );
  }

  Container _buildEventsListHeader(BuildContext context) {
    return Container(
      height: 24,
      margin: EdgeInsets.only(top: 24, left: 0, right: 0),
      alignment: Alignment.topCenter,
      child: Row(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 24, top: 0, bottom: 0),
              alignment: Alignment.centerLeft,
              child:
                  Text('Upcoming Events', style: AppStyle.style16RegularGrey)),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 12, top: 0, bottom: 0),
              alignment: Alignment.centerRight,
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(6.0),
                ),
                padding: EdgeInsets.all(0.0),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  var result = await Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.downToUp,
                      child: PastUpcommingEventScreen(
                        isPast: false,
                        pastEvents: pastEvents,
                        upcomingEvents: upcomingEvents,
                      ),
                    ),
                  );
                  if (result != null) {
                    var code = result as String;
                    bloc.deleteEventFromCode(context, code);
                  }
                },
                child: Text('See More', style: AppStyle.style14RegularRed),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _buildPastEventsButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
      height: MediaQuery.of(context).size.height / 14,
      constraints: BoxConstraints(maxHeight: 56),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          border: Border.all(color: AppColor.redColor, width: 1)),
      width: MediaQuery.of(context).size.width - 32,
      child: FlatButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(28.0)),
        padding: EdgeInsets.all(0.0),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          //ACTION
          var result = await Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.downToUp,
              child: PastUpcommingEventScreen(
                isPast: true,
                pastEvents: pastEvents,
                upcomingEvents: upcomingEvents,
              ),
            ),
          );
          if (result != null) {
            var code = result as String;
            bloc.deleteEventFromCode(context, code);
          }
        },
        child: Text(
          'VIEW PAST EVENTS',
          textAlign: TextAlign.center,
          style: AppStyle.style14BoldRed,
        ),
      ),
    );
  }

  StreamBuilder<List<EventRequest>> _buildEventsList() {
    return StreamBuilder(
      stream: bloc.upcomingEventsBloc.stream,
      builder: (BuildContext context,
          AsyncSnapshot<List<EventRequest>> dataUpcoming) {
        upcomingEvents = dataUpcoming?.data ?? [];
        return StreamBuilder(
          stream: bloc.pastEventsBloc.stream,
          builder: (BuildContext context,
              AsyncSnapshot<List<EventRequest>> dataPast) {
            pastEvents = dataPast?.data ?? [];
            return dataUpcoming.hasData
                ? Container(
                    margin: EdgeInsets.only(top: 12, left: 0, right: 0),
                    height: 200,
                    child: upcomingEvents.length == 0
                        ? _buildEmptyEvent(context)
                        : ListView.builder(
                            itemCount: upcomingEvents.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildItemEvent(
                                  context, upcomingEvents[index], index);
                            }),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 12, left: 0, right: 0),
                    height: MediaQuery.of(context).size.height / 3.8,
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      itemCount: 3,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildItemSkeletonEvent(context, index);
                      },
                    ),
                  );
          },
        );
      },
    );
  }

  Widget _buildEmptyEvent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 20, left: 30, right: 30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
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
      child: Text(
        emptyEventText,
        textAlign: TextAlign.center,
        style: AppStyle.style15RegularGrey,
      ),
    );
  }

  Widget _buildItemSkeletonEvent(BuildContext context, int index) {
    Color color = Color.fromRGBO(215, 215, 215, 1);
    return Container(
      margin: EdgeInsets.only(
          top: 0,
          left: index == 0 ? 16 : 0,
          bottom: MediaQuery.of(context).size.height < 667
              ? 28 //AppHelper.getHeightFromScreenSize(context, 28)
              : 28, //40
          right: 16),
      width: 192,
      height: MediaQuery.of(context).size.height / 3.8,
      constraints: BoxConstraints(maxHeight: 172),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(28)),
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
          //NAME EVENT
          Container(
            margin: EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 6),
            height: MediaQuery.of(context).size.height / 30,
            constraints: BoxConstraints(maxHeight: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: _buildShimmer(color, child: null),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildItemAvatarSkeleton(color, width: 32, height: 32),
                )
              ],
            ),
          ),
          //DATE & TIME
          Container(
            margin: EdgeInsets.only(top: 0, left: 28, right: 28),
            height: MediaQuery.of(context).size.height / 13,
            constraints: BoxConstraints(maxHeight: 64),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //DATE
                _buildShimmer(
                  color,
                  child: _buildDateTimeShimmerContainer(context, color),
                ),
                //TIME
                _buildShimmer(color,
                    child: _buildDateTimeShimmerContainer(context, color)),
              ],
            ),
          ),
          //BUILD LINE
          Container(
            margin: EdgeInsets.only(top: 7.5, left: 12, right: 12),
            child: _buildShimmer(
              color,
              child: Container(
                height: 1,
                color: color,
              ),
            ),
          ),
          //BUILD LIST AVATAR
          Container(
            margin: EdgeInsets.only(top: 8, left: 14, right: 14),
            height: 26,
            child: Row(
              children: <Widget>[
                _buildItemAvatarSkeleton(color),
                _buildItemAvatarSkeleton(color),
                _buildItemAvatarSkeleton(color),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _buildDateTimeShimmerContainer(BuildContext context, Color color) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
      height: MediaQuery.of(context).size.height / 13,
      width: MediaQuery.of(context).size.height / 13,
      constraints: BoxConstraints(maxHeight: 64, maxWidth: 64),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 0, left: 0, right: 0),
            height: 15,
            child: Text(
              '',
              style: AppStyle.style8LightRed,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 0, left: 0, right: 0),
            height: 3,
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(top: 0, left: 0, right: 0),
            height: 28,
            child: Text(
              '',
              style: AppStyle.style24RegularRed,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(0.0),
              child: Text(
                '',
                style: AppStyle.style12LightRed,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Shimmer _buildShimmer(Color color, {@required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[50],
      enabled: true,
      child: Container(
        color: color,
        margin: EdgeInsets.only(left: 0),
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Widget _buildItemAvatarSkeleton(Color color,
      {double height = 24, double width = 24}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[50],
      enabled: true,
      child: Container(
        margin: EdgeInsets.all(0),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildItemEvent(BuildContext context, EventRequest event, int index) {
    String monthString = AppHelper.convertDatetoStringWithFormat(
            AppHelper.convertStringToDateWithFormat(
                event.swipeTime, AppConstant.formatTime),
            'MMM')
        .toUpperCase();
    String dayString = AppHelper.convertDatetoStringWithFormat(
            AppHelper.convertStringToDateWithFormat(
                event.swipeTime, AppConstant.formatTime),
            'dd')
        .toUpperCase();
    String weekString = AppHelper.convertDatetoStringWithFormat(
            AppHelper.convertStringToDateWithFormat(
                event.swipeTime, AppConstant.formatTime),
            'EE')
        .toUpperCase();
    String timeString = AppHelper.convertDatetoStringWithFormat(
            AppHelper.convertStringToDateWithFormat(
                event.swipeTime, AppConstant.formatTime),
            'h:mm')
        .toUpperCase();
    String amPmString = AppHelper.convertDatetoStringWithFormat(
            AppHelper.convertStringToDateWithFormat(
                event.swipeTime, AppConstant.formatTime),
            'aa')
        .toUpperCase();
    return Container(
      margin: EdgeInsets.only(
          top: 0,
          left: index == 0 ? 16 : 0,
          bottom: MediaQuery.of(context).size.height < 667
              ? 28 //AppHelper.getHeightFromScreenSize(context, 28)
              : 28, //40
          right: 16),
      width: 192,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(28)),
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
            borderRadius: new BorderRadius.circular(28.0)),
        padding: EdgeInsets.all(0.0),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          //ACTION
          var result = await Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.downToUp,
              child: EventDetailScreen(event: event, type: TypeEvent.QR),
            ),
          );
          if (result != null) {
            var code = result as String;
            bloc.deleteEventFromCode(context, code);
          }
        },
        child: Column(
          children: <Widget>[
            //NAME EVENT
            Container(
              margin: EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 6),
              height: 32,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        event?.name ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.style18RegularGrey,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 0),
                    alignment: Alignment.topRight,
                    child: (event?.isHost ?? false)
                        ? Container(
                            margin: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppHelper.fromHex('#FFC857')
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16)),
                            width: 32,
                            height: 32,
                            child: Image.asset(AppImages.icStar,
                                width: 32, height: 32),
                          )
                        : Container(
                            margin: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            width: 1,
                            height: 32,
                          ),
                  ),
                ],
              ),
            ),
            //DATE & TIME
            Container(
              margin: EdgeInsets.only(top: 0, left: 28, right: 28),
              height: MediaQuery.of(context).size.height / 12,
              constraints: BoxConstraints(
                maxHeight: 64,
              ),
              child: Row(
                children: <Widget>[
                  //DATE
                  Container(
                    margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                    height: MediaQuery.of(context).size.height / 12,
                    width: MediaQuery.of(context).size.height / 12,
                    constraints: BoxConstraints(maxHeight: 64, maxWidth: 64),
                    decoration: BoxDecoration(
                        color: AppHelper.fromHex('#FFC857').withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                          height: 15,
                          child: Text(
                            monthString,
                            style: AppStyle.style8LightRed,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                          height: 3,
                          color: Colors.white,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                          height: 28,
                          child: Text(
                            dayString,
                            style: AppStyle.style24RegularRed,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(0.0),
                            child: Text(
                              weekString,
                              style: AppStyle.style12LightRed,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //TIME
                  Container(
                    margin: EdgeInsets.only(top: 0, left: 8, bottom: 0),
                    width: MediaQuery.of(context).size.height / 12,
                    height: MediaQuery.of(context).size.height / 12,
                    constraints: BoxConstraints(maxHeight: 64, maxWidth: 64),
                    decoration: BoxDecoration(
                        color: AppHelper.fromHex('#FFC857').withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 16, left: 0, right: 0),
                          height: 20,
                          child: Text(
                            timeString,
                            style: AppStyle.style14RegularRed,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                          child: Text(
                            amPmString,
                            style: AppStyle.style12RegularRed,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            //BUILD LINE
            Container(
              margin: EdgeInsets.only(top: 7.5, left: 12, right: 12),
              height: 0.5,
              color: AppHelper.fromHex('#FFC857').withOpacity(0.6),
            ),
            //BUILD LIST AVATAR
            Container(
              margin: EdgeInsets.only(top: 8, left: 14, right: 14),
              height: 28,
              child: ListView.builder(
                  itemCount: event.listUser.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildItemAvatar(context, event.listUser[index]);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemAvatar(BuildContext context, User user) {
    return Container(
      margin: EdgeInsets.all(0),
      height: 28,
      width: 28,
      decoration: BoxDecoration(
          color: AppColor.redColor.withOpacity(0.2),
          borderRadius: BorderRadius.all(Radius.circular(14))),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        child: CachedNetworkImage(
          imageUrl: user.avatarUrl ?? '',
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
    );
  }
}
