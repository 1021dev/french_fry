import 'package:bflutter/bflutter.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/contact_model.dart';

class ContactBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();
  var createEventBloc = BlocDefault<bool>();
  var searchContactBloc = BlocDefault<String>();
  final loading = BlocDefault<bool>();
  var listContactBloc = BlocDefault<List<ContactModel>>();
  List<ContactModel> listFullContacts = List<ContactModel>();
  List<ContactModel> listSearchContacts = List<ContactModel>();
  List<Contact> listSelected = List<Contact>();
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

  ContactBloc() {
    initLogic();
  }

  @override
  void dispose() {
    searchContactBloc.dispose();
  }

  @override
  void initLogic() {}

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
              (i.displayName[0] ?? '')[0].toLowerCase() ==
                  alpha.toLowerCase() && (i.phones.length > 0) &&
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
    listSelected = List<Contact>();
    for (var i = 0; i < list.length; i++) {
      for (var j = 0; j < list[i].listContact.length; j++) {
        if (list[i].listContact[j].jobTitle == '1') {
          listSelected.add(list[i].listContact[j]);
        }
      }
    }
    // createEventBloc.push(listSelected.length > 0);
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
                    alpha.toLowerCase() && (i.phones.length > 0) &&
                (i.phones?.first?.value ?? '')
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

//////////////////////////////////////////////////////////////////////////////
  ///LIST SELECTED
//////////////////////////////////////////////////////////////////////////////
  void addContact(BuildContext context) {
    Navigator.of(context).pop(listSelected);
  }
}
