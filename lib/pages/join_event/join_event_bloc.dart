import 'package:bflutter/bflutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/pages/event_detail/event_detail_screen.dart';
import 'package:french_fry/provider/store/store.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/widgets/transparent_route.dart';

class JoinEventBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();
  var loading = BlocDefault<bool>();

  JoinEventBloc() {
    initLogic();
  }

  @override
  void dispose() {}

  @override
  void initLogic() {}

  Future<void> checkQR(BuildContext context, String first, String second,
      String third, String four) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    if (first.replaceAll(' ', '').isEmpty ||
        second.replaceAll(' ', '').isEmpty ||
        third.replaceAll(' ', '').isEmpty ||
        four.replaceAll(' ', '').isEmpty ||
        third.replaceAll(' ', '').isEmpty) {
      return;
    }
    String codeQR = first.replaceAll(' ', '') +
        second.replaceAll(' ', '') +
        third.replaceAll(' ', '') +
        four.replaceAll(' ', '');

    final dbRef = Firestore.instance;
    EventRequest eventRequest;
    loading.push(true);
    var result = await dbRef.collection("events").getDocuments();

    for (var element in result.documents) {
      // print(element.data);
      if (element.data['codeQR'] == codeQR) {
        DefaultStore.instance.saveEventDB(element.documentID);
        eventRequest = EventRequest.fromJson(element.data);
        eventRequest.nameDB = element.documentID;
        eventRequest.isHost = eventRequest.host == currentUser.uid;
        break;
      }
    }
    loading.push(false);
    if (eventRequest != null) {
      final currentUser = await FirebaseAuth.instance.currentUser();
      var filterEventGuest = eventRequest.guests
          .where((element) => (element == currentUser.uid ||
              currentUser.uid == eventRequest.host))
          .toList();
      if (filterEventGuest.length == 0) {
        eventRequest.guests.add(currentUser.uid);
        updateDB(eventRequest);
      }
      eventRequest.isFromQRScreen = true;
       Navigator.of(context).push(
          TransparentRoute(
            builder: (BuildContext context) =>
                EventDetailScreen(event: eventRequest, type: TypeEvent.QR),
          ),
        );
    } else {
      AppHelper.showToaster('Invalid code.', context);
    }
  }

  void updateDB(EventRequest request) async {
    final nameDB = await DefaultStore.instance.getEventDB();
    final dbRef = Firestore.instance;
    await dbRef
        .collection("events")
        .document(nameDB)
        .updateData(request.toJson())
        .then((_) {
      print("success update event!");
    });
  }
}
