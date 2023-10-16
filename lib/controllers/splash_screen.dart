import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/user_profile_api.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initConfig();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_splash_screen);
    startTimer();
  }

  Future<User> getOwnProfile(BuildContext context) async {
    UserProfileApi userProfileApi = UserProfileApi(context);
    return userProfileApi.getOwnUserProfile();
  }

  RemoteConfig _remoteConfig = RemoteConfig.instance;
  Future<void> _initConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(
          seconds: 1), // a fetch will wait up to 30 seconds before timing out
      minimumFetchInterval: Duration(
          seconds:
              30), // fetch parameters will be cached for a maximum of 1 hour
    ));

    _fetchConfig();
  }

  // Fetching, caching, and activating remote config
  void _fetchConfig() async {
    await _remoteConfig.fetchAndActivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.asset(
          Constants.ASSET_IMAGES + "behn_meyer_splash_screen.png",
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  startTimer() {
    Future.delayed(Duration(seconds: 3), () {
      checkLoginState();
      // Navigator.pushReplacementNamed(context, MyRoute.landingRoute);
    });
  }

  checkLoginState() async {
    var accessToken = await AppCache.containValue(AppCache.ACCESS_TOKEN_PREF);
    var refreshToken = await AppCache.containValue(AppCache.REFRESH_TOKEN_PREF);
    if (accessToken && refreshToken) {
      Util.printInfo('got tokens');
      getOwnProfile(context).then((value) async {
        Util.printInfo('got own profile');
        MyApp.setLocale(context, Util.mylocale(value.language));
        if (AppCache.me != null) {
          Util.printInfo('got me');
          FirebaseAnalytics().setUserProperty(
              name: "accountcountry",
              value: (AppCache.me.country != null &&
                      AppCache.me.country.length > 0 &&
                      AppCache.me.country == Constants.COUNTRY_CODE_VIETNAM)
                  ? "Vietnam"
                  : "Malaysia");
          Navigator.pushReplacementNamed(context, MyRoute.homebaseRoute,
              arguments: [_remoteConfig]);
        } else {
          Navigator.pushReplacementNamed(context, MyRoute.landingRoute,
              arguments: [_remoteConfig]);
        }
      }, onError: (error) {
        Util.printInfo('GET PROFILE ERROR: $error');
        Navigator.pushReplacementNamed(context, MyRoute.landingRoute,
            arguments: [_remoteConfig]);
      });
    } else {
      Navigator.pushReplacementNamed(context, MyRoute.landingRoute,
          arguments: [_remoteConfig]);
    }
  }
}
