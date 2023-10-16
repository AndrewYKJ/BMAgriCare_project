import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/user_profile_api.dart';
import 'package:behn_meyer_flutter/dio/api/referral/referral_api.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class ReferralCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReferralCodeScreen();
  }
}

class _ReferralCodeScreen extends State<ReferralCode> {
  String languageCode = "";
  User user;
  String countryCode = "";
  String referralCode = "";
  int referrerCount = 0;
  int referrerBalance = 0;
  String viewRewardsUrl;
  String termsNConditionUrl;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (AppCache.me != null) {
      setState(() {
        languageCode = AppCache.me.language;
        user = AppCache.me;
        if (AppCache.me.country != null && AppCache.me.country.length > 0) {
          countryCode = AppCache.me.country;
        } else {
          countryCode = Constants.COUNTRY_CODE_MALAYSIA;
        }
      });
    }

    getUserProfile();
  }

  Future<void> getReferralData() async {
    getReferralInfo();
  }

  void getReferralInfo() {
    print('calling');
    EasyLoading.show();

    ReferralApi referralApi = ReferralApi(context);
    referralApi.getReferralInfo().then((data) {
      if (data != null) {
        print('hello');
        setState(() {
          viewRewardsUrl = data.viewRewardUrl;
          termsNConditionUrl = data.rewardTermUrl;
        });
      }
    }).whenComplete(() {
      EasyLoading.dismiss();
    }).catchError((error) {
      print(error);
    });
  }

  void getUserProfile() {
    EasyLoading.show();
    UserProfileApi userProfileApi = UserProfileApi(context);
    userProfileApi.getOwnUserProfile().then((data) {
      if (data != null) {
        user = data;
        languageCode = data.language;
        if (data.country != null && data.country.length > 0) {
          countryCode = data.country;
        } else {
          countryCode = Constants.COUNTRY_CODE_MALAYSIA;
        }

        if (data.referralCode != null) {
          setState(() {
            referralCode = data.referralCode;
          });
        }

        if (data.referrerCount != null) {
          setState(() {
            referrerCount = data.referrerCount;
          });
        }

        if (data.referrerBalance != null) {
          setState(() {
            referrerBalance = data.referrerBalance;
          });
        }

        getReferralInfo();
      }
    }).whenComplete(() {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      setState(() {});
    }).catchError((error) {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            leadingWidth: 80,
            leading: backButton(context),
            elevation: 0,
            backgroundColor: Colors.lightGreen.shade500),
        body: SafeArea(
            child: Container(
                child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Column(children: [
                          referAFriend(context),
                          illustation(context),
                          usedCode(context),
                          shareReferralText(context),
                          myReferralCodeText(context),
                          referralCodeSection(context),
                          shareReferral(),
                          SizedBox(height: 60),
                          viewRewards(),
                          Container(
                              margin:
                                  EdgeInsets.only(left: 16, right: 16, top: 16),
                              child: dottedLineSeperator(
                                  height: 1.5, color: AppColor.appBlue())),
                          SizedBox(height: 40),
                          termsCondition()
                        ]))))));
  }

  Widget referAFriend(BuildContext context) {
    return Container(
        color: Colors.lightGreen.shade500,
        padding: EdgeInsets.only(left: 16),
        alignment: Alignment.topLeft,
        child: Text(Util.getTranslated(context, "referral_refer_friend"),
            style: AppFont.bold(20,
                color: Colors.white, decoration: TextDecoration.none)));
  }

  Widget illustation(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.lightGreen.shade500,
        padding: EdgeInsets.only(top: 24),
        child: Image.asset(
          "assets/images/refer_illustration.png",
          width: 220,
          height: 220,
          fit: BoxFit.contain,
        ));
  }

  Widget usedCode(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.lightGreen.shade500,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
            referrerCount.toString() +
                " " +
                Util.getTranslated(context, "referral_used_code") +
                " (" +
                Util.getTranslated(context, "available_point") +
                ": " +
                referrerBalance.toString() +
                ")",
            textAlign: TextAlign.center,
            style: AppFont.bold(16, color: Colors.white)));
  }

  Widget shareReferralText(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.lightGreen.shade500,
        padding: EdgeInsets.only(left: 42, right: 24),
        child: Text(Util.getTranslated(context, "share_referral_msg"),
            style: TextStyle(
              color: Colors.white,
              height: 1.7,
              fontSize: 14,
            )));
  }

  Widget myReferralCodeText(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        color: Colors.lightGreen.shade500,
        padding: EdgeInsets.only(top: 24, bottom: 24),
        child: Text(Util.getTranslated(context, "my_referral_code"),
            style: TextStyle(color: Colors.white, fontSize: 16)));
  }

  Widget referralCodeSection(BuildContext context) {
    var h = MediaQuery.of(context).size.height * 0.50;

    String text1 = Util.getTranslated(context, "share_text_head") +
        "\n" +
        Util.getTranslated(context, "share_text_IOS_title") +
        "\n" +
        "https://apple.co/3cmWi2l" +
        "\n" +
        Util.getTranslated(context, "share_text_ANDROID_title") +
        "\n" +
        "https://bit.ly/3oncFyt" +
        "\n";
    String text2 = Util.getTranslated(context, "share_text1") +
        " " +
        referralCode.toString() +
        " " +
        Util.getTranslated(context, "share_text2");

    return Container(
        height: 60,
        child: Stack(children: [
          Container(height: 30, color: Colors.lightGreen.shade500),
          Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  height: h * 0.15,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/dash_box.png",
                        height: h * 0.95 * 0.4,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                      ),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(referralCode.toString(),
                                  style: AppFont.bold(20, color: Colors.white)),
                              InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                            text: text1 + "\n" + text2))
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          Util.getTranslated(
                                              context, "copied_to_clipboard"),
                                          textAlign: TextAlign.center,
                                        ),
                                        backgroundColor: AppColor.appBlue(),
                                        duration: Duration(seconds: 2),
                                      ));
                                    });
                                  },
                                  child: Text(
                                      Util.getTranslated(
                                        context,
                                        "tap_to_copy",
                                      ),
                                      style: AppFont.regular(14,
                                          color: Colors.white)))
                            ],
                          ))
                    ],
                  ))),
        ]));
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16),
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

  Widget shareReferral() {
    String text1 = Util.getTranslated(context, "share_text_head") +
        "\n" +
        Util.getTranslated(context, "share_text_IOS_title") +
        "\n" +
        "https://apple.co/3cmWi2l" +
        "\n" +
        Util.getTranslated(context, "share_text_ANDROID_title") +
        "\n" +
        "https://bit.ly/3oncFyt" +
        "\n";
    String text2 = Util.getTranslated(context, "share_text1") +
        " " +
        referralCode.toString() +
        " " +
        Util.getTranslated(context, "share_text2");
    return Container(
        margin: EdgeInsets.only(top: 32),
        padding: EdgeInsets.only(left: 24, right: 24),
        width: 230,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            shape: BoxShape.rectangle,
            color: Colors.blue.shade200),
        child: InkWell(
            onTap: () {
              Share.share(text1 + "\n" + text2);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Util.getTranslated(context, "share_referral"),
                    style: AppFont.bold(16)),
                Image.asset("assets/images/share_icon.png")
              ],
            )));
  }

  Widget viewRewards() {
    return Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: InkWell(
            onTap: () async {
              if (viewRewardsUrl != null) {
                if (Platform.isAndroid) {
                  _launchBrowser(viewRewardsUrl.toString());
                } else if (Platform.isIOS) {
                  await launch(viewRewardsUrl.toString(), forceSafariVC: false);
                }
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, "alert_dialog_title_error_text"),
                    Util.getTranslated(context, "view_rewards_link"));
              }
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Util.getTranslated(context, "view_rewards"),
                    style: AppFont.bold(15),
                  ),
                  Image.asset(
                    Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
                    width: 20,
                    height: 20,
                  ),
                ])));
  }

  Widget termsCondition() {
    return Container(
        margin: EdgeInsets.only(bottom: 24),
        child: InkWell(
            onTap: () async {
              if (termsNConditionUrl != null) {
                if (Platform.isAndroid) {
                  _launchBrowser(termsNConditionUrl.toString());
                } else if (Platform.isIOS) {
                  await launch(termsNConditionUrl.toString(),
                      forceSafariVC: false);
                }
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, "alert_dialog_title_error_text"),
                    Util.getTranslated(context, "termsAndCondition"));
              }
            },
            child: Text(
                Util.getTranslated(context, "referrals_terms_condition"),
                style: AppFont.bold(16, color: AppColor.appBlue()))));
  }

  _launchBrowser(String website) async {
    String url = website;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
