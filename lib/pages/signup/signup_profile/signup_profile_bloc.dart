import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:french_fry/pages/home/home_screen.dart';
import 'package:path/path.dart';
import 'package:bflutter/bflutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/provider/store/remote/auth_api.dart';

class SignUpProfileBloc with AppBloc {
  final usernameInput = Bloc<String, bool>();
  final validInput = BlocDefault<bool>();
  final authApi = AuthApi();
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();
  String linkAvatar = '';

  SignUpProfileBloc() {
    initLogic();
  }

  @override
  void dispose() {
    validInput.dispose();
    usernameInput.dispose();
    reloadBloc.dispose();
  }

  @override
  void initLogic() {}

  //////////////////////////////////////////////////////////
  ///UPLOAD AVATAR
  //////////////////////////////////////////////////////////
  void upload(BuildContext context, File image, bool isUpdateProfile,
      String username, FirebaseUser _auth) async {
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
      final currentUser = await FirebaseAuth.instance.currentUser();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: currentUser,
          ),
        ),
      );
    });
  }
}
