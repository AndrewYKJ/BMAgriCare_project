import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/controllers/landing.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/logout_api.dart';
import 'package:behn_meyer_flutter/models/landing/landing_country.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeCountry extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChangeCountry();
  }
}

class _ChangeCountry extends State<ChangeCountry> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LandingCountry> countries = [];

  Future<void> logout(BuildContext context) async {
    LogoutApi loginApi = LogoutApi(context);
    return loginApi.logout(context, "", "");
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_change_country);
    if (AppCache.me != null) {
      setState(() {
        if (AppCache.me.country != null && AppCache.me.country.length > 0) {
          if (AppCache.me.country == Constants.COUNTRY_CODE_MALAYSIA) {
            countries.add(LandingCountry(
                title: 'setting_country_my', code: 'MY', selected: true));
            countries.add(LandingCountry(
                title: 'setting_country_vt', code: 'VT', selected: false));
          } else {
            countries.add(LandingCountry(
                title: 'setting_country_my', code: 'MY', selected: false));
            countries.add(LandingCountry(
                title: 'setting_country_vt', code: 'VT', selected: true));
          }
        } else {
          countries.add(LandingCountry(
              title: 'setting_country_my', code: 'MY', selected: true));
          countries.add(LandingCountry(
              title: 'setting_country_vt', code: 'VT', selected: false));
        }
      });
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
              countryLabelText(
                labelName: Util.getTranslated(context, "landing_country_label"),
                labelTextStyle: AppFont.bold(
                  20,
                  color: AppColor.appBlue(),
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 10),
              countryLabelText(
                labelName:
                    Util.getTranslated(context, "landing_country_select"),
                labelTextStyle: AppFont.regular(
                  14,
                  color: AppColor.appDarkGreyColor(),
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 30),
              countryWidget(context),
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

  Widget countryLabelText({String labelName, TextStyle labelTextStyle}) {
    return Text(
      labelName,
      style: labelTextStyle,
    );
  }

  Widget countryWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: countries.map((item) => countryItem(context, item)).toList(),
    );
  }

  Widget countryItem(BuildContext context, LandingCountry countryDTO) {
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
                  Util.getTranslated(context, countryDTO.title),
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
                if (!countryDTO.selected) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => new CupertinoAlertDialog(
                      content: new Text(Util.getTranslated(
                          context, 'change_country_alert_message')),
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
                              context, 'alert_dialog_proceed_text')),
                          onPressed: () {
                            logout(context);
                            AppCache.setCountry(countryDTO.code);
                            AppCache.removeValues();
                            AppCache.removeLanguages();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Landing()),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              child: countryCheckboxWidget(countryDTO.selected),
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

  Widget countryCheckboxWidget(bool isSelected) {
    if (isSelected) {
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
