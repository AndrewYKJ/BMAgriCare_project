import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/login_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/logout_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/user_profile_api.dart';
import 'package:behn_meyer_flutter/dio/api/setting/checknow_getpoint.dart';
import 'package:behn_meyer_flutter/dio/api/setting/checknow_login.dart';
import 'package:behn_meyer_flutter/dio/api/setting/checknow_logout.dart';
import 'package:behn_meyer_flutter/dio/api/setting/checknow_profile.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/qrcode_scanner_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/user_profile_argument.dart';
import 'package:behn_meyer_flutter/models/setting/checknow.dart';
import 'package:behn_meyer_flutter/models/setting/checknow_point.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/my_route.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  Settings() : super();

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> with WidgetsBindingObserver {
  String _languageCode = "";
  String _countryCode = "";
  User _user;
  String checkNowPoints = "0";
  bool isClickCheckNowEarnPoint = false;

  Future<void> logout(BuildContext context) async {
    LogoutApi loginApi = LogoutApi(context);
    return loginApi.logout(context, "", "");
  }

  Future<void> _getData() async {
    getUserProfile();
  }

  void getUserProfile() {
    UserProfileApi userProfileApi = UserProfileApi(context);
    userProfileApi.getOwnUserProfile().then((data) {
      if (data != null) {
        _user = data;
        _languageCode = data.language;
        if (data.country != null && data.country.length > 0) {
          _countryCode = data.country;
        } else {
          _countryCode = Constants.COUNTRY_CODE_MALAYSIA;
        }

        if (_countryCode == Constants.COUNTRY_CODE_MALAYSIA) {
          if (data.checkNowGuid != null &&
              data.checkNowGuid.length > 0 &&
              data.checkNowAuthToken != null &&
              data.checkNowAuthToken.length > 0) {
            callGetCheckNowPoints(context).then((value) {
              if (value.statusCode == "200") {
                this.checkNowPoints = value.points;
              } else {
                this.checkNowPoints = "0";
              }
            }).whenComplete(() {
              setState(() {});
            }).catchError((error) {
              this.checkNowPoints = "0";
            });
          }
        }
      }
    }).whenComplete(() {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      setState(() {});
    }).catchError((error) {});
  }

  Future<CheckNowDTO> callCheckNowLogin(BuildContext context) async {
    CheckNowLoginApi checkNowLoginApi = CheckNowLoginApi(context);
    return checkNowLoginApi.call();
  }

  Future<Response> callCheckNowUnlinkAccount(BuildContext context) async {
    CheckNowUnlinkApi checkNowUnlinkApi = CheckNowUnlinkApi(context);
    return checkNowUnlinkApi.call();
  }

  Future<CheckNowDTO> callViewCheckNowProfile(BuildContext context) async {
    CheckNowProfileApi checkNowProfileApi = CheckNowProfileApi(context);
    return checkNowProfileApi.call();
  }

  Future<CheckNowPointDTO> callGetCheckNowPoints(BuildContext context) async {
    CheckNowGetPointApi checkNowGetPointApi = CheckNowGetPointApi(context);
    return checkNowGetPointApi.call();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_tab_settings);
    if (AppCache.me != null) {
      setState(() {
        _languageCode = AppCache.me.language;
        _user = AppCache.me;
        if (AppCache.me.country != null && AppCache.me.country.length > 0) {
          _countryCode = AppCache.me.country;
        } else {
          _countryCode = Constants.COUNTRY_CODE_MALAYSIA;
        }
      });

      if (AppCache.me.country != null && AppCache.me.country.length > 0) {
        _countryCode = AppCache.me.country;
        if (_countryCode == Constants.COUNTRY_CODE_MALAYSIA) {
          if (AppCache.me.checkNowGuid != null &&
              AppCache.me.checkNowGuid.length > 0 &&
              AppCache.me.checkNowAuthToken != null &&
              AppCache.me.checkNowAuthToken.length > 0) {
            callGetCheckNowPoints(context).then((value) {
              if (value.statusCode == "200") {
                this.checkNowPoints = value.points;
              } else {
                this.checkNowPoints = "0";
              }
            }).whenComplete(() {
              setState(() {});
            }).catchError((error) {
              setState(() {
                this.checkNowPoints = "0";
              });
            });
          }
        }
      } else {
        _countryCode = Constants.COUNTRY_CODE_MALAYSIA;
        if (AppCache.me.checkNowGuid != null &&
            AppCache.me.checkNowGuid.length > 0 &&
            AppCache.me.checkNowAuthToken != null &&
            AppCache.me.checkNowAuthToken.length > 0) {
          callGetCheckNowPoints(context).then((value) {
            if (value.statusCode == "200") {
              this.checkNowPoints = value.points;
            } else {
              this.checkNowPoints = "0";
            }
          }).whenComplete(() {
            setState(() {});
          }).catchError((error) {
            this.checkNowPoints = "0";
          });
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed
        Util.printInfo(">>>>> AppLifecycleState Resumed >>>>>>");
        getUserProfile();
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        Util.printInfo(">>>>> AppLifecycleState Inactive >>>>>>");
        break;
      case AppLifecycleState.paused:
        // widget is paused
        Util.printInfo(">>>>> AppLifecycleState Paused >>>>>>");
        break;
      case AppLifecycleState.detached:
        // widget is detached
        Util.printInfo(">>>>> AppLifecycleState Detached >>>>>>");
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _launchBrowser(String website) async {
    String url = website;
    if (await canLaunch(url)) {
      if (Platform.isIOS) {
        await launch(url, forceSafariVC: false);
      } else {
        await launch(url);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColor.appBlue(),
          onRefresh: _getData,
          child: ListView(
            children: [
              header(context),
              SizedBox(height: 30),
              userProfile(context),
              SizedBox(height: 20),
              _countryCode == Constants.COUNTRY_CODE_MALAYSIA
                  ? checkMyPoints(context)
                  : Container(),
              SizedBox(height: 20),
              languange(context),
              SizedBox(height: 20),
              dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
              SizedBox(height: 20),
              country(context),
              SizedBox(height: 20),
              dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
              _countryCode == Constants.COUNTRY_CODE_VIETNAM
                  ? referralCodeSection(context)
                  : Container(),
              SizedBox(height: 20),
              if (Platform.isAndroid) changePassword(context),
              // SizedBox(height: 20),
              // dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
              // SizedBox(height: 20),
              aboutUs(context),
              SizedBox(height: 20),
              dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
              SizedBox(height: 20),
              termsAndConditions(context),
              SizedBox(height: 20),
              dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
              SizedBox(height: 20),
              privacyPolicy(context),
              SizedBox(height: 20),
              dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
              SizedBox(height: 20),
              if (Platform.isIOS) accountSettings(context),
              if (Platform.isIOS) SizedBox(height: 20),
              if (Platform.isIOS)
                dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              top: 5,
            ),
            color: Colors.white,
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                Constants.ASSET_IMAGES + "s_behn_meyer_logo.png",
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onSignOut(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Constants.ASSET_IMAGES + "logout_icon.png",
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColor.appBlue(),
                    ),
                  ),
                ),
                child: Text(
                  Util.getTranslated(context, "setting_logout"),
                  style: AppFont.bold(
                    14,
                    color: AppColor.appBlue(),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget userProfile(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 80,
          height: 80,
          child: _user != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: DisplayImage(
                    _user.photo,
                    'profile_placeholder.png',
                    width: 80.0,
                    height: 80.0,
                    boxFit: BoxFit.cover,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Image.asset(
                    Constants.ASSET_IMAGES + 'profile_placeholder.png',
                    height: 80.0,
                    width: 80.0,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            color: Colors.white,
            child: (_user != null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user.name,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.bold(
                          18,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 10),
                      (_user.email != null && _user.email.length > 0)
                          ? Text(
                              _user.email,
                              maxLines: 2,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: AppFont.regular(
                                12,
                                color: AppColor.appBlack(),
                                decoration: TextDecoration.none,
                              ),
                            )
                          : (_user.mobileNo != null &&
                                  _user.mobileNo.length > 0)
                              ? Text(
                                  _user.mobileNo,
                                  maxLines: 2,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFont.regular(
                                    12,
                                    color: AppColor.appBlack(),
                                    decoration: TextDecoration.none,
                                  ),
                                )
                              : Container(),
                      SizedBox(height: 10),
                      _user.country == Constants.COUNTRY_CODE_MALAYSIA
                          ? (_user.company != null && _user.company.length > 0)
                              ? Text(
                                  _user.company,
                                  maxLines: 2,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFont.regular(
                                    12,
                                    color: AppColor.appBlack(),
                                    decoration: TextDecoration.none,
                                  ),
                                )
                              : Container()
                          : (_user.area != null && _user.area.length > 0)
                              ? Text(
                                  _user.area,
                                  maxLines: 2,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFont.regular(
                                    12,
                                    color: AppColor.appBlack(),
                                    decoration: TextDecoration.none,
                                  ),
                                )
                              : Container()
                    ],
                  )
                : Container(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: (_user != null)
              ? ClipOval(
                  child: InkWell(
                    child: Image.asset(
                      Constants.ASSET_IMAGES + "edit_icon.png",
                      height: 30,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, MyRoute.editProfileRoute,
                              arguments: UserProfileArgument(_user))
                          .then(onGoBack);
                    },
                  ),
                )
              : Container(),
        ),
      ],
    );
  }

  Widget checkMyPoints(BuildContext context) {
    if (_user.checkNowGuid != null &&
        _user.checkNowGuid.length > 0 &&
        _user.checkNowAuthToken != null &&
        _user.checkNowAuthToken.length > 0) {
      return checkMyPointsDetails(context);
    }
    return GestureDetector(
      onTap: () {
        FirebaseAnalytics().logEvent(
          name: Constants.analytics_checknow_link_account,
        );
        EasyLoading.show(maskType: EasyLoadingMaskType.black);
        callCheckNowLogin(context).then((value) {
          if (value != null) {
            if (value.url != null && value.url.length > 0) {
              _launchBrowser(value.url);
            }
          }
        }).whenComplete(() {
          EasyLoading.dismiss();
        }).catchError((error) {
          if (error is DioError) {
            if (error.response != null) {
              if (error.response.data != null) {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, "alert_dialog_title_error_text"),
                    ErrorDTO.fromJson(error.response.data).message +
                        "(${ErrorDTO.fromJson(error.response.data).code})");
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, "alert_dialog_title_error_text"),
                    Util.getTranslated(
                        context, "general_alert_message_error_response_2"));
              }
            } else {
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, "alert_dialog_title_error_text"),
                  Util.getTranslated(
                      context, "general_alert_message_error_response_2"));
            }
          } else {
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, "alert_dialog_title_error_text"),
                Util.getTranslated(
                    context, "general_alert_message_error_response_2"));
          }
        });
        // _launchBrowser(Constants.CHECK_MY_POINT_URL);
        // Navigator.pushNamed(context, MyRoute.webBrowserRoute,
        //     arguments: WebBrowserArgument(Constants.CHECK_MY_POINT_URL));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: AppColor.appBlue(),
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Image.asset(
                        Constants.ASSET_IMAGES + "point_icon.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Text(
                      Util.getTranslated(context, "setting_check_my_points"),
                      style: AppFont.bold(
                        16,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              )),
              Image.asset(
                Constants.ASSET_IMAGES + "white_right_arrow_icon.png",
                width: 20,
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget checkMyPointsDetails(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: AppColor.appBlue(),
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Util.getTranslated(
                                    context, "setting_checknow_balance_point"),
                                style: AppFont.medium(
                                  14,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                EasyLoading.show(
                                    maskType: EasyLoadingMaskType.black);
                                callViewCheckNowProfile(context).then((value) {
                                  if (value != null) {
                                    if (value.url != null &&
                                        value.url.length > 0) {
                                      _launchBrowser(value.url);
                                      // Navigator.pushNamed(
                                      //     context, MyRoute.webBrowserRoute,
                                      //     arguments:
                                      //         WebBrowserArgument(value.url));
                                    }
                                  }
                                }).whenComplete(() {
                                  EasyLoading.dismiss();
                                }).catchError((error) {
                                  if (error is DioError) {
                                    if (error.response != null) {
                                      if (error.response.data != null) {
                                        Util.showAlertDialog(
                                            context,
                                            Util.getTranslated(context,
                                                "alert_dialog_title_error_text"),
                                            ErrorDTO.fromJson(
                                                        error.response.data)
                                                    .message +
                                                "(${ErrorDTO.fromJson(error.response.data).code})");
                                      } else {
                                        Util.showAlertDialog(
                                            context,
                                            Util.getTranslated(context,
                                                "alert_dialog_title_error_text"),
                                            Util.getTranslated(context,
                                                "general_alert_message_error_response_2"));
                                      }
                                    } else {
                                      Util.showAlertDialog(
                                          context,
                                          Util.getTranslated(context,
                                              "alert_dialog_title_error_text"),
                                          Util.getTranslated(context,
                                              "general_alert_message_error_response_2"));
                                    }
                                  } else {
                                    Util.showAlertDialog(
                                        context,
                                        Util.getTranslated(context,
                                            "alert_dialog_title_error_text"),
                                        Util.getTranslated(context,
                                            "general_alert_message_error_response_2"));
                                  }
                                });
                              },
                              child: Text(
                                Util.getTranslated(
                                    context, "setting_checknow_view_more"),
                                textAlign: TextAlign.center,
                                style: AppFont.medium(
                                  16,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            Image.asset(
                              Constants.ASSET_IMAGES +
                                  "white_right_arrow_icon.png",
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Image.asset(
                            Constants.ASSET_IMAGES + "point_icon.png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                        Text(
                          this.checkNowPoints +
                              " " +
                              Util.getTranslated(
                                  context, "setting_checknow_points"),
                          textAlign: TextAlign.center,
                          style: AppFont.bold(
                            25,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      isClickCheckNowEarnPoint = true;
                      Navigator.pushNamed(context, MyRoute.qrcodeScannerRoute,
                          arguments: QrcodeScannerArgument(
                              Constants.SCANNER_TYPE_EARN_POINT))
                        ..then(onGoBack);
                    },
                    child: Container(
                      height: 65.0,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColor.appGreen(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Constants.ASSET_IMAGES + "earn_points_icon.png",
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                          Expanded(
                            child: Text(
                              Util.getTranslated(
                                  context, "setting_checknow_btn_earn_point"),
                              textAlign: TextAlign.center,
                              style: AppFont.bold(
                                18,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, MyRoute.qrcodeScannerRoute,
                          arguments: QrcodeScannerArgument(
                              Constants.SCANNER_TYPE_VALIDATE_PRODUCT));
                    },
                    child: Container(
                      height: 65.0,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColor.appBlack(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Constants.ASSET_IMAGES +
                                "validate_products_icon.png",
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                          Expanded(
                            child: Text(
                              Util.getTranslated(context,
                                  "setting_checknow_btn_validate_product"),
                              textAlign: TextAlign.center,
                              style: AppFont.bold(
                                18,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          unlinkCheckNow(context),
          SizedBox(height: 20),
          dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
        ],
      ),
    );
  }

  Widget unlinkCheckNow(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => new CupertinoAlertDialog(
            content: new Text(Util.getTranslated(
                context, 'checknow_unlink_acct_confirm_message')),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                    Util.getTranslated(context, 'alert_dialog_cancel_text')),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                    Util.getTranslated(context, 'alert_dialog_proceed_text')),
                onPressed: () {
                  FirebaseAnalytics().logEvent(
                    name: Constants.analytics_checknow_unlink_account,
                  );
                  Navigator.pop(context);
                  EasyLoading.show(maskType: EasyLoadingMaskType.black);
                  callCheckNowUnlinkAccount(context).then((value) {
                    getUserProfile();
                  }).catchError((error) {
                    EasyLoading.dismiss();
                    if (error is DioError) {
                      if (error.response != null) {
                        if (error.response.data != null) {
                          Util.showAlertDialog(
                              context,
                              Util.getTranslated(
                                  context, "alert_dialog_title_error_text"),
                              ErrorDTO.fromJson(error.response.data).message +
                                  "(${ErrorDTO.fromJson(error.response.data).code})");
                        } else {
                          Util.showAlertDialog(
                              context,
                              Util.getTranslated(
                                  context, "alert_dialog_title_error_text"),
                              Util.getTranslated(context,
                                  "general_alert_message_error_response_2"));
                        }
                      } else {
                        Util.showAlertDialog(
                            context,
                            Util.getTranslated(
                                context, "alert_dialog_title_error_text"),
                            Util.getTranslated(context,
                                "general_alert_message_error_response_2"));
                      }
                    } else {
                      Util.showAlertDialog(
                          context,
                          Util.getTranslated(
                              context, "alert_dialog_title_error_text"),
                          Util.getTranslated(context,
                              "general_alert_message_error_response_2"));
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "setting_checknow_unlink_account"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Image.asset(
            Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget languange(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.changeLanguageRoute)
          ..then(onGoBack);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "setting_language"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Util.appLanguage(context, _languageCode),
                  style: AppFont.regular(
                    16,
                    color: AppColor.appBlue(),
                    decoration: TextDecoration.none,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
                    width: 20,
                    height: 20,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget country(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.changeCountryRoute);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "setting_country"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _countryCode == Constants.COUNTRY_CODE_MALAYSIA
                      ? Util.getTranslated(context, "setting_country_my")
                      : Util.getTranslated(context, "setting_country_vt"),
                  style: AppFont.regular(
                    16,
                    color: AppColor.appBlue(),
                    decoration: TextDecoration.none,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
                    width: 20,
                    height: 20,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget changePassword(BuildContext context) {
    if (_user != null) {
      if (_user.userType == LoginType.Email.name ||
          _user.userType == LoginType.Mobile.name) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, MyRoute.changePasswordRoute);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Text(
                        Util.getTranslated(context, "setting_change_password"),
                        style: AppFont.bold(
                          16,
                          color: AppColor.appBlack(),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
            SizedBox(height: 20),
          ],
        );
      } else {
        return new Container();
      }
    } else {
      return new Container();
    }
  }

  Widget aboutUs(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.aboutUsRoute);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "setting_about_us"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Image.asset(
            Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget termsAndConditions(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.termsAndConditionsRoute);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "setting_terms_and_conditions"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Image.asset(
            Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget privacyPolicy(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.privacyPolicyRoute);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "setting_privacy_policy"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Image.asset(
            Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget accountSettings(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, MyRoute.accountSettingRoute,
            arguments: [_user]);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "account_setting"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Image.asset(
            Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget referralCodeSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        InkWell(
            onTap: () {
              Navigator.pushNamed(context, MyRoute.referralCodeRoute);
            },
            child: Row(
              children: [
                Expanded(
                    child: Text(Util.getTranslated(context, "setting_referral"),
                        style: AppFont.bold(
                          16,
                          color: AppColor.appBlack(),
                          decoration: TextDecoration.none,
                        ))),
                Image.asset(
                  Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
                  width: 20,
                  height: 20,
                ),
              ],
            )),
        SizedBox(height: 20),
        dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
      ],
    );
  }

  void onSignOut(BuildContext context) {
    print('onSign Out');
    logout(context);
    // Navigator.of(context, rootNavigator: true).pop();
    AppCache.removeValues();
    Navigator.pushReplacementNamed(context, MyRoute.landingRoute);
  }

  void refreshData() {
    print("Refresh Data Here...");
    if (AppCache.me != null) {
      setState(() {
        _user = AppCache.me;
        _languageCode = AppCache.me.language;
      });
    }
  }

  void onGoBack(dynamic value) {
    if (isClickCheckNowEarnPoint) {
      isClickCheckNowEarnPoint = false;
      callGetCheckNowPoints(context).then((value) {
        if (value.statusCode == "200") {
          this.checkNowPoints = value.points;
        } else {
          this.checkNowPoints = "0";
        }
      }).whenComplete(() {
        setState(() {});
      }).catchError((error) {
        setState(() {
          this.checkNowPoints = "0";
        });
      });
    } else {
      refreshData();
    }
  }
}
