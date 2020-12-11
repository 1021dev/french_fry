import 'dart:async';

import 'package:bflutter/bflutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sidekick/flutter_sidekick.dart';
import 'package:french_fry/models/remote/category_model.dart';
import 'package:french_fry/models/remote/contact_model.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/models/remote/request/restaurant_request.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/pages/base/custom_switch.dart';
import 'package:french_fry/pages/create_event/create_event_bloc.dart';
import 'package:french_fry/provider/store/store.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:french_fry/utils/debouncer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateEventScreen extends StatefulWidget {
  CreateEventScreen({Key key}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = CreateEventBloc();
  TextEditingController eventController = TextEditingController();
  TextEditingController searchMapController = TextEditingController();
  TextEditingController peopleController = TextEditingController();
  ScrollController mainScrollController = ScrollController();
  ScrollController peopleScrollController = ScrollController();
  MarkerId selectedMarker;
  String currentLocationString = 'Current Location';
  LatLng cameraLocation = LatLng(40.6451594, -74.0850839);
  List<CategoryModel> listDistances = [
    CategoryModel('Any', true),
    CategoryModel('1 mile', false),
    CategoryModel('5 miles', false),
    CategoryModel('10 miles', false)
  ];
  List<CategoryModel> listPrices = [
    CategoryModel('\$', true),
    CategoryModel('\$\$', true),
    CategoryModel('\$\$\$', true),
    CategoryModel('\$\$\$\$', true)
  ];

  List<CategoryModel> listCuisine = [
    CategoryModel('Any Cuisine', false),
  ];
  List<CategoryModel> listCuisineTop = [];
  List<CategoryModel> listCuisineBottom = [
    CategoryModel('American', false),
    CategoryModel('Sushi', false),
    CategoryModel('Vietnamese', false),
    CategoryModel('Japanese', false),
    CategoryModel('Seafood', false),
    CategoryModel('Steakhouse', false),
    CategoryModel('Italian', false),
    CategoryModel('Mexican', false),
    CategoryModel('Chinese', false),
    CategoryModel('Breakfast', false),
    CategoryModel('Vegetarian', false),
    CategoryModel('Greek', false), // CategoryModel('Mediterranean', false),
    CategoryModel('Dessert', false),
    CategoryModel('Mediterranean', false), // CategoryModel('Greek', false),
    CategoryModel('Buffet', false),
    CategoryModel('Fusion', false),
    CategoryModel('Indian', false),
    CategoryModel('Vegan', false),
  ];
  ScrollController _scrollcontroller = ScrollController();
  List<CategoryModel> listCuisineTopFake = [];

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  GoogleMapController controller;
  Position currentLocation;
  DateTime dateStart;
  DateTime dateEnd;
  DateTime dateStartFake = DateTime.now();
  DateTime dateEndFake = DateTime.now();
  bool isCusine = false;
  bool isPeople = false;
  bool isFriend = true;
  bool isQr = true;
  bool isExpanded = false;
  bool isPopup = false;
  bool isTap = false;
  final Debouncer onSearchDebouncer =
      new Debouncer(delay: new Duration(milliseconds: 500));
  String nameDBCreate = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) {
      getLocation();
      bloc.getAllContact(context);
      bloc.createEventBloc.push(true);
    });
  }

  void getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    currentLocation = position;
    cameraLocation = LatLng(currentLocation?.latitude ?? 0, currentLocation.longitude ?? 0);
    print(
        '@@@@@@ Camera LAT ${cameraLocation.latitude} - ${cameraLocation.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    bloc.initContext(context);
    return Scaffold(
      backgroundColor: AppColor.redColor,
      resizeToAvoidBottomInset: false,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: GestureDetector(
          child: StreamBuilder(
            stream: bloc.loading.stream,
            builder: (context, AsyncSnapshot<bool> data) {
              return SingleChildScrollView(
                physics: new NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                controller: peopleScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Hero(
                                  tag: 'BODY_HOME',
                                  child: _buildHeader(context)),
                              _buildBody(context),
                            ],
                          ),
                          AppHelper.buildLoading(data.data ?? false),
                          /////////IS POPUP/////////////
                          isPopup
                              ? Container(
                                  margin: EdgeInsets.all(0),
                                  color: Colors.black.withOpacity(0.2),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              _buildHeaderPeople(context),
                              _buildBodyAddPeople(context),
                            ],
                          ),
                          AppHelper.buildLoading(data.data ?? false),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          onTap: () {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderPeople(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: 56,
        margin: EdgeInsets.only(top: 0, left: 0, right: 0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 0, top: 0, bottom: 0),
              width: 50,
              child: FlatButton(
                padding: EdgeInsets.all(0.0),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (isPeople) {
                    isPeople = false;
                    bloc.searchContactWithKey('');
                    // bloc.createEventBloc.push(false);
                    bloc.createEventBloc.push(true);
                    this.peopleController.text = '';
                    bloc.reloadBloc.push(true);
                    peopleScrollController.animateTo(
                      0.0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    );
                  }
                },
                child: Image.asset(AppImages.icBackWhite, width: 9, height: 16),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: bloc.searchContactBloc.stream,
                builder: (context, AsyncSnapshot<String> dataSearch) {
                  return Container(
                    height: 40,
                    margin: EdgeInsets.only(left: 0, right: 16),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            style: AppStyle.style14RegularWhite,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 12.0,
                                  right: 12.0,
                                  top: 0.0,
                                  bottom: 7.0),
                              hintText: 'Search People from Your Contacts',
                              hintStyle: AppStyle.style14RegularWhite,
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            controller: peopleController,
                            obscureText: false,
                            onChanged: (text) {
                              bloc.searchContactBloc.push(text);
                              if (text == '') {
                                bloc.searchContactWithKey(text);
                              }

                              this.onSearchDebouncer.debounce(
                                () {
                                  bloc.searchContactWithKey(text);
                                },
                              );
                            },
                            onSubmitted: (text) {
                              FocusScope.of(context).unfocus();
                              bloc.searchContactWithKey(text);
                            },
                          ),
                        ),
                        (dataSearch.data ?? '').length > 0
                            ? Container(
                                width: 40,
                                margin: EdgeInsets.only(
                                    top: 0, bottom: 0, right: 0),
                                child: FlatButton(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(0.0),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      peopleController.text = "";
                                      bloc.searchContactBloc.push('');
                                      bloc.searchContactWithKey('');
                                    },
                                    child: Image.asset(AppImages.icClear,
                                        width: 16, height: 16)))
                            : Container()
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
                  FocusScope.of(context).unfocus();
                  if (isCusine) {
                    isCusine = false;
                    isExpanded = false;

                    var filter = listCuisine
                        .where((i) => i.name == 'Any Cuisine')
                        .toList();
                    if (filter.length > 0) {
                      listCuisineTopFake = [];
                    } else {
                      listCuisineTopFake = listCuisine;
                      listCuisineTop = listCuisine;
                    }
                    bloc.reloadBloc.push(true);
                    mainScrollController.animateTo(
                      0.0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Image.asset(AppImages.icBackWhite, width: 9, height: 16),
              ),
            ),
            StreamBuilder(
              stream: bloc.reloadBloc.stream,
              builder: (context, data) {
                return Container(
                  margin: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 0),
                  child: Text(isCusine ? 'Add Cuisines' : 'New Event',
                      style: AppStyle.style16RegularWhite),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////////////////
  ///ADD PEOPLE
  ///////////////////////////////////////////////////////////////////////

  Widget _buildBodyAddPeople(BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 0, left: 0, bottom: 0, right: 0),
            decoration: new BoxDecoration(
                color: AppColor.bgColor,
                borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36))),
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36), topRight: Radius.circular(36)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder(
                      stream: bloc.listContactBloc.stream,
                      builder:
                          (context, AsyncSnapshot<List<ContactModel>> data) {
                        return Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(
                              top: 0, bottom: 0, left: 16, right: 0),
                          child: (data.data ?? []).length > 0
                              ? ListView.builder(
                                  controller: _scrollcontroller,
                                  padding: EdgeInsets.only(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      bottom: MediaQuery.of(context)
                                              .padding
                                              .bottom +
                                          32 +
                                          56),
                                  itemCount: (data.data ?? []).length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _buildItemContact(context,
                                        (data.data ?? [])[index], index);
                                  },
                                )
                              : Container(),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 40,
                    margin: EdgeInsets.only(
                        right: 0,
                        top: AppHelper.getHeightFromScreenSize(
                            context,
                            MediaQuery.of(context).size.height <= 667
                                ? 40
                                : 48)),
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: (bloc.listAlpha).length,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return _buildAlphaItem(
                              context, (bloc.listAlpha)[index], index);
                        }),
                    /*
                    child: Text(
                      'A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ\n\#',
                      textAlign: TextAlign.center,
                      style: MediaQuery.of(context).size.height <= 667
                          ? TextStyle(
                              fontSize: 14.0,
                              height: 1.3,
                              fontFamily: AppFonts.Poppins,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400,
                              color: AppHelper.fromHex('#4C0148'))
                          : TextStyle(
                              fontSize: 16.0,
                              height: 1.25,
                              fontFamily: AppFonts.Poppins,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400,
                              color: AppHelper.fromHex('#4C0148')),
                    ),*/
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Container(
              margin: EdgeInsets.only(left: 0, bottom: 0, right: 0),
              alignment: Alignment.bottomCenter,
              child: _buildCreateEventButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphaItem(BuildContext context, String item, int index) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, right: 0),
      height: MediaQuery.of(context).size.height <= 667 ? 19.3 : 20.3,
      alignment: Alignment.center,
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        child: Text(
          item,
          style: MediaQuery.of(context).size.height <= 667
              ? TextStyle(
                  fontSize: 14.0,
                  fontFamily: AppFonts.Poppins,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: AppHelper.fromHex('#4C0148'))
              : TextStyle(
                  fontSize: 15.5,
                  fontFamily: AppFonts.Poppins,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: AppHelper.fromHex('#4C0148'),
                ),
        ),
        onPressed: () {
          scrollToItem(context, item);
        },
      ),
    );
  }

  void scrollToItem(BuildContext context, String keyItem) {
    double offset = 0;
    bool isHave = false;
    for (var item in bloc.listSearchContacts) {
      if (item.key == keyItem) {
        isHave = true;
        break;
      } else {
        offset += 42.0 + 60.0 * item.listContact.length;
      }
    }
    if (isHave) {
      _scrollcontroller.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildItemContact(BuildContext context, ContactModel item, int index) {
    return Column(
      children: <Widget>[
        Container(
          height: 42,
          margin: EdgeInsets.only(top: 0, left: 0, right: 0),
          child: Container(
            margin: EdgeInsets.only(top: 18, left: 8, right: 0),
            alignment: Alignment.topLeft,
            height: 24,
            child: Text(
              item.key,
              style: AppStyle.style16RegularGrey,
            ),
          ),
        ),
        Container(
          height: 60.0 * item.listContact.length,
          margin: EdgeInsets.all(0.0),
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: (item.listContact).length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return _buildItemContactChild(
                    context, (item.listContact)[index], index);
              }),
        )
      ],
    );
  }

  Widget _buildItemContactChild(BuildContext context, Contact item, int index) {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 0, left: 0, right: 0),
      child: Container(
        height: 52,
        margin: EdgeInsets.only(top: 8, left: 0, right: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: FlatButton(
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(12.0)),
          child: Row(
            children: <Widget>[
              //AVATAR
              /* CUTOMER REQUIRED
              Container(
                height: 36,
                width: 36,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(
                  left: 12,
                ),
                decoration: BoxDecoration(
                    color: AppHelper.fromHex('C6C6C6'), shape: BoxShape.circle),
              ), */

              //USER PHONE NAME
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 12, right: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(item.displayName ?? '',
                      style: AppStyle.style16RegularGrey),
                ),
              ),

              //CHECK
              Container(
                height: 24,
                width: 24,
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  right: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: item.jobTitle == "1"
                          ? AppColor.redColor
                          : AppColor.bgColor),
                  color: item.jobTitle == "1"
                      ? AppColor.redColor
                      : AppColor.bgColor.withOpacity(0.6),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: item.jobTitle == "1"
                    ? Image.asset(AppImages.icCheckWhite,
                        width: 29 / 2, height: 21 / 2)
                    : Container(),
              ),
            ],
          ),
          onPressed: () {
            bloc.selectedContactItem(item);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder(
      stream: bloc.reloadBloc.stream,
      builder: (context, data) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.all(0),
            decoration: new BoxDecoration(
                color: AppColor.bgColor,
                borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36))),
            // child: _buildBodyEvent(context),
            child: SingleChildScrollView(
              physics: new NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              controller: mainScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _buildBodyEvent(context),
                  _buildBodyCusine(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //BODY CUSINE
  Widget _buildBodyCusine(BuildContext context) {
    List<CategoryModel> listShow = [];
    List<CategoryModel> listShowDefault = [];
    if (listCuisineTopFake.length == 0) {
      listShow.addAll(listCuisineBottom);
    } else {
      listShow.addAll(listCuisineBottom);
      for (var it in listCuisineTopFake) {
        listShow.removeWhere((item) => item.name == it.name);
      }
    }
    if (listCuisineTopFake.length > 0) {
      for (var i = listCuisineTopFake.length - 1; i >= 0; i--) {
        listShowDefault.add(listCuisineTopFake[i]);
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: SidekickTeamBuilder<CategoryModel>(
                animationDuration: Duration(milliseconds: 400),
                initialSourceList: listShow,
                initialTargetList: listShowDefault, //listCuisineTopFake,
                builder:
                    (context, sourceBuilderDelegates, targetBuilderDelegates) {
                  //LOGIC IN BOTTOM LIST
                  double widthDouble = MediaQuery.of(context).size.width / 2;
                  double widthThree = MediaQuery.of(context).size.width / 3;
                  for (var i = 0; i < sourceBuilderDelegates.length; i++) {
                    sourceBuilderDelegates[i].message.isRight = false;
                    sourceBuilderDelegates[i].message.isLeft = false;
                    sourceBuilderDelegates[i].message.index = i + 1;
                    //WIDTH BUBBLE
                    if (sourceBuilderDelegates[i].message.index == 4 ||
                        sourceBuilderDelegates[i].message.index == 5 ||
                        sourceBuilderDelegates[i].message.index == 9 ||
                        sourceBuilderDelegates[i].message.index == 10 ||
                        sourceBuilderDelegates[i].message.index == 14 ||
                        sourceBuilderDelegates[i].message.index == 15) {
                      sourceBuilderDelegates[i].message.width = widthDouble;
                    } else {
                      sourceBuilderDelegates[i].message.width = widthThree;
                    }
                    //LEFT RIGHT BUBBLE
                    if (sourceBuilderDelegates[i].message.index == 1 ||
                        sourceBuilderDelegates[i].message.index == 4 ||
                        sourceBuilderDelegates[i].message.index == 6 ||
                        sourceBuilderDelegates[i].message.index == 9 ||
                        sourceBuilderDelegates[i].message.index == 11 ||
                        sourceBuilderDelegates[i].message.index == 14 ||
                        sourceBuilderDelegates[i].message.index == 16) {
                      sourceBuilderDelegates[i].message.isLeft = true;
                    } else if (sourceBuilderDelegates[i].message.index == 3 ||
                        sourceBuilderDelegates[i].message.index == 5 ||
                        sourceBuilderDelegates[i].message.index == 8 ||
                        sourceBuilderDelegates[i].message.index == 10 ||
                        sourceBuilderDelegates[i].message.index == 13 ||
                        sourceBuilderDelegates[i].message.index == 15 ||
                        sourceBuilderDelegates[i].message.index == 18) {
                      sourceBuilderDelegates[i].message.isRight = true;
                    } else {
                      sourceBuilderDelegates[i].message.isRight = false;
                      sourceBuilderDelegates[i].message.isLeft = false;
                    }
                  }
                  //ALL LIST NOT SELECTED
                  for (var i = 0; i < targetBuilderDelegates.length; i++) {
                    targetBuilderDelegates[i].message.isSelected = false;
                  }
                  listCuisineTopFake = [];
                  listCuisineTop = [];
                  int count = 0;
                  double width = 0;
                  bool isFinish = true;
                  List<SidekickBuilderDelegate<CategoryModel>> listItem =
                      List<SidekickBuilderDelegate<CategoryModel>>();
                  List<SidekickBuilderDelegate<CategoryModel>> listItemShow =
                      List<SidekickBuilderDelegate<CategoryModel>>();
                  //LIST REVERSE
                  if (isExpanded) {
                    for (var i = targetBuilderDelegates.length - 1;
                        i >= 0;
                        i--) {
                      targetBuilderDelegates[i].message.sub = '';
                      listItemShow.add(targetBuilderDelegates[i]);
                      listCuisineTopFake.add(targetBuilderDelegates[i].message);
                      /*
                      if ((width +
                              textSize(targetBuilderDelegates[i].message.name,
                                      AppStyle.style14RegularWhite)
                                  .width +
                              48.0) <=
                          (MediaQuery.of(context).size.width - 45)) {
                        width += textSize(
                                  targetBuilderDelegates[i].message.name,
                                  AppStyle.style14RegularWhite)
                              .width +
                          48;
                        listItemShowFake.add(targetBuilderDelegates[i]);
                      } else {
                          isExpanded = false;
                          bloc.reloadBloc.push(true);
                        listItem.add(targetBuilderDelegates[i]);
                      } */
                    }
                  } else {
                    for (var i = targetBuilderDelegates.length - 1;
                        i >= 0;
                        i--) {
                      if ((width +
                                  textSize(
                                          targetBuilderDelegates[i]
                                              .message
                                              .name,
                                          AppStyle.style14RegularWhite)
                                      .width +
                                  48.0) <=
                              (MediaQuery.of(context).size.width - 45) &&
                          isFinish) {
                        count += 1;
                        width += textSize(
                                    targetBuilderDelegates[i].message.name,
                                    AppStyle.style14RegularWhite)
                                .width +
                            48;
                        targetBuilderDelegates[i].message.sub = '';

                        listItemShow.add(targetBuilderDelegates[i]);
                        listCuisineTopFake
                            .add(targetBuilderDelegates[i].message);
                      } else {
                        isFinish = false;
                        listItem.add(targetBuilderDelegates[i]);
                        listCuisineTopFake
                            .add(targetBuilderDelegates[i].message);
                      }
                    }

                    //LOGIC ADD +
                    if (listItem.length > 0 && !isExpanded) {
                      listItem.first.message.sub = "+${listItem.length}";
                      listItemShow.add(listItem.first);
                    }
                  }

                  return Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 72,
                            margin: EdgeInsets.only(top: 0, left: 0, right: 0),
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 233, 191, 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(36))),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(36)),
                              child: Center(
                                  child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  bottom: 15,
                                  top: 15,
                                ),
                                physics: isExpanded
                                    ? ScrollPhysics()
                                    : NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  verticalDirection: VerticalDirection.up,
                                  spacing: 0.0,
                                  runSpacing: 0.0,
                                  direction: Axis.vertical,
                                  children:
                                      listItemShow //targetBuilderDelegates.reversed
                                          .map((builderDelegate) {
                                    return builderDelegate.build(
                                      context,
                                      GestureDetector(
                                        onTap: () {
                                          if (!builderDelegate.message.sub
                                              .contains('+')) {
                                            builderDelegate.state
                                                .move(builderDelegate.message);
                                          } else {
                                            isExpanded = true;
                                            setState(() {});
                                          }
                                        },
                                        child: builderDelegate.message.sub
                                                .contains('+')
                                            ? Container(
                                                height: 40,
                                                width: 45,
                                                margin:
                                                    EdgeInsets.only(right: 0),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 5),
                                                        width: 40,
                                                        height: 40,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppColor.redColor,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Text(
                                                          builderDelegate
                                                              .message.sub,
                                                          style: AppStyle
                                                              .style18RegularWhite,
                                                        )),
                                                    Expanded(
                                                      child: Container(),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Bubble(
                                                item: builderDelegate.message,
                                                image: AppImages.icCheckCuisine,
                                                text: builderDelegate
                                                    .message.name,
                                                backgroundColor: builderDelegate
                                                        .message.isSelected
                                                    ? Colors.white
                                                        .withOpacity(0.0)
                                                    : AppColor.redColor,
                                                foregroundColor: builderDelegate
                                                        .message.isSelected
                                                    ? Colors.white
                                                        .withOpacity(0.0)
                                                    : Colors.white,
                                                child: Row(
                                                  children: <Widget>[
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <=
                                                                375
                                                            ? 5
                                                            : 7),
                                                    Text(
                                                      builderDelegate
                                                          .message.name,
                                                      style: builderDelegate
                                                              .message
                                                              .isSelected
                                                          ? (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <=
                                                                  375
                                                              ? AppStyle
                                                                  .style12RegularWhite0
                                                              : AppStyle
                                                                  .style13RegularWhite0)
                                                          : (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <=
                                                                  375
                                                              ? AppStyle
                                                                  .style12RegularWhite
                                                              : AppStyle
                                                                  .style13RegularWhite),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <=
                                                                375
                                                            ? 3
                                                            : 4),
                                                    builderDelegate
                                                            .message.isSelected
                                                        ? Container(
                                                            width: 15,
                                                            height: 15,
                                                          )
                                                        : Container(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <=
                                                                    375
                                                                ? 13
                                                                : 15,
                                                            height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <=
                                                                    375
                                                                ? 13
                                                                : 15,
                                                            child: Image.asset(
                                                                AppImages
                                                                    .icCheckCuisine,
                                                                width: MediaQuery.of(context)
                                                                            .size
                                                                            .width <=
                                                                        375
                                                                    ? 13
                                                                    : 15,
                                                                height: MediaQuery.of(context)
                                                                            .size
                                                                            .width <=
                                                                        375
                                                                    ? 13
                                                                    : 15),
                                                          ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <=
                                                                375
                                                            ? 5
                                                            : 7),
                                                  ],
                                                ),
                                              ),
                                      ),
                                      animationBuilder: (animation) =>
                                          CurvedAnimation(
                                        parent: animation,
                                        curve: FlippedCurve(Curves.easeOut),
                                      ),
                                      flightShuttleBuilder: (
                                        context,
                                        animation,
                                        type,
                                        from,
                                        to,
                                      ) =>
                                          buildShuttle(
                                              animation,
                                              builderDelegate.message.name,
                                              builderDelegate.message),
                                    );
                                  }).toList(),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              top: AppHelper.getHeightFromScreenSize(
                                  context, 30),
                              left: 0,
                              right: 0,
                              bottom: 0),
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 0,
                                runSpacing: AppHelper.getHeightFromScreenSize(
                                    context, 30),
                                alignment: WrapAlignment.center,
                                children: sourceBuilderDelegates
                                    .map((builderDelegate) {
                                  var bubble = Bubble(
                                    item: builderDelegate.message,
                                    image: AppImages.icAddCuisine,
                                    text: builderDelegate.message.name,
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColor.redColor,
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    375
                                                ? 5
                                                : 7),
                                        Text(
                                          builderDelegate.message.name,
                                          style: MediaQuery.of(context)
                                                      .size
                                                      .width <=
                                                  375
                                              ? AppStyle.style12RegularRed
                                              : AppStyle.style13RegularRed,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    375
                                                ? 3
                                                : 4),
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width <=
                                                  375
                                              ? 13
                                              : 15,
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <=
                                                  375
                                              ? 13
                                              : 15,
                                          child: Image.asset(
                                              AppImages.icAddCuisine,
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width <=
                                                      375
                                                  ? 13
                                                  : 15,
                                              height: 15),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    375
                                                ? 5
                                                : 7),
                                      ],
                                    ),
                                  );
                                  return builderDelegate.build(
                                    context,
                                    GestureDetector(
                                      onTap: () => builderDelegate.state
                                          .move(builderDelegate.message),
                                      child: Container(
                                        width: builderDelegate.message.width,
                                        child: Center(
                                          child: _buildCheckBubble(
                                              builderDelegate.message, bubble),
                                        ),
                                      ),
                                    ),
                                    animationBuilder: (animation) =>
                                        CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    ),
                                    flightShuttleBuilder: (
                                      context,
                                      animation,
                                      type,
                                      from,
                                      to,
                                    ) =>
                                        buildShuttle(
                                            animation,
                                            builderDelegate.message.name,
                                            builderDelegate.message),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          _buildConfirmButton(context)
        ],
      ),
    );
  }

  Widget _buildCheckBubble(CategoryModel model, Widget bubble) {
    if (model.isLeft) {
      return Row(
        children: <Widget>[
          Expanded(child: Container()),
          bubble,
        ],
      );
    } else if (model.isRight) {
      return Row(
        children: <Widget>[
          bubble,
          Expanded(child: Container()),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        bubble,
      ],
    );
  }

  List<Widget> generalWrapList(BuildContext context) {
    return listCuisineBottom
        .map((i) => _buildItemCuisineBottom(
              context,
              i,
            ))
        .toList();
  }

  Widget buildShuttle(
    Animation<double> animation,
    String message,
    CategoryModel item,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Bubble(
          item: item,
          text: message,
          backgroundColor:
              ColorTween(begin: Colors.white, end: AppColor.redColor)
                  .evaluate(animation),
          foregroundColor:
              ColorTween(begin: AppColor.redColor, end: Colors.white)
                  .evaluate(animation),
          child: Row(
            children: <Widget>[
              SizedBox(width: MediaQuery.of(context).size.width <= 375 ? 5 : 7),
              Text(
                message,
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width <= 375 ? 12 : 13.0,
                    fontFamily: AppFonts.Poppins,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: item.isSelected
                        ? AppColor.redColor.withOpacity(0)
                        : ColorTween(
                                begin: AppColor.redColor, end: Colors.white)
                            .evaluate(animation)),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: MediaQuery.of(context).size.width <= 375 ? 3 : 4),
              item.isSelected
                  ? Container(
                      width: MediaQuery.of(context).size.width <= 375 ? 13 : 15,
                      height:
                          MediaQuery.of(context).size.width <= 375 ? 13 : 15,
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width <= 375 ? 13 : 15,
                      height:
                          MediaQuery.of(context).size.width <= 375 ? 13 : 15,
                      child: Image.asset(AppImages.icCheckCuisine,
                          width: MediaQuery.of(context).size.width <= 375
                              ? 13
                              : 15,
                          height: MediaQuery.of(context).size.width <= 375
                              ? 13
                              : 15),
                    ),
              SizedBox(width: MediaQuery.of(context).size.width <= 375 ? 5 : 7),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCuisineBottom(BuildContext context, CategoryModel item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      height: 40,
      child: InkWell(
        onTap: () {
          //NAVIGATE
          FocusScope.of(context).unfocus();
        },
        child: Row(
          children: <Widget>[
            SizedBox(width: 8),
            Text(
              item.name,
              style: AppStyle.style14RegularRed,
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 8),
            Container(
              width: 16,
              height: 16,
              child: Image.asset(AppImages.icAddCuisine, width: 16, height: 16),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return StreamBuilder(
      stream: bloc.enableConfirmBloc.stream,
      builder: (context, AsyncSnapshot<bool> data) {
        if (data.data ?? false) {
          return Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 19, bottom: 32),
            height: 56,
            padding: EdgeInsets.all(0.0),
            alignment: Alignment.topCenter,
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
              width: MediaQuery.of(context).size.width - 32,
              height: 56,
              margin: EdgeInsets.all(0.0),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(Radius.circular(28)),
                color: AppColor.redColor,
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
                  isCusine = false;
                  isExpanded = false;
                  // listCuisineTopFake = [];
                  listCuisineTop = listCuisineTopFake;
                  listCuisine = listCuisineTop;
                  if (listCuisineTop.length == 0) {
                    listCuisine = [
                      CategoryModel('Any Cuisine', false),
                    ];
                  }
                  bloc.reloadBloc.push(true);
                  mainScrollController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                padding: EdgeInsets.all(0.0),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(28.0),
                ),
                child: Text(
                  'CONFIRM',
                  style: AppStyle.style14BoldWhite,
                ),
              ),
            ),
          );
        }
        return Opacity(
          opacity: 0.6,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 19, bottom: 32),
            height: 56,
            alignment: Alignment.center,
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
            child: Text(
              'CONFIRM',
              style: AppStyle.style14BoldWhite,
            ),
          ),
        );
      },
    );
  }

  //BODY EVENT
  Widget _buildBodyEvent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(36), topRight: Radius.circular(36))),
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36), topRight: Radius.circular(36)),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: MediaQuery.of(context).size.height >= 812
              ? NeverScrollableScrollPhysics()
              : ClampingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                height: 44,
                margin: EdgeInsets.only(top: 24, left: 16, right: 16),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: StreamBuilder(
                    stream: bloc.eventNameBloc.stream,
                    builder: (context, AsyncSnapshot<String> data) {
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(
                                  top: 0, left: 12, bottom: 0, right: 0),
                              child: TextField(
                                style: AppStyle.style18RegularRed,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 0.0,
                                      right: 0.0,
                                      top: 0.0,
                                      bottom: 3.0),
                                  hintText: 'Event Name',
                                  hintStyle: AppStyle.style18RegularRed60,
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                controller: eventController,
                                obscureText: false,
                                onChanged: (text) {
                                  bloc.eventNameBloc.push(text);
                                  bloc.reloadBloc.push(true);
                                },
                                onSubmitted: (text) {
                                  var isEnable = listDistances
                                              .where((i) => i.isSelected)
                                              .toList()
                                              .length >
                                          0 &&
                                      listPrices
                                              .where((i) => i.isSelected)
                                              .toList()
                                              .length >
                                          0 &&
                                      listCuisine.length > 0 &&
                                      dateEnd != null &&
                                      dateStart != null &&
                                      text.length > 0;
                                  if (isEnable) {
                                    FocusScope.of(context).unfocus();
                                    //COMPLETE ACTION
                                    isPeople = true;
                                    bloc.searchContactWithKey('');
                                    // bloc.createEventBloc.push(false);
                                    bloc.createEventBloc.push(true);
                                    this.peopleController.text = '';
                                    bloc.makeListFullNotSelected(context);
                                    peopleScrollController.animateTo(
                                      MediaQuery.of(context).size.width,
                                      curve: Curves.linear,
                                      duration:
                                          const Duration(milliseconds: 300),
                                    );
                                    // bloc.reloadBloc.push(true);
                                  }
                                },
                              ),
                            ),
                          ),
                          (data.data ?? '').length > 0
                              ? Container(
                                  width: 40,
                                  margin: EdgeInsets.only(
                                      top: 0, bottom: 0, right: 0),
                                  child: FlatButton(
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        eventController.text = "";
                                        bloc.eventNameBloc.push('');
                                      },
                                      child: Image.asset(AppImages.icClear,
                                          width: 16, height: 16)))
                              : Container()
                        ],
                      );
                    }),
              ),

              //++++++++++++++++++++DISTANCE++++++++++++++++++++
              Container(
                margin: EdgeInsets.only(top: 14, left: 24, right: 16),
                height: 32,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(0.0),
                        child: Text(
                          'Distance From',
                          style: AppStyle.style16RegularGrey,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(0.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          border:
                              Border.all(color: AppColor.redColor, width: 1)),
                      child: FlatButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(12.0)),
                        padding: EdgeInsets.all(0.0),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          //ACTION MAP
                          isPopup = true;
                          bloc.loading.push(false);
                          _buildBottomSheetMap(context);
                          Future.delayed(Duration(seconds: 1)).then((val) {
                            //CURRENT LOCATION
                            markers.clear();
                            _addMarker(cameraLocation.latitude,
                                cameraLocation.longitude,
                                isReload: false);
                            bloc.locationBloc.push(cameraLocation);
                            controller.animateCamera(
                                CameraUpdate.newLatLngZoom(cameraLocation, 15));
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 8, right: 8),
                              alignment: Alignment.centerLeft,
                              child: Image.asset(AppImages.icLocation,
                                  width: 15, height: 20),
                            ),
                            StreamBuilder(
                              stream: bloc.currentLocationBloc.stream,
                              builder: (context, data) {
                                return Container(
                                  margin: EdgeInsets.only(left: 0, right: 8),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      data.data ?? currentLocationString,
                                      style: AppStyle.style14RegularRed),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, left: 0, right: 0),
                height: 32,
                child: ListView.builder(
                    itemCount: listDistances.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItem(
                          context, listDistances[index], index, 0);
                    }),
              ),

              //++++++++++++++++++++PRICE++++++++++++++++++++
              Container(
                margin: EdgeInsets.only(top: 18, left: 24, right: 16),
                height: 24,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Price',
                  style: AppStyle.style16RegularGrey,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, left: 0, right: 0),
                height: 32,
                child: ListView.builder(
                    itemCount: listPrices.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItem(context, listPrices[index], index, 1);
                    }),
              ),

              //++++++++++++++++CUSINE++++++++++++++++++++
              Container(
                margin: EdgeInsets.only(top: 18, left: 24, right: 16),
                height: 24,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cuisine',
                  style: AppStyle.style16RegularGrey,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 4, left: 0, right: 0),
                height: 40,
                // child: InkWell(
                child: ListView.builder(
                    itemCount: listCuisine.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItemCuisine(
                          context, listCuisine[index], index);
                    }),
                //   onTap: () {
                //     FocusScope.of(context).unfocus();
                //     isCusine = true;
                //     mainScrollController.animateTo(
                //       MediaQuery.of(context).size.width,
                //       curve: Curves.easeOut,
                //       duration: const Duration(milliseconds: 300),
                //     );
                //     bloc.reloadBloc.push(true);
                //   },
                // ),
              ),

              //++++++++++++++++EVENT TIME++++++++++++++++++++
              Container(
                margin: EdgeInsets.only(top: 10, left: 24, right: 16),
                height: 24,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Event Time',
                  style: AppStyle.style16RegularGrey,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 6, left: 16, right: 16, bottom: 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                height: 48,
                padding: EdgeInsets.all(0.0),
                child: FlatButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(12.0)),
                  padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    //ACTION CALENDAR
                    isPopup = true;
                    bloc.loading.push(false);
                    _buildBottomSheetCalendar(context, true);
                  },
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateStart == null
                              ? 'Select Time of Event'
                              : AppHelper.convertDatetoStringWithFormat(
                                  dateStart, "EEEE, MMMM dd, h:mm aa"),
                          style: dateStart == null
                              ? AppStyle.style16RegularBlack60
                              : AppStyle.style16RegularGrey,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 17),
                        alignment: Alignment.centerRight,
                        width: 9,
                        height: 5,
                        child: Image.asset(AppImages.icSortGrey,
                            width: 9, height: 5),
                      ),
                    ],
                  ),
                ),
              ),

              //++++++++++++++++EVENT TIME++++++++++++++++++++
              Container(
                margin: EdgeInsets.only(top: 18, left: 24, right: 16),
                height: 24,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Swipe Deadline',
                  style: AppStyle.style16RegularGrey,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 6, left: 16, right: 16, bottom: 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                height: 48,
                padding: EdgeInsets.all(0.0),
                child: FlatButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(12.0)),
                  padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    //ACTION SWIPE
                    isPopup = true;
                    bloc.loading.push(false);
                    _buildBottomSheetCalendar(context, false);
                  },
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateEnd == null
                              ? 'Select Deadline of Event'
                              : AppHelper.convertDatetoStringWithFormat(
                                  dateEnd, "EEEE, MMMM dd, h:mm aa"),
                          style: dateEnd == null
                              ? AppStyle.style16RegularBlack60
                              : AppStyle.style16RegularGrey,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 17),
                        alignment: Alignment.centerRight,
                        width: 9,
                        height: 5,
                        child: Image.asset(AppImages.icSortGrey,
                            width: 9, height: 5),
                      ),
                    ],
                  ),
                ),
              ),

              //++++++++++++++++INVITE FRIEND++++++++++++++++++++
              Container(
                margin:
                    EdgeInsets.only(top: 18, left: 16, right: 16, bottom: 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                height: 48,
                padding: EdgeInsets.all(0.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Allow Guests to Invite Friends",
                        style: AppStyle.style16RegularGrey,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      height: 32,
                      width: 50,
                      margin: EdgeInsets.only(right: 12),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(0.0),
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) async {
                          //HapticFeedback.vibrate();
                          if (details.delta.dx > 0) {
                            isFriend = true;
                            bloc.reloadBloc.push(true);
                          } else if (details.delta.dx < 0) {
                            isFriend = false;
                            bloc.reloadBloc.push(true);
                          }
                        },
                        child: GestureDetector(
                          child: CustomSwitch(
                            onChanged: (isOn) async {
                              //HapticFeedback.vibrate();
                              isFriend = !isFriend;
                              bloc.reloadBloc.push(true);
                            },
                            value: isFriend,
                          ),
                          onTap: () async {
                            //HapticFeedback.vibrate();
                            isFriend = !isFriend;
                            bloc.reloadBloc.push(true);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //++++++++++++++++QR CODE++++++++++++++++++++
              Container(
                margin: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                height: 48,
                padding: EdgeInsets.all(0.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Allow Guests to Join via QR & Event ID",
                        style: AppStyle.style16RegularGrey,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      height: 32,
                      width: 50,
                      margin: EdgeInsets.only(right: 12),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(0.0),
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          //HapticFeedback.vibrate();
                          if (details.delta.dx > 0) {
                            isQr = true;
                            bloc.reloadBloc.push(true);
                          } else if (details.delta.dx < 0) {
                            isQr = false;
                            bloc.reloadBloc.push(true);
                          }
                        },
                        child: GestureDetector(
                          child: CustomSwitch(
                            onChanged: (isOn) {
                              //HapticFeedback.vibrate();
                              isQr = !isQr;
                              bloc.reloadBloc.push(true);
                            },
                            value: isQr,
                          ),
                          onTap: () {
                            //HapticFeedback.vibrate();
                            isQr = !isQr;
                            bloc.reloadBloc.push(true);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCompleteButton(context),
              Container(
                height: MediaQuery.of(context).size.height <= 667 ? 0 : 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateEventButton(BuildContext context) {
    return StreamBuilder(
      stream: bloc.createEventBloc.stream,
      builder: (context, AsyncSnapshot<bool> data) {
        // if (data.data ?? false) {
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
                //CREATE EVENT
                //////////////////////////////
                if (isTap) {
                } else {
                  isTap = true;
                  Future.delayed(Duration(seconds: 1)).then((value) {
                    isTap = false;
                  });
                  createEventAction(context);
                }

                // bloc.checkSendMessageAction(context);
              },
              padding: EdgeInsets.all(0.0),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(28.0),
              ),
              child: Text(
                'CREATE EVENT',
                style: AppStyle.style14BoldWhite,
              ),
            ),
          ),
        );
        // }
        /*
        return Opacity(
          opacity: 0.6,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
            height: 56,
            width: MediaQuery.of(context).size.width - 32,
            alignment: Alignment.center,
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
            child: Text(
              'CREATE EVENT',
              style: AppStyle.style14BoldWhite,
            ),
          ),
        );*/
      },
    );
  }

  void createEventAction(BuildContext context) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    var deviceToken = await _firebaseMessaging.getToken();
    final currentUser = await FirebaseAuth.instance.currentUser();
    var modelUser = User(
        uid: currentUser.uid,
        avatarUrl: currentUser.photoUrl,
        phone: currentUser.phoneNumber,
        username: currentUser.displayName,
        deviceToken: deviceToken);

    var distance = listDistances.where((i) => i.isSelected).toList();
    List<String> prices = List<String>();
    List<String> cuisines = List<String>();
    var filterPrices = listPrices.where((i) => i.isSelected).toList();
    for (var item in filterPrices) {
      prices.add(item.name);
    }
    var filterCuisines = listCuisine;
    for (var item in filterCuisines) {
      cuisines.add(item.name);
    }
    bloc.initEventName(eventController.text ?? '');

    var model = EventRequest(
      eventController.text ?? '',
      cameraLocation.latitude,
      cameraLocation.longitude,
      distance.first.name,
      prices,
      cuisines,
      AppHelper.convertDatetoStringWithFormat(
          dateStart, AppConstant.formatTime),
      AppHelper.convertDatetoStringWithFormat(dateEnd, AppConstant.formatTime),
      isFriend,
      isQr,
      bloc.listRestaurant,
      AppHelper.random4Number(),
      [SwipeModel(restaurants: [], user: modelUser.uid)],
      [],
      currentUser.uid,
    );
    bloc.loading.push(true);
    final dbRef = Firestore.instance;
    if (nameDBCreate == '') {
      //CHECK IF CREATE DATABASE
      await dbRef.collection('events').add(model.toJson()).then((val) {
        nameDBCreate = val.documentID;
        print('RESULT NAME DB EVENT :: ${val.documentID}');
        DefaultStore.instance.saveEventDB(val.documentID);
        bloc.initEventRequestAction(model);
        bloc.checkNavigate(context);
        bloc.loading.push(false);
        bloc.checkSendMessageAction(context);
      });
    } else {
      // HAVE CREATE DATABASE
      bloc.initEventRequestAction(model);
      bloc.checkNavigate(context);
      bloc.loading.push(false);
      bloc.checkSendMessageAction(context);
    }
  }

  Widget _buildCompleteButton(BuildContext context) {
    return StreamBuilder(
      stream: bloc.reloadBloc.stream,
      builder: (context, data) {
        var isEnable =
            listDistances.where((i) => i.isSelected).toList().length > 0 &&
                listPrices.where((i) => i.isSelected).toList().length > 0 &&
                listCuisine.length > 0 &&
                dateEnd != null &&
                dateStart != null &&
                eventController.text.length > 0;
        if (isEnable) {
          return Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 19, bottom: 32),
            height: 56,
            padding: EdgeInsets.all(0.0),
            alignment: Alignment.topCenter,
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
              width: MediaQuery.of(context).size.width - 32,
              height: 56,
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
                  //COMPLETE ACTION
                  isPeople = true;
                  bloc.searchContactWithKey('');
                  // bloc.createEventBloc.push(false);
                  bloc.createEventBloc.push(true);
                  this.peopleController.text = '';
                  bloc.makeListFullNotSelected(context);
                  peopleScrollController.animateTo(
                    MediaQuery.of(context).size.width,
                    curve: Curves.linear,
                    duration: const Duration(milliseconds: 300),
                  );

                  //CALL API GET RESTAURANT
                  String priceText = '';
                  var priceFilter = listPrices
                      .where((element) => element.isSelected)
                      .toList();
                  for (var item in priceFilter) {
                    if (priceText == '') {
                      priceText = item.name.length.toString();
                    } else {
                      priceText += ',${item.name.length.toString()}';
                    }
                  }

                  int radius = 0;
                  var filterDistance = listDistances
                      .where((element) => element.isSelected)
                      .toList();
                  if (filterDistance.length > 0) {
                    if (filterDistance.first.name.contains('1')) {
                      radius = 1609;
                    } else if (filterDistance.first.name.contains('5')) {
                      radius = 1609 * 5;
                    } else if (filterDistance.first.name.contains('10')) {
                      radius = 1609 * 10;
                    }
                  }

                  String cuisineCategory = '';
                  for (var item in listCuisine) {
                    if (cuisineCategory == '' &&
                        !item.name.toLowerCase().contains('any')) {
                      cuisineCategory = AppHelper.checkKeyCuisine(item.name);
                    } else if (cuisineCategory != '') {
                      cuisineCategory +=
                          ',${AppHelper.checkKeyCuisine(item.name)}';
                    }
                  }

                  print(
                      '@@@@@@@ FINAL CALL API LAT ${cameraLocation.latitude} - ${cameraLocation.longitude}');

                  bloc.getRestaurantBloc.push(
                    RestaurantRequest(
                      cameraLocation.latitude,
                      cameraLocation.longitude,
                      'restaurants',
                      priceText,
                      radius,
                      cuisineCategory,
                      dateStart.millisecondsSinceEpoch ~/ 1000.0, //To seconds
                    ),
                  );
                  // createEventAction(context);
                },
                padding: EdgeInsets.all(0.0),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(28.0),
                ),
                child: Text(
                  'NEXT STEP',
                  style: AppStyle.style14BoldWhite,
                ),
              ),
            ),
          );
        }
        return Opacity(
          opacity: 0.6,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 19, bottom: 32),
            height: 56,
            alignment: Alignment.center,
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
            child: Text(
              'NEXT STEP',
              style: AppStyle.style14BoldWhite,
            ),
          ),
        );
      },
    );
  }

  //////////////////////////////////BUILD ITEM LIST/////////////////////////////

  Widget _buildItemCuisine(
      BuildContext context, CategoryModel item, int index) {
    return Container(
      margin: EdgeInsets.only(
          top: 4, left: index == 0 ? 16 : 0, right: 8, bottom: 4),
      decoration: BoxDecoration(
        color: AppColor.redColor,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(250, 141, 53, 0.1),
            blurRadius: 16.0,
            spreadRadius: 1.0,
            offset: Offset(
              0.0,
              8.0,
            ),
          ),
        ],
      ),
      height: 32,
      padding: EdgeInsets.all(0.0),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          //NAVIGATE
          FocusScope.of(context).unfocus();
          isCusine = true;
          listCuisineTop = listCuisine;
          mainScrollController.animateTo(
            MediaQuery.of(context).size.width,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          bloc.reloadBloc.push(true);
        },
        child: Row(
          children: <Widget>[
            SizedBox(width: 8),
            Text(
              item.name,
              style: AppStyle.style14RegularWhite,
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 8),
            Container(
              width: 16,
              height: 16,
              child: FlatButton(
                shape: CircleBorder(),
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  /*
                  //REMOVE ITEM
                  FocusScope.of(context).unfocus();
                  listCuisine.removeAt(index);
                  bloc.reloadBloc.push(true);
                  */
                  FocusScope.of(context).unfocus();
                  isCusine = true;
                  mainScrollController.animateTo(
                    MediaQuery.of(context).size.width,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  );
                  bloc.reloadBloc.push(true);
                },
                child: Image.asset(AppImages.icRemove, width: 16, height: 16),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, CategoryModel item, int index, int mode) {
    //Mode : 0: distance, 1: price |
    return Container(
      margin: EdgeInsets.only(
          top: 0, left: index == 0 ? 16 : 0, right: 8, bottom: 0),
      decoration: BoxDecoration(
        color: item.isSelected ? AppColor.redColor : Colors.white,
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
      width: (MediaQuery.of(context).size.width - 16 - 32) / 4,
      height: 32,
      padding: EdgeInsets.all(0.0),
      alignment: Alignment.center,
      child: FlatButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(12.0)),
        padding: EdgeInsets.all(0.0),
        onPressed: () {
          FocusScope.of(context).unfocus();
          //OPEN MAP
          if (mode == 0) {
            for (var i = 0; i < listDistances.length; i++) {
              listDistances[i].isSelected = false;
            }
            listDistances[index].isSelected = !listDistances[index].isSelected;
          } else if (mode == 1) {
            listPrices[index].isSelected = !listPrices[index].isSelected;
          }
          bloc.reloadBloc.push(true);
        },
        child: Text(
          item.name,
          style: item.isSelected
              ? AppStyle.style14RegularWhite
              : AppStyle.style14RegularRed,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///CALENDAR
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void _buildBottomSheetCalendar(BuildContext context, bool isStart) {
    showCupertinoModalPopup(
      //ShowDialog(
      context: context,
      builder: (BuildContext ct) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.01),
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            child: new Container(
              child: SafeArea(
                top: false,
                bottom: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28)),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: Text(isStart ? 'Event' : 'Swipe Deadline',
                                style: AppStyle.style16MediumRed),
                          ),
                          _buildLine(context),
                          Container(
                            margin: EdgeInsets.all(0.0),
                            height: 224,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.dateAndTime,
                              initialDateTime: isStart
                                  ? (dateStart ?? DateTime.now())
                                  : (dateEnd ?? DateTime.now()),
                              onDateTimeChanged: (newDateTime) {
                                if (isStart) {
                                  dateStartFake = newDateTime;
                                } else {
                                  dateEndFake = newDateTime;
                                }
                              },
                            ),
                          ),
                          _buildLine(context),
                          //CANCEL
                          Container(
                            margin: EdgeInsets.all(0.0),
                            height: 48,
                            child: FlatButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.only(
                                      bottomLeft: Radius.circular(28),
                                      bottomRight: Radius.circular(28))),
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                isPopup = false;
                                bloc.loading.push(false);
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.only(left: 0, right: 8),
                                  alignment: Alignment.center,
                                  child: Text('CANCEL',
                                      style: AppStyle.style14BoldRed),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //CONFIRM ACTION
                    Container(
                      margin: EdgeInsets.only(
                          left: 16, right: 16, bottom: 10, top: 16),
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
                          isPopup = false;
                          bloc.loading.push(false);
                          //CONFIRM
                          Navigator.of(context).pop();
                          if (isStart) {
                            dateStart = dateStartFake;
                          } else {
                            dateEnd = dateEndFake;
                          }
                          bloc.reloadBloc.push(true);
                        },
                        child: Text(
                          'CONFIRM',
                          textAlign: TextAlign.center,
                          style: AppStyle.style14BoldRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
        );
      },
    );
  }

  Widget _buildLine(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, right: 0),
      color: Colors.black.withOpacity(0.2),
      height: 0.5,
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///GOOGLE MAP
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void _buildBottomSheetMap(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.01),
          resizeToAvoidBottomInset: false,
          body: StreamBuilder(
            stream: bloc.loading.stream,
            builder: (context, AsyncSnapshot<bool> loading) {
              return Stack(
                children: <Widget>[
                  StreamBuilder(
                    stream: bloc.reloadBloc.stream,
                    builder: (context, data) {
                      return Scaffold(
                        backgroundColor: Colors.black.withOpacity(0.01),
                        resizeToAvoidBottomInset: false,
                        body: GestureDetector(
                          child: new Container(
                            child: SafeArea(
                              top: false,
                              bottom: true,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                      bottom: 16,
                                    ),
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: new BorderRadius.only(
                                          topLeft: Radius.circular(28),
                                          topRight: Radius.circular(28),
                                          bottomLeft: Radius.circular(44),
                                          bottomRight: Radius.circular(44)),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 44,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          margin: EdgeInsets.only(
                                              top: 16, left: 16, right: 16),
                                          decoration: BoxDecoration(
                                              color: AppColor.redColor
                                                  .withOpacity(0.2),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: 0,
                                                left: 12,
                                                bottom: 0,
                                                right: 0),
                                            child: TextField(
                                              style: AppStyle.style16RegularRed,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 0.0,
                                                        right: 0.0,
                                                        top: 0.0,
                                                        bottom: 3.0),
                                                hintText:
                                                    'Enter ZIP Code, State, City...',
                                                hintStyle:
                                                    AppStyle.style16RegularRed,
                                                border: InputBorder.none,
                                              ),
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.search,
                                              controller: searchMapController,
                                              obscureText: false,
                                              onChanged: (text) {
                                                //TEXT
                                              },
                                              onSubmitted: (text) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                if (text
                                                        .replaceAll(' ', '')
                                                        .length >
                                                    2) {
                                                  bloc.searchWithKey(
                                                      context, text);
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        //CURRENT LOCATION
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 8,
                                          ),
                                          height: 48,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          decoration: new BoxDecoration(
                                            border: Border.all(
                                                color: AppColor.redColor,
                                                width: 1),
                                            borderRadius: new BorderRadius.all(
                                                Radius.circular(12)),
                                          ),
                                          child: FlatButton(
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        12.0)),
                                            padding: EdgeInsets.all(0.0),
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                              //CURRENT LOCATION
                                              markers.clear();
                                              cameraLocation = LatLng(
                                                  currentLocation?.latitude ??
                                                      0,
                                                  currentLocation.longitude ??
                                                      0);
                                              _addMarker(
                                                  cameraLocation.latitude,
                                                  cameraLocation.longitude,
                                                  isReload: false);
                                              bloc.locationBloc
                                                  .push(cameraLocation);
                                              controller.animateCamera(
                                                  CameraUpdate.newLatLngZoom(
                                                      cameraLocation, 15));
                                              bloc.zipCodeBloc
                                                  .push(currentLocationString);
                                            },
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 8, right: 8),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Image.asset(
                                                        AppImages.icLocation,
                                                        width: 15,
                                                        height: 20),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 0, right: 8),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        'CURRENT LOCATION',
                                                        style: AppStyle
                                                            .style14BoldRed),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        //MAP SCREEN
                                        StreamBuilder(
                                          stream: bloc.locationBloc.stream,
                                          builder: (context,
                                              AsyncSnapshot<LatLng> data) {
                                            if (data.hasData) {
                                              //CURRENT LOCATION
                                              markers.clear();
                                              cameraLocation = LatLng(
                                                  data.data?.latitude ?? 0,
                                                  data.data?.longitude ?? 0);
                                              _addMarker(
                                                  cameraLocation.latitude,
                                                  cameraLocation.longitude,
                                                  isReload: false);
                                              controller.animateCamera(
                                                  CameraUpdate.newLatLngZoom(
                                                      cameraLocation, 15));
                                            }
                                            return Container(
                                              margin: EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  bottom: 16,
                                                  top: 8),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  32,
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      32) *
                                                  280 /
                                                  343,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(28))),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                                child: GoogleMap(
                                                  onMapCreated: _onMapCreated,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: cameraLocation,
                                                    zoom: 15.0,
                                                  ),
                                                  markers: Set<Marker>.of(
                                                      markers.values),
                                                  myLocationEnabled: true,
                                                  myLocationButtonEnabled:
                                                      false,
                                                  onTap: (position) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    /* Remove tap on map
                                                  markers.clear();
                                                  cameraLocation = position;
                                                  bloc.searchWithLatLng(context, cameraLocation);
                                                  _addMarker(
                                                      cameraLocation.latitude,
                                                      cameraLocation.longitude,
                                                      isReload: false);
                                                  bloc.locationBloc
                                                      .push(cameraLocation);
                                                  controller.animateCamera(
                                                      CameraUpdate
                                                          .newLatLngZoom(
                                                              cameraLocation,
                                                              15));
                                                              */
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  //PIC ACTION
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 16, right: 16, bottom: 10),
                                    height: 56,
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    decoration: new BoxDecoration(
                                      color: AppHelper.fromHex('FFC857'),
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(28)),
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
                                    child: StreamBuilder(
                                      stream: bloc.zipCodeBloc.stream,
                                      builder: (context, data) {
                                        return FlatButton(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      28.0)),
                                          padding: EdgeInsets.all(0.0),
                                          onPressed: () {
                                            FocusScope.of(context).unfocus();
                                            isPopup = false;
                                            bloc.loading.push(false);
                                            Navigator.of(context).pop();
                                            if (data.hasData) {
                                              bloc.currentLocationBloc
                                                  .push(data.data ?? '');
                                            }
                                          },
                                          child: Text(
                                            'PICK LOCATION',
                                            textAlign: TextAlign.center,
                                            style: AppStyle.style14BoldRed,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      );
                    },
                  ),
                  AppHelper.buildLoading(loading.data ?? false)
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _addMarker(double lat, double lng, {bool isReload = true}) {
    int markerCount = markers.length;
    final String markerIdVal = 'marker_id_$markerCount';
    markerCount++;
    final MarkerId markerId = MarkerId(markerIdVal);

    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        lat,
        lng,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );
    markers[markerId] = marker;
    if (isReload) {
      bloc.reloadBloc.push(true);
    }
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      if (markers.containsKey(selectedMarker)) {
        final Marker resetOld = markers[selectedMarker]
            .copyWith(iconParam: BitmapDescriptor.defaultMarker);
        markers[selectedMarker] = resetOld;
      }
      selectedMarker = markerId;
      final Marker newMarker = tappedMarker.copyWith(
        iconParam: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );
      markers[markerId] = newMarker;
    }
    bloc.reloadBloc.push(true);
  }

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  static Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}

class Bubble extends StatelessWidget {
  const Bubble({
    Key key,
    this.item,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.text,
    this.image,
  }) : super(key: key);

  final Widget child;
  final String text;
  final Color backgroundColor;
  final String image;
  final Color foregroundColor;
  final CategoryModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40,
        margin: EdgeInsets.only(left: 4, right: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          /* https://trello.com/c/wvNMpgxR/78-there-is-still-a-color-haze-when-adding-cuisines-on-this-screen
          boxShadow: [
            BoxShadow(
              color: (item.isSelected ?? false)
                  ? Color.fromRGBO(250, 141, 53, 0)
                  : Color.fromRGBO(250, 141, 53, 0.3),
              blurRadius: 16.0,
              spreadRadius: 1.0,
              offset: Offset(
                0.0,
                8.0,
              ),
            ),
          ],*/
        ),
        child: child);
  }
}
