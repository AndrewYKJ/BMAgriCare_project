import 'dart:io';

import 'package:behn_meyer_flutter/const/localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_color.dart';
import 'app_font.dart';
import 'constants.dart';

class Util {
  static printInfo(Object object) {
    if (Constants.isDebug) {
      print(object);
    }
  }

  static void showAlertDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(Util.getTranslated(context, 'alert_dialog_ok_text')),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static Locale mylocale(String languageCode) {
    switch (languageCode) {
      case Constants.LANGUAGE_CODE_EN:
        return Locale(Constants.ENGLISH);
      case Constants.LANGUAGE_CODE_BM:
        return Locale(Constants.INDONESIA);
      case Constants.LANGUAGE_CODE_CN:
        return Locale(Constants.CHINESE);
      case Constants.LANGUAGE_CODE_VT:
        return Locale(Constants.VIETNAMESE);
      default:
        return Locale(Constants.ENGLISH);
    }
  }

  static String appLanguage(BuildContext context, String languageCode) {
    switch (languageCode) {
      case Constants.LANGUAGE_CODE_EN:
        return getTranslated(context, "setting_language_en");
      case Constants.LANGUAGE_CODE_BM:
        return getTranslated(context, "setting_language_id");
      case Constants.LANGUAGE_CODE_CN:
        return getTranslated(context, "setting_language_zh");
      case Constants.LANGUAGE_CODE_VT:
        return "Vietnamese";
      default:
        return "";
    }
  }

  static String getTranslated(BuildContext context, String key) {
    return MyLocalization.of(context).translate(key);
  }

  static String toUpperCase(String str) {
    return str.toUpperCase();
  }

  static void checkAppVersion(
      BuildContext context, RemoteConfig _remoteConfig) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    var latestAppVersion = _remoteConfig.getString('app_version');
    var updateUrl = _remoteConfig.getString('url');
    var forceUpdateEnabled = _remoteConfig.getBool('force_update_enabled');

    // var compare = appVersion.toString().compareTo(latestAppVersion.toString());
    var isVersionGreater = isVersionGreaterThan(latestAppVersion, appVersion);

    Util.printInfo(
        'CURRENT APP VERSION: $appVersion || LATEST APP VERSION: $latestAppVersion || UPDATE URL: $updateUrl');
    Util.printInfo('FORCE UPDATE ENABLED: $forceUpdateEnabled');
    // Util.printInfo("COMPARE NEW with OLD VERSION: $compare");
    Util.printInfo("IS VERSION GREATER: $isVersionGreater");

