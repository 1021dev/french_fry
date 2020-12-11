import 'dart:convert';
import 'dart:io';

import 'package:bflutter/bflutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:french_fry/models/remote/contact_model.dart';
import 'package:french_fry/models/remote/location_model.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/models/remote/request/notification_request.dart';
import 'package:french_fry/models/remote/request/restaurant_request.dart';
import 'package:french_fry/models/remote/restaurant_model.dart';
import 'package:french_fry/models/remote/user.dart';
import 'package:french_fry/pages/congratulation/congratulation_screen.dart';
import 'package:french_fry/pages/swipe/swipe_screen.dart';
import 'package:french_fry/provider/store/remote/notification_api.dart';
import 'package:french_fry/provider/store/remote/search_api.dart';
import 'package:french_fry/provider/store/store.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateEventBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var eventNameBloc = BlocDefault<String>();
  var reloadBloc = BlocDefault<bool>();
  var validInput = BlocDefault<bool>();
  var enableConfirmBloc = BlocDefault<bool>();
  var searchContactBloc = BlocDefault<String>();
  var createEventBloc = BlocDefault<bool>();
  var showAllBloc = BlocDefault<bool>();
  List<RestaurantModel> listRestaurant = List<RestaurantModel>();
  var listRestaurantBLoc = BlocDefault<List<RestaurantModel>>();
  final loading = BlocDefault<bool>();
  var searchLocation = Bloc<String, List<LocationModel>>();
  var searchLatLngLocation = Bloc<LatLng, List<LocationModel>>();
  var getRestaurantBloc = Bloc<RestaurantRequest, List<RestaurantModel>>();
  final searchApi = SearchApi();
  var locationBloc = BlocDefault<LatLng>();
  var currentLocationBloc = BlocDefault<String>();
  var zipCodeBloc = BlocDefault<String>();
  var listContactBloc = BlocDefault<List<ContactModel>>();
  List<ContactModel> listFullContacts = List<ContactModel>();
  List<ContactModel> listSearchContacts = List<ContactModel>();
  EventRequest eventRequest;
  List<String> listAlpha = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '\#',
  ];
  BuildContext context;
  String nameEvent = '';

  CreateEventBloc() {
    initLogic();
  }

  @override
  void dispose() {
    eventNameBloc.dispose();
    reloadBloc.dispose();
    validInput.dispose();
    enableConfirmBloc.dispose();
    searchLocation.dispose();
    searchLatLngLocation.dispose();
    locationBloc.dispose();
    zipCodeBloc.dispose();
    searchContactBloc.dispose();
  }

  @override
  void initLogic() {
    enableConfirmBloc.push(true);

    searchLocation.logic = (Observable<String> input) => input
            .distinct()
            .debounceTime(Duration(milliseconds: 500))
            .flatMap((input) {
          loading.push(true);
          if (input.isEmpty) return Observable.just(null);
          return Observable.fromFuture(searchApi.searchWithKey(input))
              .asyncMap((data) async {
            List<LocationModel> list = data.data['results'] == null
                ? []
                : (data.data['results'] as List)
                    .map((i) => new LocationModel.fromJson(i))
                    .toList();
            if (list.length > 0) {
              return list;
            } else {
              throw (data.data);
            }
          });
        }).handleError((error) {
          loading.push(false);
          AppHelper.showToast("No results found!", this.context);
        }).doOnData((data) {
          loading.push(false);
          if (data.length > 0) {
            locationBloc.push(LatLng(data.first?.geometry?.location?.lat ?? 0,
                data.first?.geometry?.location?.lng ?? 0));
            //FOUND ZIP CODE
            String zipcode = '';
            for (var item in data.last.addressComponents) {
              if (item.types.length > 0) {
                if (item.types.first == "postal_code") {
                  zipcode = item.longName;
                }
              }
            }
            zipCodeBloc.push(zipcode.length > 0 ? zipcode : '94203');
          }
        });

    searchLatLngLocation.logic = (Observable<LatLng> input) => input
            .distinct()
            .debounceTime(Duration(milliseconds: 500))
            .flatMap((input) {
          loading.push(true);
          return Observable.fromFuture(searchApi.searchWithLatLng(input))
              .asyncMap((data) async {
            List<LocationModel> list = data.data['results'] == null
                ? []
                : (data.data['results'] as List)
                    .map((i) => new LocationModel.fromJson(i))
                    .toList();
            if (list.length > 0) {
              return list;
            } else {
              throw (data.data);
            }
          });
        }).handleError((error) {
          loading.push(false);
          // AppHelper.showToast("No results found!", this.context);
        }).doOnData((data) {
          loading.push(false);
          if (data.length > 0) {
            //FOUND ZIP CODE
            String zipcode = '';
            for (var item in data.last.addressComponents) {
              if (item.types.length > 0) {
                if (item.types.first == "postal_code") {
                  zipcode = item.longName;
                }
              }
            }
            zipCodeBloc.push(zipcode.length > 0 ? zipcode : '94203');
          }
        });

    getRestaurantBloc.logic = (Observable<RestaurantRequest> input) => input
            .distinct()
            .debounceTime(Duration(milliseconds: 500))
            .flatMap((input) {
          loading.push(true);
          return Observable.fromFuture(searchApi.searchRestaurant(input))
              .asyncMap((data) async {
            List<RestaurantModel> list = data.data['businesses'] == null
                ? []
                : (data.data['businesses'] as List)
                    .map((i) => new RestaurantModel.fromJson(i))
                    .toList();
            if (list != null) {
              return list;
            } else {
              throw (data.data);
            }
          });
        }).handleError((error) {
          loading.push(false);
          AppHelper.showToaster("No results found!", context);
        }).doOnData((data) {
          loading.push(false);
          listRestaurant = data;
          listRestaurantBLoc.push(data);
        });
  }

  void checkNavigate(BuildContext context) {
    List<Contact> listSelected = List<Contact>();
    for (var i = 0; i < listSearchContacts.length; i++) {
      for (var j = 0; j < listSearchContacts[i].listContact.length; j++) {
        if (listSearchContacts[i].listContact[j].jobTitle == '1') {
          listSelected.add(listSearchContacts[i].listContact[j]);
        }
      }
    }
    if (listSelected.length == 0) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => eventRequest.allowQR
              ? CongratulationScreen(eventRequest: eventRequest)
              : SwipeScreen(eventRequest: eventRequest),
        ),
      );
    }
  }

