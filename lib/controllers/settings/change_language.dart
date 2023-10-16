import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/setting/change_language_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/setting/language.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../main.dart';

class ChangeLanguage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChangeLanguage();
  }
}

class _ChangeLanguage extends State<ChangeLanguage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<Response> futureLanguageResponse;
  bool isEnglish = true;
  bool isBahasaMalaysia = false;
  bool isChinese = false;
  bool isVietnamese = false;
  List<LanguageDTO> languageList = [];

  // Future<Response> fetchLanguage(BuildContext ctx) {
  //   GetLanguageApi languageApi = GetLanguageApi(ctx);
  //   return languageApi.call();
  // }

  void updateLanguage(BuildContext ctx, String languageCode) {
    var bodyData = {"language": languageCode};
    ChangeLanguageApi changeLanguageApi =
        ChangeLanguageApi(ctx, bodyData: bodyData);
    changeLanguageApi
        .call()
        .then((value) async {
          if (value.statusCode == HttpStatus.ok) {
            MyApp.setLocale(context, Util.mylocale(languageCode));
            AppCache.setString(AppCache.LANGUAGE_CODE_PREF, languageCode);
            AppCache.me = User.fromJson(value.data);
            EasyLoading.showSuccess(
                Util.getTranslated(
                    context, "general_alert_message_change_language_success"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
          } else {
            EasyLoading.showError(
                Util.getTranslated(
                    context, "general_alert_message_change_language_failed"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
          }
        })
        .whenComplete(() {})
        .catchError((error) {
          if (error is DioError) {
            if (error.response != null) {
              if (error.response.data != null){
                Util.showAlertDialog(
                  _scaffoldKey.currentContext,
                  Util.getTranslated(context, "alert_dialog_title_error_text"),
                  ErrorDTO.fromJson(error.response.data).message +
                      "(${ErrorDTO.fromJson(error.response.data).code})");
              } else {
                EasyLoading.showError(
                  Util.getTranslated(
                      context, "general_alert_message_change_language_failed"),
                  duration: Duration(milliseconds: 2000),
                  maskType: EasyLoadingMaskType.black);
              }
            } else {
              EasyLoading.showError(
                  Util.getTranslated(
                      context, "general_alert_message_change_language_failed"),
                  duration: Duration(milliseconds: 2000),
                  maskType: EasyLoadingMaskType.black);
            }
          } else {
            EasyLoading.showError(
                Util.getTranslated(
                    context, "general_alert_message_change_language_failed"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
          }
        });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_change_language);
    // futureLanguageResponse = fetchLanguage(context);
    if (AppCache.me != null) {
      if (AppCache.me.country != null && AppCache.me.country.length > 0) {
        if (AppCache.me.country == Constants.COUNTRY_CODE_MALAYSIA) {
          languageList.add(LanguageDTO(
              code: Constants.LANGUAGE_CODE_EN, name: "setting_language_en"));
          languageList.add(LanguageDTO(
              code: Constants.LANGUAGE_CODE_BM, name: "setting_language_id"));
          languageList.add(LanguageDTO(
              code: Constants.LANGUAGE_CODE_CN, name: "setting_language_zh"));
          if (AppCache.me.language == Constants.LANGUAGE_CODE_EN) {
            setState(() {
              this.isEnglish = true;
              this.isBahasaMalaysia = false;
              this.isChinese = false;
            });
          } else if (AppCache.me.language == Constants.LANGUAGE_CODE_BM) {
            setState(() {
              this.isEnglish = false;
              this.isBahasaMalaysia = true;
              this.isChinese = false;
            });
          } else if (AppCache.me.language == Constants.LANGUAGE_CODE_CN) {
            setState(() {
              this.isEnglish = false;
              this.isBahasaMalaysia = false;
              this.isChinese = true;
            });
          }
        } else {
          languageList.add(LanguageDTO(
              code: Constants.LANGUAGE_CODE_VT, name: "landing_language_VT"));
          setState(() {
            this.isVietnamese = true;
          });
        }
      } else {
        languageList.add(LanguageDTO(
            code: Constants.LANGUAGE_CODE_EN, name: "setting_language_en"));
        languageList.add(LanguageDTO(
            code: Constants.LANGUAGE_CODE_BM, name: "setting_language_id"));
        languageList.add(LanguageDTO(
            code: Constants.LANGUAGE_CODE_CN, name: "setting_language_zh"));
        if (AppCache.me.language == Constants.LANGUAGE_CODE_EN) {
          setState(() {
            this.isEnglish = true;
            this.isBahasaMalaysia = false;
            this.isChinese = false;
          });
        } else if (AppCache.me.language == Constants.LANGUAGE_CODE_BM) {
          setState(() {
            this.isEnglish = false;
            this.isBahasaMalaysia = true;
            this.isChinese = false;
          });
        } else if (AppCache.me.language == Constants.LANGUAGE_CODE_CN) {
          setState(() {
            this.isEnglish = false;
            this.isBahasaMalaysia = false;
            this.isChinese = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          child: backButton(context),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          margin: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              languageLabelText(
                labelName:
                    Util.getTranslated(context, "setting_language_title"),
                labelTextStyle: AppFont.bold(
                  20,
                  color: AppColor.appBlue(),
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 10),
              languageLabelText(
                labelName:
                    Util.getTranslated(context, "setting_language_subtitle"),
                labelTextStyle: AppFont.regular(
                  14,
                  color: AppColor.appDarkGreyColor(),
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 30),
              languageWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: InkWell(
          child: Image.asset(
            Constants.ASSET_IMAGES + "grey_back_icon.png",
            width: 30,
            height: 30,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget languageLabelText({String labelName, TextStyle labelTextStyle}) {
    return Text(
      labelName,
      style: labelTextStyle,
    );
  }

  Widget languageWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          languageList.map((item) => languageItem(context, item)).toList(),
    );
  }

  Widget languageItem(BuildContext context, LanguageDTO languageDTO) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: Text(
                  Util.getTranslated(context, languageDTO.name),
                  style: AppFont.bold(
                    16,
                    color: AppColor.appBlack(),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (AppCache.me.country == null ||
                    AppCache.me.country.length == 0 ||
                    AppCache.me.country == Constants.COUNTRY_CODE_MALAYSIA) {
                  setState(() {
                    if (languageDTO.code == Constants.LANGUAGE_CODE_EN) {
                      isEnglish = true;
                      isBahasaMalaysia = false;
                      isChinese = false;
                      // _changeLanguage(Constants.ENGLISH);
                    } else if (languageDTO.code == Constants.LANGUAGE_CODE_BM) {
                      isEnglish = false;
                      isBahasaMalaysia = true;
                      isChinese = false;
                      // _changeLanguage(Constants.INDONESIA);
                    } else if (languageDTO.code == Constants.LANGUAGE_CODE_CN) {
                      isEnglish = false;
                      isBahasaMalaysia = false;
                      isChinese = true;
                      // _changeLanguage(Constants.CHINESE);
                    }
                    EasyLoading.show(maskType: EasyLoadingMaskType.black);
                    updateLanguage(context, languageDTO.code);
                  });
                }
              },
              child: languageCheckboxWidget(languageDTO.code),
            ),
          ],
        ),
        SizedBox(height: 20),
        dottedLineSeperator(
          height: 1.5,
          color: AppColor.appBlue(),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget languageCheckboxWidget(String languageCode) {
    if (languageCode == Constants.LANGUAGE_CODE_EN && isEnglish) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.appBlue(),
          border: null,
        ),
        child: Image.asset(
          Constants.ASSET_IMAGES + "blue_tick_icon.png",
          width: 20,
          height: 20,
        ),
      );
    } else if (languageCode == Constants.LANGUAGE_CODE_BM && isBahasaMalaysia) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.appBlue(),
          border: null,
        ),
        child: Image.asset(
          Constants.ASSET_IMAGES + "blue_tick_icon.png",
          width: 20,
          height: 20,
        ),
      );
    } else if (languageCode == Constants.LANGUAGE_CODE_CN && isChinese) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.appBlue(),
          border: null,
        ),
        child: Image.asset(
          Constants.ASSET_IMAGES + "blue_tick_icon.png",
          width: 20,
          height: 20,
        ),
      );
    } else if (languageCode == Constants.LANGUAGE_CODE_VT && isVietnamese) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.appBlue(),
          border: null,
        ),
        child: Image.asset(
          Constants.ASSET_IMAGES + "blue_tick_icon.png",
          width: 20,
          height: 20,
        ),
      );
    } else {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: AppColor.appDarkGreyColor(),
            width: 1,
          ),
        ),
      );
    }
  }
}
