import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/controllers/authentication/authentication.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/detect_country_api.dart';
import 'package:behn_meyer_flutter/models/landing/landing_country.dart';
import 'package:behn_meyer_flutter/models/landing/landing_language.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:io' show Platform;

import '../main.dart';

class Landing extends StatefulWidget {
  final RemoteConfig config;
  Landing({Key key, this.config}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LandingState();
  }
}

class _LandingState extends State<Landing> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  // List<LandingLanguage> languages = [
  //   LandingLanguage(title: 'landing_language_EN', code: 'EN', selected: false),
  //   LandingLanguage(title: 'landing_language_BM', code: 'BM', selected: false),
  //   LandingLanguage(title: 'landing_language_CN', code: 'CN', selected: false)
  // ];
  List<LandingLanguage> languages;
  List<LandingCountry> countries = [
    LandingCountry(title: 'setting_country_my', code: 'MY', selected: false),
    LandingCountry(title: 'setting_country_vt', code: 'VT', selected: false)
  ];
  LandingLanguage selectedLanguage;
  LandingCountry selectedCountry;
  String cachedLanguage = "";
  String cachedCountry = "";
  bool isLoading = true;
  String did = "";
  String token = "";
  String secretKey = 'H3S9YF\$\$1tp8';

  Map<String, List<LandingLanguage>> mapLanguages = {
    'MY': [
      LandingLanguage(
          title: 'landing_language_EN', code: 'EN', selected: false),
      LandingLanguage(
          title: 'landing_language_BM', code: 'BM', selected: false),
      LandingLanguage(title: 'landing_language_CN', code: 'CN', selected: false)
    ],
    'VT': [
      LandingLanguage(title: 'landing_language_VT', code: 'VT', selected: false)
    ],
  };
  bool _isiOS13Above = false;

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_landing);

    initPlatformState();

    // getCurrentCountry();

    // AppCache.getCountry().then((value) {
    //   print('Cached country $value');
    //   Util.printInfo('CACHED COUNTRY: $value');
    //   setState(() {
    //     if (value != null && value.length > 0) {
    //       matchCountries(value);
    //       if (selectedCountry == null) {
    //         selectedCountry = countries.first;
    //         AppCache.setString(
    //             AppCache.COUNTRY_CODE_PREF, selectedCountry.code);
    //       }

    //       FirebaseAnalytics().setUserProperty(
    //           name: "accountcountry",
    //           value: selectedCountry.code == Constants.COUNTRY_CODE_VIETNAM
    //               ? "Vietnam"
    //               : "Malaysia");
    //       getCountryLanguages(selectedCountry.code);
    //       isLoading = false;
    //     } else {
    //       getCurrentCountry();
    //     }
    //   });
    // });

    // AppCache.getStringValue(AppCache.LANGUAGE_CODE_PREF).then((value) {
    //   Util.printInfo('CACHED LANGUAGE: $value');
    //   setState(() {
    //     cachedLanguage = value;
    //     if (cachedLanguage.length > 0) {
    //       MyApp.setLocale(context, Util.mylocale(cachedLanguage));
    //       matchLanguage(cachedLanguage);
    //       if (selectedLanguage == null) {
    //         selectedLanguage = languages.first;
    //         AppCache.setString(
    //             AppCache.LANGUAGE_CODE_PREF, selectedLanguage.code);
    //       }
    //     } else {
    //       selectedLanguage = languages.first;
    //       AppCache.setString(
    //           AppCache.LANGUAGE_CODE_PREF, selectedLanguage.code);
    //       MyApp.setLocale(context, Util.mylocale(selectedLanguage.code));
    //     }
    //     checkLanguages(selectedLanguage);
    //   });
    // });

    if (widget.config != null) {
      Util.checkAppVersion(context, widget.config);
    }
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};
    setState(() {
      _isiOS13Above = false;
    });

    try {
      if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        final isAppleSignInAvailable = await AppleSignInAvailable.check();
        if (isAppleSignInAvailable.isAvailable) {
          setState(() {
            _isiOS13Above = true;
          });
        }
      } else if (Platform.isAndroid) {
        deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;

      did = _deviceData['uuid'];

      AppCache.getCountry().then((value) {
        print('Cached country $value');
        Util.printInfo('CACHED COUNTRY: $value');
        setState(() {
          if (value != null && value.length > 0) {
            matchCountries(value);
            if (selectedCountry == null) {
              selectedCountry = countries.first;
              AppCache.setString(
                  AppCache.COUNTRY_CODE_PREF, selectedCountry.code);
            }

            FirebaseAnalytics().setUserProperty(
                name: "accountcountry",
                value: selectedCountry.code == Constants.COUNTRY_CODE_VIETNAM
                    ? "Vietnam"
                    : "Malaysia");
            getCountryLanguages(selectedCountry.code);
            isLoading = false;
          } else {
            getCurrentCountry();
          }
        });
      });
    });
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'deviceVersion': data.systemVersion,
      'model': data.model,
      'isPhysicalDevice': data.isPhysicalDevice,
      'uuid': data.identifierForVendor
    };
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'deviceVersion': build.version.sdkInt.toString(),
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'uuid': build.androidId, //uuid
    };
  }

  void getCurrentCountry() {
    EasyLoading.show();
    final jwt = JWT(
      // Payload
      {'did': did, 'expiresIn': '300000'},
      issuer: 'behn-meyer-api',
    );
    token = jwt.sign(SecretKey(secretKey));

    DetectCountryApi countryApi = DetectCountryApi(context);

    countryApi.getCountryInfo(token).then((data) {
      if (data != null) {
        setState(() {
          matchCountries(data.country);
          if (selectedCountry == null) {
            selectedCountry = countries.first;
            AppCache.setString(
                AppCache.COUNTRY_CODE_PREF, selectedCountry.code);
          } else {
            AppCache.setString(
                AppCache.COUNTRY_CODE_PREF, selectedCountry.code);
          }
          // AppCache.setString(AppCache.LANGUAGE_CODE_PREF, selectedCountry.code);

          isLoading = false;

          FirebaseAnalytics().setUserProperty(
              name: "accountcountry",
              value: selectedCountry.code == Constants.COUNTRY_CODE_VIETNAM
                  ? "Vietnam"
                  : "Malaysia");
          getCountryLanguages(selectedCountry.code);

          // print(data.country);
        });
      } else {
        EasyLoading.dismiss();

        isLoading = false;
        selectedCountry = countries.first;
        AppCache.setString(AppCache.COUNTRY_CODE_PREF, selectedCountry.code);
        FirebaseAnalytics().setUserProperty(
            name: "accountcountry",
            value: selectedCountry.code == Constants.COUNTRY_CODE_VIETNAM
                ? "Vietnam"
                : "Malaysia");
        getCountryLanguages(selectedCountry.code);
      }
    }).whenComplete(() {
      EasyLoading.dismiss();
    }).catchError((error) {
      print('get language error');
      EasyLoading.dismiss();

      isLoading = false;
      selectedCountry = countries.first;
      AppCache.setString(AppCache.COUNTRY_CODE_PREF, selectedCountry.code);
      FirebaseAnalytics().setUserProperty(
          name: "accountcountry",
          value: selectedCountry.code == Constants.COUNTRY_CODE_VIETNAM
              ? "Vietnam"
              : "Malaysia");
      getCountryLanguages(selectedCountry.code);
    });
  }

  void getCountryLanguages(String countryCode) {
    languages = mapLanguages[countryCode];

    AppCache.getStringValue(AppCache.LANGUAGE_CODE_PREF).then((value) {
      Util.printInfo('CACHED LANGUAGE: $value');
      setState(() {
        cachedLanguage = value;
        if (cachedLanguage.length > 0) {
          MyApp.setLocale(context, Util.mylocale(cachedLanguage));
          matchLanguage(cachedLanguage);
          if (selectedLanguage == null) {
            selectedLanguage = languages.first;
            AppCache.setString(
                AppCache.LANGUAGE_CODE_PREF, selectedLanguage.code);
          }
        } else {
          selectedLanguage = languages.first;
          AppCache.setString(
              AppCache.LANGUAGE_CODE_PREF, selectedLanguage.code);
          MyApp.setLocale(context, Util.mylocale(selectedLanguage.code));
        }
        checkLanguages(selectedLanguage);
      });
    });
  }

  void checkCountries(LandingCountry selected) {
    countries.forEach((element) => {
          if (element.code == selected.code)
            {element.selected = true}
          else
            {element.selected = false}
        });
  }

  void matchCountries(String code) {
    countries.forEach((element) => {
          if (element.code == code) {selectedCountry = element}
        });
  }

  void checkLanguages(LandingLanguage selected) {
    languages.forEach((element) => {
          if (element.code == selected.code)
            {element.selected = true}
          else
            {element.selected = false}
        });
  }

  void matchLanguage(String code) {
    languages.forEach((element) => {
          if (element.code == code) {selectedLanguage = element}
        });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              child: Image.asset(
                Constants.ASSET_IMAGES + "behn_meyer_splash_screen.png",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ))
        : Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Image.asset(
                  Constants.ASSET_IMAGES + "behn_meyer_splash_screen.png",
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                // uatWording(context),
                Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      signUpButton(context),
                      signInButton(context),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          selectedCountry != null
                              ? changeCountry(context)
                              : SizedBox(height: 0),
                          selectedLanguage != null
                              ? changeLanguage(context)
                              : SizedBox(height: 0),
                        ],
                      ),
                      SizedBox(height: 30)
                    ],
                  ),
                ),
              ],
            ));
  }

  Widget uatWording(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40),
      child: Text(
        "UAT",
        textAlign: TextAlign.center,
        style: AppFont.bold(
          16,
          color: AppColor.appBlack(),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget signUpButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: TextButton(
        onPressed: () {
          onSignUp(context);
        },
        child: Text(
          Util.getTranslated(context, "landing_sign_up"),
          style: AppFont.bold(16,
              color: AppColor.appBlack(), decoration: TextDecoration.none),
        ),
        style: TextButton.styleFrom(
          primary: AppColor.appBlack(),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  void onSignUp(BuildContext context) {
    print('onSign Up');
    Navigator.pushNamed(context, MyRoute.signUpRoute);
  }

  Widget signInButton(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: TextButton(
        onPressed: () {
          onSignIn(context);
        },
        child: Text(Util.getTranslated(context, "landing_sign_in")),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void onSignIn(BuildContext context) {
    print('onSign In');
    Navigator.pushNamed(context, MyRoute.signInRoute);
  }

  Widget changeCountry(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width / 2;
    return Container(
      // width: screenWidth,
      height: 80,
      margin: EdgeInsets.only(left: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Util.getTranslated(context, "landing_current_country"),
            style: AppFont.medium(15,
                color: AppColor.appDarkGreyColor(),
                decoration: TextDecoration.none),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              checkCountries(selectedCountry);
              _countryModalBottomSheetMenu(context);
            },
            child: SizedBox(
                height: 20,
                child: Text(
                  Util.getTranslated(context, selectedCountry.title),
                  style: AppFont.bold(15,
                      color: AppColor.appBlue(),
                      decoration: TextDecoration.underline),
                )),
          )
        ],
      ),
    );
  }

  Widget changeLanguage(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width / 2;
    return Container(
      // width: screenWidth,
      height: 80,
      margin: EdgeInsets.only(right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Util.getTranslated(context, "landing_current_language"),
            style: AppFont.medium(15,
                color: AppColor.appDarkGreyColor(),
                decoration: TextDecoration.none),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              checkLanguages(selectedLanguage);
              _modalBottomSheetMenu(context);
            },
            child: SizedBox(
                height: 20,
                child: Text(
                  Util.getTranslated(context, selectedLanguage.title),
                  style: AppFont.bold(15,
                      color: AppColor.appBlue(),
                      decoration: TextDecoration.underline),
                )),
          )
        ],
      ),
    );
  }

  void _countryModalBottomSheetMenu(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (builder) {
          return new Container(
              height: 350.0,
              color:
                  Colors.transparent, //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor
              child: SafeArea(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: countries.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Wrap(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 25, 10, 5),
                                width: screenWidth,
                                child: Text(
                                  Util.getTranslated(
                                      context, "landing_country_label"),
                                  style: AppFont.bold(17,
                                      color: AppColor.appBlue(),
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                width: screenWidth,
                                child: Text(
                                  Util.getTranslated(
                                      context, "landing_country_select"),
                                  style: AppFont.regular(13,
                                      color: AppColor.appDarkGreyColor(),
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          );
                        } else {
                          index -= 1;
                          var item = countries[index];
                          return InkWell(
                              onTap: () {
                                selectedCountry = item;
                                AppCache.setCountry(item.code);
                                AppCache.removeLanguages();
                                setState(() {
                                  Util.printInfo(
                                      'Selected : $index Item: ${item.title}');
                                  FirebaseAnalytics().setUserProperty(
                                      name: "accountcountry",
                                      value: (item.code ==
                                              Constants.COUNTRY_CODE_VIETNAM)
                                          ? "Vietnam"
                                          : "Malaysia");
                                  getCountryLanguages(item.code);
                                });
                                Navigator.pop(context);
                              },
                              child: countryModalContent(context, item));
                        }
                      })));
        });
  }

  void _modalBottomSheetMenu(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (builder) {
          return new Container(
              height: 350.0,
              color:
                  Colors.transparent, //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor
              child: SafeArea(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: languages.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Wrap(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 25, 10, 5),
                                width: screenWidth,
                                child: Text(
                                  Util.getTranslated(
                                      context, "landing_language_label"),
                                  style: AppFont.bold(17,
                                      color: AppColor.appBlue(),
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                width: screenWidth,
                                child: Text(
                                  Util.getTranslated(
                                      context, "landing_language_select"),
                                  style: AppFont.regular(13,
                                      color: AppColor.appDarkGreyColor(),
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          );
                        } else {
                          index -= 1;
                          var item = languages[index];
                          return InkWell(
                              onTap: () {
                                selectedLanguage = item;
                                AppCache.setString(
                                    AppCache.LANGUAGE_CODE_PREF, item.code);
                                setState(() {
                                  Util.printInfo(
                                      'Selected : $index Item: ${item.title}');
                                  MyApp.setLocale(
                                      context, Util.mylocale(item.code));
                                });
                                Navigator.pop(context);
                              },
                              child: modalContent(context, item));
                        }
                      })));
        });
  }

  Widget countryModalContent(BuildContext context, LandingCountry country) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: 70,
        width: screenWidth,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Util.getTranslated(context, country.title),
                style: AppFont.bold(17,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: countryCustomRadio(country.selected, country)),
            // SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomLeft,
              child: dottedLineSeperator(),
            )
          ],
        ));
  }

  Widget modalContent(BuildContext context, LandingLanguage language) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: 70,
        width: screenWidth,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Util.getTranslated(context, language.title),
                style: AppFont.bold(17,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: customRadio(language.selected, language)),
            // SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomLeft,
              child: dottedLineSeperator(),
            )
          ],
        ));
  }

  Widget countryCustomRadio(bool agreeTnc, LandingCountry country) {
    return GestureDetector(
      onTap: () {
        selectedCountry = country;
        AppCache.setCountry(country.code);
        AppCache.removeLanguages();
        setState(() {
          getCountryLanguages(country.code);
        });
        Navigator.pop(context);
      },
      child: SizedBox(
          width: 30,
          height: 30,
          child: agreeTnc
              ? CircleAvatar(
                  radius: 15,
                  backgroundImage:
                      AssetImage(Constants.ASSET_IMAGES + 'blue_tick_icon.png'))
              : Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                      color: Colors.white),
                )),
    );
  }

  Widget customRadio(bool agreeTnc, LandingLanguage language) {
    return GestureDetector(
      onTap: () {
        selectedLanguage = language;
        AppCache.setString(AppCache.LANGUAGE_CODE_PREF, language.code);
        setState(() {
          MyApp.setLocale(context, Util.mylocale(language.code));
        });
        Navigator.pop(context);
      },
      child: SizedBox(
          width: 30,
          height: 30,
          child: agreeTnc
              ? CircleAvatar(
                  radius: 15,
                  backgroundImage:
                      AssetImage(Constants.ASSET_IMAGES + 'blue_tick_icon.png'))
              : Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                      color: Colors.white),
                )),
    );
  }
}