    if (isVersionGreater) {
      // currentVersion is lower
      Util.printInfo('currentVersion is lower');
      if (Platform.isIOS) {
        Util.printInfo("isIOS");
        try {
          if (forceUpdateEnabled) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => new CupertinoAlertDialog(
                title: new Text(
                    Util.getTranslated(context, 'update_dialog_title')),
                content: new Text(
                    Util.getTranslated(context, 'update_dialog_forceVer_ios')),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(Util.getTranslated(
                        context, 'alert_dialog_cancel_text')),
                    onPressed: () {
                      Navigator.pop(context);
                      exit(0);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(Util.getTranslated(
                        context, 'update_dialog_update_text')),
                    onPressed: () {
                      _launchBrowser(updateUrl);
                    },
                  ),
                ],
              ),
            );
          } else {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => new CupertinoAlertDialog(
                title: new Text(
                    Util.getTranslated(context, 'update_dialog_title')),
                content: new Text(
                    Util.getTranslated(context, 'update_dialog_newVer_ios')),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(Util.getTranslated(
                        context, 'alert_dialog_cancel_text')),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(Util.getTranslated(
                        context, 'update_dialog_update_text')),
                    onPressed: () {
                      _launchBrowser(updateUrl);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          print(e.toString());
        }
      } else {
        try {
          if (forceUpdateEnabled) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => new WillPopScope(
                  child: new AlertDialog(
                    title: new Text(
                      Util.getTranslated(context, 'update_dialog_title'),
                      style: AppFont.bold(
                        16,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    content: new Text(
                      Util.getTranslated(
                          context, "update_dialog_forceVer_android"),
                      style: AppFont.regular(
                        14,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(Util.getTranslated(
                            context, "alert_dialog_cancel_text")),
                        onPressed: () {
                          Navigator.pop(context);
                          SystemNavigator.pop();
                        },
                      ),
                      TextButton(
                        child: Text(Util.getTranslated(
                            context, 'update_dialog_update_text')),
                        onPressed: () {
                          _launchBrowser(updateUrl);
                        },
                      )
                    ],
                  ),
                  onWillPop: () async => false),
            );
          } else {
            showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                title: new Text(
                  Util.getTranslated(context, 'update_dialog_title'),
                  style: AppFont.bold(
                    16,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none,
                  ),
                ),
                content: new Text(
                  Util.getTranslated(context, "update_dialog_newVer_android"),
                  style: AppFont.regular(
                    14,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(Util.getTranslated(
                        context, "alert_dialog_cancel_text")),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text(Util.getTranslated(
                        context, 'update_dialog_update_text')),
                    onPressed: () {
                      _launchBrowser(updateUrl);
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
          }
        } catch (e) {
          print(e.toString());
        }
      }
    }
    //  else if (compare == 0) {
    //   //both versions are same
    //   Util.printInfo('both versions are same');
    // } 
    else {
      //currentVersion is bigger
      Util.printInfo('currentVersion is bigger');
    }
  }

  static bool isVersionGreaterThan(String newVersion, String currentVersion){
   List<String> currentV = currentVersion.split(".");
   List<String> newV = newVersion.split(".");
   bool a = false;
   for (var i = 0 ; i <= 2; i++){
     a = int.parse(newV[i]) > int.parse(currentV[i]);
     if(int.parse(newV[i]) != int.parse(currentV[i])) break;
   }
   return a;
 }

  static _launchBrowser(String website) async {
    String url = website;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String displayTimeAgoFromTimestamp(
      BuildContext context, String timestamp) {
    final year = int.parse(timestamp.substring(0, 4));
    final month = int.parse(timestamp.substring(5, 7));
    final day = int.parse(timestamp.substring(8, 10));
    final hour = int.parse(timestamp.substring(11, 13));
    final minute = int.parse(timestamp.substring(14, 16));

    final DateTime msgDate = DateTime(year, month, day, hour, minute);
    final int diffInHours = DateTime.now().difference(msgDate).inHours;

    String timeAgo = '';
    String timeUnit = '';
    int timeValue = 0;

    if (diffInHours < 1) {
      final diffInMinutes = DateTime.now().difference(msgDate).inMinutes;
      timeValue = diffInMinutes;
      timeUnit = getTranslated(context, "timestamp_minute");
    } else if (diffInHours < 24) {
      timeValue = diffInHours;
      timeUnit = getTranslated(context, "timestamp_hour");
    } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
      timeValue = (diffInHours / 24).floor();
      timeUnit = getTranslated(context, "timestamp_day");
    } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
      timeValue = (diffInHours / (24 * 7)).floor();
      timeUnit = getTranslated(context, "timestamp_week");
    } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
      timeValue = (diffInHours / (24 * 30)).floor();
      timeUnit = getTranslated(context, "timestamp_month");
    } else {
      timeValue = (diffInHours / (24 * 365)).floor();
      timeUnit = getTranslated(context, "timestamp_year");
    }

    timeAgo = timeValue.toString() + ' ' + timeUnit;
    timeAgo += timeValue > 1 ? 's' : '';

    return timeValue == 0
        ? getTranslated(context, "timestamp_justnow")
        : timeAgo + ' ' + getTranslated(context, "timestamp_ago");
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
