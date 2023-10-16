import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutUs();
  }
}

class _AboutUs extends State<AboutUs> {
  // String email = "enquiry@behnmeyer.com.my";
  // String contact = "+60380263333";
  String email = "";
  String contact = "";
  String addr = "";
  Coords coords;

  _customLaunch(String command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      throw 'Could not launch $command';
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_about_us);

    if (AppCache.me != null) {
      if (AppCache.me.country != null && AppCache.me.country.length > 0) {
        if (AppCache.me.country == Constants.COUNTRY_CODE_MALAYSIA) {
          email = Constants.ABOUT_US_EMAIL_MY;
          contact = Constants.ABOUT_US_CONTACT_MY;
          addr = Constants.ABOUT_US_ADDRESS_MY;
          coords = Coords(3.041857862430738, 101.56584216842619);
        } else {
          email = Constants.ABOUT_US_EMAIL_VT;
          contact = Constants.ABOUT_US_CONTACT_VT;
          addr = Constants.ABOUT_US_ADDRESS_VT;
          coords = Coords(10.5594154, 107.0412593);
        }
      } else {
        email = Constants.ABOUT_US_EMAIL_MY;
        contact = Constants.ABOUT_US_CONTACT_MY;
        addr = Constants.ABOUT_US_ADDRESS_MY;
        coords = Coords(3.041857862430738, 101.56584216842619);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          child: backButton(context),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(left: 16, right: 16),
          color: Colors.white,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  aboutUsLabel(),
                  SizedBox(height: 20),
                  aboutUsDescription(context),
                  SizedBox(height: 30),
                  emailAddress(context),
                  SizedBox(height: 30),
                  contactNumber(context),
                  SizedBox(height: 30),
                  address(context),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: InkWell(
            child: Image.asset(
              Constants.ASSET_IMAGES + "grey_back_icon.png",
              width: 30,
              height: 30,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          )),
    );
  }

  Widget aboutUsLabel() {
    return Text(
      Util.getTranslated(context, "setting_about_us_title"),
      style: AppFont.bold(
        20,
        color: AppColor.appBlue(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget aboutUsDescription(BuildContext context) {
    return Text(
      (AppCache.me.country != null && AppCache.me.country.length > 0)
          ? (AppCache.me.country == Constants.COUNTRY_CODE_MALAYSIA)
              ? Util.getTranslated(context, "setting_about_us_detail")
              : Constants.ABOUT_US_DESCRIPTION_VT
          : Util.getTranslated(context, "setting_about_us_detail"),
      style: AppFont.regular(
        14,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget emailAddress(BuildContext context) {
    return InkWell(
      onTap: () {
        _customLaunch("mailto:$email");
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Util.getTranslated(context, "setting_about_us_email"),
                    style: AppFont.bold(
                      16,
                      color: AppColor.appBlue(),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    email,
                    style: AppFont.regular(
                      16,
                      color: AppColor.appBlack(),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Image.asset(
              Constants.ASSET_IMAGES + "email_icon.png",
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget contactNumber(BuildContext context) {
    return InkWell(
      onTap: () {
        _customLaunch("tel:+$contact");
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Util.getTranslated(
                        context, "setting_about_us_contact_number"),
                    style: AppFont.bold(
                      16,
                      color: AppColor.appBlue(),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    contact,
                    style: AppFont.regular(
                      16,
                      color: AppColor.appBlack(),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Image.asset(
              Constants.ASSET_IMAGES + "call_icon.png",
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget address(BuildContext context) {
    return InkWell(
      onTap: () {
        showMapPicker(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Util.getTranslated(context, "setting_about_us_address"),
                    style: AppFont.bold(
                      16,
                      color: AppColor.appBlue(),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    addr,
                    style: AppFont.regular(
                      16,
                      color: AppColor.appBlack(),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Image.asset(
              Constants.ASSET_IMAGES + "navigate_location_icon.png",
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showMapPicker(BuildContext context) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: availableMaps
              .map((item) => CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      item.showMarker(
                        coords: coords,
                        title: '',
                      );
                    },
                    child: Text(item.mapName),
                  ))
              .toList(),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
          children: availableMaps
              .map((item) => ListTile(
                    title: Text(
                      item.mapName,
                      style: AppFont.bold(
                        16,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      item.showMarker(
                        coords: coords,
                        title: '',
                      );
                    },
                  ))
              .toList(),
        ),
      );
    }
  }
}