//////////////////////////////////////////////////////////////////////////////
  ///SEARCH LOCATION
//////////////////////////////////////////////////////////////////////////////
  void searchWithKey(BuildContext context, String key) {
    this.context = context;
    searchLocation.push(key);
  }

  void searchWithLatLng(BuildContext context, LatLng latlng) {
    this.context = context;
    searchLatLngLocation.push(latlng);
  }

  void initContext(BuildContext context) {
    this.context = context;
  }

//////////////////////////////////////////////////////////////////////////////
  ///GET CONTACTS
//////////////////////////////////////////////////////////////////////////////
  void getAllContact(BuildContext context) async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    for (var alpha in listAlpha) {
      var items = contacts
          .where((i) =>
              i.displayName != null &&
              i.displayName.length > 0 &&
              (i.displayName[0] ?? '').toLowerCase() == alpha.toLowerCase() &&
              (i.phones.length > 0) &&
              (i.phones?.first?.value ?? '')
                      .replaceAll('-', '')
                      .replaceAll(')', '')
                      .replaceAll('(', '')
                      .replaceAll(' ', '')
                      .length >
                  0)
          .toList();
      if (items.length > 0) {
        listFullContacts.add(ContactModel(alpha, items));
      }
    }
    listSearchContacts = listFullContacts;
    listContactBloc.push(listSearchContacts);
  }

//////////////////////////////////////////////////////////////////////////////
  ///SELECTED CONTACT
