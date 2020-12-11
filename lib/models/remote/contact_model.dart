import 'package:contacts_service/contacts_service.dart';

class ContactModel {
  String key;
  List<Contact> listContact = [];

  ContactModel(
    this.key,
    this.listContact,
  );
}