import 'package:bflutter/bflutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/pages/event_detail/event_detail_screen.dart';
import 'package:french_fry/pages/past_upcoming_event/past_upcoming_event_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:page_transition/page_transition.dart';

class PastUpcommingEventScreen extends StatefulWidget {
  bool isPast = false;
  List<EventRequest> pastEvents = List<EventRequest>();
  List<EventRequest> upcomingEvents = List<EventRequest>();
  PastUpcommingEventScreen(
      {Key key,
      @required this.isPast,
      @required this.pastEvents,
      @required this.upcomingEvents})
      : super(key: key);

  @override
  _PastUpcommingEventScreenState createState() =>
      _PastUpcommingEventScreenState();
}

class _PastUpcommingEventScreenState extends State<PastUpcommingEventScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = PastUpcommingEventBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void deleteEventFromCode(BuildContext context, String code) {
    for (var i = 0; i < widget.upcomingEvents.length; i++) {
      if (widget.upcomingEvents[i].codeQR == code) {
        widget.upcomingEvents.removeAt(i);
      }
    }
    for (var i = 0; i < widget.pastEvents.length; i++) {
      if (widget.pastEvents[i].codeQR == code) {
        widget.pastEvents.removeAt(i);
      }
    }
    bloc.reloadBloc.push(true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.reloadBloc.stream,
      builder: (BuildContext context, data) {
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
      },
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
              child: Text(widget.isPast ? 'Past Events' : 'Upcoming Events',
                  style: AppStyle.style16RegularWhite),
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
                topLeft: Radius.circular(44), topRight: Radius.circular(44))),
        child: ClipRRect(
          borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(44), topRight: Radius.circular(44)),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 0, bottom: 16),
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.isPast
                          ? widget.pastEvents.length
                          : widget.upcomingEvents.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildItemEvent(
                            context,
                            widget.isPast
                                ? widget.pastEvents[index]
                                : widget.upcomingEvents[index],
                            index);
                      }),
                ),
              ),
              _buildBottomButton(context),
            ],
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
          top: index == 0 ? 16.0 : 0, left: 16.0, bottom: 16.0, right: 16),
      height: 132,
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
          //ACTION
          var result = await Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: EventDetailScreen(event: event, type: TypeEvent.Normal),
            ),
          );
          if (result != null) {
            var code = result as String;
            deleteEventFromCode(context, code);
          }
        },
        child: Column(
          children: <Widget>[
            //NAME EVENT
            Container(
              margin: EdgeInsets.only(left: 24, right: 12, top: 16, bottom: 6),
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        event?.name ?? '',
                        style: AppStyle.style20RegularGrey,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 0),
                    alignment: Alignment.topRight,
                    child: (event?.isHost ?? false) ? Container(
                      margin: EdgeInsets.all(0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppHelper.fromHex('#FFC857').withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16)),
                      width: 32,
                      height: 32,
                      child:
                          Image.asset(AppImages.icStar, width: 32, height: 32),
                    ) : Container(
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
              margin: EdgeInsets.only(
                top: 0,
                left: 24,
              ),
              height: 64,
              child: Row(
                children: <Widget>[
                  //DATE
                  Container(
                    margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                    height: 64,
                    width: 64,
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
                    height: 64,
                    width: 64,
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
                  ),
                  Expanded(child: Container()),
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                      ),
                      //BUILD LIST AVATAR

                      Container(
                        margin: EdgeInsets.only(bottom: 0, right: 14),
                        height: 28,
                        width: 28.0 * event.listUser.length,
                        alignment: Alignment.centerRight,
                        child: ListView.builder(
                            itemCount: event.listUser.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildItemAvatar(
                                  context, event.listUser[index], index);
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemAvatar(BuildContext context, User user, int index) {
    return Container(
      margin: EdgeInsets.all(0),
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: AppColor.redColor.withOpacity(0.2),
        borderRadius: BorderRadius.all(
          Radius.circular(14),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        child: CachedNetworkImage(
          imageUrl: user?.avatarUrl ?? '',
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

  Widget _buildBottomButton(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
        height: 56,
        padding: EdgeInsets.all(0.0),
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 56,
          width: MediaQuery.of(context).size.width - 32,
          margin: EdgeInsets.all(0.0),
          decoration: new BoxDecoration(
            border: Border.all(
              color: AppColor.redColor,
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          child: FlatButton(
            onPressed: () async {
              widget.isPast = !widget.isPast;
              bloc.reloadBloc.push(true);
            },
            padding: EdgeInsets.all(0.0),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(36.0),
            ),
            child: Text(
              widget.isPast ? 'VIEW UPCOMING EVENTS' : 'VIEW PAST EVENTS',
              style: AppStyle.style14BoldRed,
            ),
          ),
        ),
      ),
    );
  }
}
