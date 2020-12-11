import 'dart:io';

import 'package:bflutter/bflutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/main.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/utils/app_constant.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:path/path.dart';

class HomeBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();
  var loading = BlocDefault<bool>();
  bool isLoad = false;
  String linkAvatar = '';
  var upcomingEventsBloc = BlocDefault<List<EventRequest>>();
  var pastEventsBloc = BlocDefault<List<EventRequest>>();
  List<EventRequest> upcomingEvents = List<EventRequest>();
  List<EventRequest> pastEvents = List<EventRequest>();

  HomeBloc() {
    initLogic();
  }

  @override
  void dispose() {
    reloadBloc.dispose();
  }

  @override
  void initLogic() async {
    /*
    final currentUser = await FirebaseAuth.instance.currentUser();
    FirebaseDatabase database = FirebaseDatabase.instance;
    var child = database
        .reference()
        .child('notifications')
        .child(currentUser.uid)
        .limitToLast(50)
        .onChildAdded
        .listen((data) {
      print(data);
    });*/

    getEvents();
  }

  //////////////////////////////////////////////////////////
  ///GET EVENTS
  //////////////////////////////////////////////////////////
  void getEvents() async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final dbRef = Firestore.instance;
    loading.push(true);
    List<EventRequest> totalEvents = List<EventRequest>();
    upcomingEvents = List<EventRequest>();
    pastEvents = List<EventRequest>();
    var result = await dbRef.collection("events").getDocuments();
    for (var element in result.documents) {
      // element.reference.delete(); // Delete all event
      
      var item = EventRequest.fromJson(element.data);
       item.nameDB = element.documentID;
       item.isHost = item.host == currentUser.uid;
      //Check event contain uid current
      if (item.guests.contains(currentUser.uid) ||
          item.host.contains(currentUser.uid)) {
        List<User> listAvatars = List<User>();
        var result = await dbRef.collection("users").getDocuments();
        var filterHost = result.documents
            .where((element) => element['uid'] == item.host)
            .toList();
        if (filterHost.length > 0) {
          listAvatars.add(User.fromJson(filterHost.first.data));
        }
        for (var element in result.documents) {
          var user = User.fromJson(element.data);
          for (var it in item.guests) {
            if (user.uid == it && it != item.host) {
              listAvatars.add(user);
            }
          }
        }
        item.listUser = listAvatars;
        totalEvents.add(item);
      }
    }
    totalEvents.sort((a, b) {
      var swipeDateA = AppHelper.convertStringToDateWithFormat(
          a.swipeTime, AppConstant.formatTime);
      var swipeDateB = AppHelper.convertStringToDateWithFormat(
          b.swipeTime, AppConstant.formatTime);
      return swipeDateB.compareTo(swipeDateA);
    });

    pastEvents = totalEvents.where((element) {
      var swipeDate = AppHelper.convertStringToDateWithFormat(
          element.swipeTime, AppConstant.formatTime);
      var today = AppHelper.convertStringToDateWithFormat(
          AppHelper.convertDatetoStringWithFormat(
              DateTime.now(), AppConstant.formatTime),
          AppConstant.formatTime);
      return today.isAfter(swipeDate);
    }).toList();

    upcomingEvents = totalEvents.where((element) {
      var swipeDate = AppHelper.convertStringToDateWithFormat(
          element.swipeTime, AppConstant.formatTime);
      var today = AppHelper.convertStringToDateWithFormat(
          AppHelper.convertDatetoStringWithFormat(
              DateTime.now(), AppConstant.formatTime),
          AppConstant.formatTime);
      return !today.isAfter(swipeDate);
    }).toList();
    loading.push(false);
    upcomingEventsBloc.push(upcomingEvents);
    pastEventsBloc.push(pastEvents);
  }


  void deleteEventFromCode(BuildContext context, String code) {
    for (var i = 0; i < upcomingEvents.length; i ++) {
      if (upcomingEvents[i].codeQR == code) {
        upcomingEvents.removeAt(i);
      }
    }
    for (var i = 0; i < pastEvents.length; i ++) {
      if (pastEvents[i].codeQR == code) {
        pastEvents.removeAt(i);
      }
    }
    upcomingEventsBloc.push(upcomingEvents);
    pastEventsBloc.push(pastEvents);
  }

  //////////////////////////////////////////////////////////
  ///UPLOAD AVATAR
  //////////////////////////////////////////////////////////
  void upload(BuildContext context, File image, bool isUpdateProfile,
      String username, FirebaseUser _auth) async {
    loading.push(true);
    isLoad = true;
    Future.delayed(Duration(seconds: 5)).then((value) {
      if (isLoad) {
        isLoad = false;
        loading.push(false);
      }
    });
    linkAvatar = '';
    if (_auth == null) {
      _auth = await FirebaseAuth.instance.currentUser();
    }
    String fileName = basename(image.path);
    StorageReference reference =
        FirebaseStorage.instance.ref().child("avatars/$fileName");
    StorageUploadTask uploadTask = reference.putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var link = await taskSnapshot.ref.getDownloadURL();
    print('RESULT  ' + link);
    linkAvatar = link;
    if (isUpdateProfile) {
      uploadUser(context, username, _auth);
    }
  }

  //////////////////////////////////////////////////////////
  ///UPLOAD USER
  //////////////////////////////////////////////////////////
  void uploadUser(
      BuildContext context, String username, FirebaseUser _auth) async {
    if (_auth == null) {
      _auth = await FirebaseAuth.instance.currentUser();
    }
    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = username;
    if (linkAvatar.length > 0) {
      userUpdateInfo.photoUrl = linkAvatar;
    }

    _auth.updateProfile(userUpdateInfo).then((value) async {
      isLoad = false;
      loading.push(false);
      eventBus.fire(AppConstant.kReloadUser);
    });
  }
}
