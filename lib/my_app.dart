import 'dart:ui' as ui;
import 'package:bflutter/bflutter.dart';
import 'package:bflutter/libs/bcache.dart';
import 'package:bflutter/provider/main_bloc.dart';
import 'package:bflutter/widgets/app_loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:french_fry/pages/base/notification_handle.dart';
import 'package:french_fry/pages/splash/splash_screen.dart';
import 'package:french_fry/provider/i18n/app_localizations.dart';
import 'package:french_fry/provider/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//////////////////////////////////////////////////////////////////////////////
/// MAIN
//////////////////////////////////////////////////////////////////////////////
Future<void> myMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DefaultStore.instance.init();
  await BCache.instance.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final mainBloc = MainBloc.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  BuildContext contextNo;

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: contextNo,
      builder: (_) => _buildDialog(contextNo, itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(contextNo, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(contextNo, item.route);
    }
  }

  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text("${item.matchteam} with score: ${item.score}"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });
    _firebaseMessaging.subscribeToTopic("matchscore");
  }

  @override
  Widget build(BuildContext context) {
    contextNo = context;
    return StreamBuilder(
        stream: mainBloc.localeBloc.stream,
        builder: (context, snapshot) {
          return MaterialApp(
            locale: (snapshot.hasData
                ? snapshot.data
                : Locale(ui.window.locale?.languageCode ?? ' en')),
            supportedLocales: [
              const Locale('en'),
              const Locale('vi'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: AppContent(),
          );
        });
  }
}

class AppContent extends StatelessWidget {
  final mainBloc = MainBloc.instance;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onAfterBuild(context));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          SplashScreen(),
          StreamBuilder(
            stream: mainBloc.appLoading.stream,
            builder: (context, snapshot) =>
                snapshot.hasData && snapshot.data ? AppLoading() : SizedBox(),
          ),
        ],
      ),
    );
  }

  // After widget initialized.
  void onAfterBuild(BuildContext context) {
    mainBloc.initContext(context);
  }
}
