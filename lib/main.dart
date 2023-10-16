import 'dart:convert';

import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/localization.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/controllers/tab/homebase.dart';
import 'package:behn_meyer_flutter/dio/api/touch_api.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'cache/appcache.dart';
import 'routes/my_route.dart';

// void main() {
//   runApp(MyApp());
// }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Util.printInfo("*** Background Message : ${message.data}");
  Util.printInfo(
      "*** Background Message Title : ${message.notification.title}");
  Util.printInfo("*** Background Message Body : ${message.notification.body}");
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyApp state = context.findAncestorStateOfType<_MyApp>();
    state.setLocale(newLocale);
  }

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void configEasyLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.light
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.grey
      ..backgroundColor = Colors.white
      ..indicatorColor = Colors.grey
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  @override
  void initState() {
    super.initState();
    configEasyLoading();

    var initializationSettingAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingAndroid);

    Future selectNotification(String payload) async {
      //Handle notification tapped logic here
      Util.printInfo("*** onTap Notification Bar: $payload");
      // navigatorKey.currentState.pushNamed(MyRoute.homebaseRoute);
      navigatorKey.currentState.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeBase()),
          (Route<dynamic> route) => false);
    }

    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: selectNotification);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Util.printInfo("FCM Listen onMessage: ${message.notification.title}");
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android?.smallIcon,
              ),
            ),
            payload: json.encode(message.data));
      } else {
        // flutterLocalNotificationsPlugin.show(notification.hashCode,
        //     notification.title, notification.body, NotificationDetails(),
        //     payload: json.encode(message.data));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Util.printInfo("****** ON MESSAGE OPENED APP ******");
      navigatorKey.currentState.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeBase()),
          (Route<dynamic> route) => false);
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light) // Or Brightness.dark
        );

    // getFcmToken();
  }

  @override
  void didChangeDependencies() {
    if (AppCache.me != null) {
      setState(() {
        this._locale = Util.mylocale(AppCache.me.language);
      });
    } else {
      setState(() {
        this._locale = Util.mylocale(Constants.ENGLISH);
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Behn Meyer',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      onGenerateRoute: MyRoute.generatedRoute,
      initialRoute: MyRoute.splashScreenRoute,
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[observer],
      locale: _locale,
      supportedLocales: [
        Locale("en"),
        Locale("id"),
        Locale("zh"),
        Locale("vi"),
      ],
      localizationsDelegates: [
        MyLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      builder: (context, child) {
        return MediaQuery(
          child: FlutterEasyLoading(
            child: child,
          ),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      // home: SplashScreen(),
    );
  }

  void getFcmToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    Util.printInfo("FCM TOKEN: $token");
    var accessToken = await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    var refreshToken = await AppCache.containValue(AppCache.REFRESH_TOKEN_PREF);
    if (accessToken && refreshToken) {
      callTouch(token);
    }
  }

  void callTouch(String fcmToken) {
    var bodyData = {'notificationToken': fcmToken};
    TouchApi touchApi = TouchApi(context, bodyData: bodyData);
    touchApi.call().then((value) {}).catchError((error) {});
  }
}