//////////////////////////////////////////////////////////////////////////////
  void selectedContactItem(Contact item) {
    for (var i = 0; i < listSearchContacts.length; i++) {
      for (var j = 0; j < listSearchContacts[i].listContact.length; j++) {
        if (item.identifier ==
            listSearchContacts[i].listContact[j].identifier) {
          listSearchContacts[i].listContact[j].jobTitle =
              (listSearchContacts[i].listContact[j].jobTitle ?? '') != '1'
                  ? '1'
                  : '0';
        }
      }
    }
    checkListSelected(listSearchContacts);
    listContactBloc.push(listSearchContacts);
  }

  void checkListSelected(List<ContactModel> list) {
    List<Contact> listSelected = List<Contact>();
    for (var i = 0; i < list.length; i++) {
      for (var j = 0; j < list[i].listContact.length; j++) {
        if (list[i].listContact[j].jobTitle == '1') {
          listSelected.add(list[i].listContact[j]);
        }
      }
    }
    // createEventBloc.push(listSelected.length > 0);
  }

  void initEventRequestAction(EventRequest request) {
    eventRequest = request;
  }

  void checkSendMessageAction(BuildContext context) async {
    List<Contact> listSelected = List<Contact>();
    for (var i = 0; i < listSearchContacts.length; i++) {
      for (var j = 0; j < listSearchContacts[i].listContact.length; j++) {
        if (listSearchContacts[i].listContact[j].jobTitle == '1') {
          listSelected.add(listSearchContacts[i].listContact[j]);
        }
      }
    }

    final dbRef = Firestore.instance;
    var result = await dbRef.collection("users").getDocuments();
    for (var element in result.documents) {
      // print(element.data);
      for (var i = 0; i < listSelected.length; i++) {
        if (listSelected[i].phones.length > 0 &&
            (element.data['phone'] as String).contains(
                (listSelected[i].phones?.first?.value ?? '')
                    .replaceAll('-', '')
                    .replaceAll(')', '')
                    .replaceAll('(', '')
                    .replaceAll(' ', '')
                    .toString())) {
          //HAVE PHONE IN BATA BASE
          listSelected[i].androidAccountName = "1";
        }
      }
    }
    if (listSelected.length > 0) {
      var filterPhoneInDB = listSelected
          .where((element) => element.androidAccountName == "1")
          .toList();
      var filterPhoneNormal = listSelected
          .where((element) => element.androidAccountName != "1")
          .toList();

      if (filterPhoneInDB.length > 0) {
        // PHONE HAVE DB SEND NOTIFICATION
        print("Send notification to user have this phone");
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
            var filterUserAdd = eventRequest.guests
                .where((element) =>
                    (item.uid == element || item.uid == eventRequest.host))
                .toList();
            var filter = eventRequest.guests
                .where((element) => element == item.uid)
                .toList(); //DUPLICATE CHECK
            if (filterUserAdd.length == 0 && filter.length == 0) {
              eventRequest.guests.add(item.uid);
            }

            var api = NotificationApi();
            var model = NotificationRequest(
                '',
                'You have been invited to ${nameEvent.toString()} by ${currentUser.displayName}. This event is now added to your upcoming events.'
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
        updateDB();
        //CHECK IF CAN'T NAVIGATE
        if (filterPhoneNormal.length == 0) {
          Future.delayed(Duration(milliseconds: 1000)).then((value) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => eventRequest.allowQR
                    ? CongratulationScreen(eventRequest: eventRequest)
                    : SwipeScreen(eventRequest: eventRequest),
              ),
            );
          });
        }
      }
      if (filterPhoneNormal.length > 0) {
        // PHONE NOT HAVE DB SEND SMS
        String message = "This is a test message!";
        List<String> recipents = List<String>();
        for (var item in filterPhoneNormal) {
          if (item.phones.length > 0) {
            recipents.add(item.phones.first.value);
          }
        }
        sendMessage(message, recipents);
      }
    }
  }

  void updateDB() async {
    final nameDB = await DefaultStore.instance.getEventDB();
    final dbRef = Firestore.instance;
    await dbRef
        .collection("events")
        .document(nameDB)
        .updateData(eventRequest.toJson())
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
    String _result = await FlutterSms.sendSMS(
            message:
                "${currentUser.displayName} has invited you to ${nameEvent.toString()} on FrenchFry. Download the app here <link to AppStore>",
            recipients: recipents)
        .catchError((onError) {
      print(onError);
      if (onError.toString().contains('Cannot send message on this device!')) {
        Future.delayed(Duration(milliseconds: 1500)).then((value) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => eventRequest.allowQR
                  ? CongratulationScreen(eventRequest: eventRequest)
                  : SwipeScreen(eventRequest: eventRequest),
            ),
          );
        });
      }
    });
    if (_result != null) {
      if (_result != 'cancelled') {
        AppHelper.showToaster('Sent successful!', context);
        Future.delayed(Duration(milliseconds: 1500)).then((value) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => eventRequest.allowQR
                  ? CongratulationScreen(eventRequest: eventRequest)
                  : SwipeScreen(eventRequest: eventRequest),
            ),
          );
        });
      }
    }
  }

  void initEventName(String eventName) {
    this.nameEvent = eventName;
  }

//////////////////////////////////////////////////////////////////////////////
  ///SEARCH WITH KEY
//////////////////////////////////////////////////////////////////////////////
  void searchContactWithKey(String key) {
    listSearchContacts = [];
    if (key.replaceAll(' ', '').length > 0) {
      List<Contact> contacts = List<Contact>();
      for (var i = 0; i < listFullContacts.length; i++) {
        for (var j = 0; j < listFullContacts[i].listContact.length; j++) {
          if (listFullContacts[i]
              .listContact[j]
              .displayName
              .toLowerCase()
              .contains(key.toLowerCase())) {
            contacts.add(listFullContacts[i].listContact[j]);
          }
        }
      }

      for (var alpha in listAlpha) {
        var items = contacts
            .where((i) =>
                i.displayName != null &&
                i.displayName.length > 0 &&
                (i.displayName[0] ?? '')[0].toLowerCase() ==
                    alpha.toLowerCase() &&
                (i.phones?.single?.value ?? '')
                        .replaceAll('-', '')
                        .replaceAll(')', '')
                        .replaceAll('(', '')
                        .replaceAll(' ', '')
                        .length >
                    0)
            .toList();
        if (items.length > 0) {
          listSearchContacts.add(ContactModel(alpha, items));
        }
      }
      listContactBloc.push(listSearchContacts);
    } else {
      listSearchContacts = listFullContacts;
    }
    listContactBloc.push(listSearchContacts);
  }

//////////////////////////////////////////////////////////////////////////////
  ///MAKE LIST NOT SELECTED
//////////////////////////////////////////////////////////////////////////////
  void makeListFullNotSelected(BuildContext context) {
    for (var i = 0; i < listFullContacts.length; i++) {
      for (var j = 0; j < listFullContacts[i].listContact.length; j++) {
        listFullContacts[i].listContact[j].jobTitle = '0';
      }
    }
    listSearchContacts = listFullContacts;
    listContactBloc.push(listSearchContacts);
  }
}
