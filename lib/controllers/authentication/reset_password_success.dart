import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class ResetPasswordSuccess extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordSuccessState();
  }
}

class _ResetPasswordSuccessState extends State<ResetPasswordSuccess> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.analytics_reset_password_success);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: successContent(),
      bottomSheet: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: doneBtn(context)),
    ));
  }

  Widget successContent() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        height: screenHeight - 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            successIcon(),
            SizedBox(
              height: 8,
            ),
            successWordings(),
          ],
        ));
  }

  Widget successIcon() {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        Constants.ASSET_IMAGES + "success_icon.png",
        fit: BoxFit.contain,
        width: 50,
      ),
    );
  }

  Widget successWordings() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        Util.getTranslated(context, 'reset_password_success'),
        style: AppFont.bold(30,
            color: AppColor.appBlue(), decoration: TextDecoration.none),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget doneBtn(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth - 60,
      height: 50,
      child: TextButton(
        onPressed: () {
          onDone(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Util.getTranslated(context, 'signup_success_done_btn'))
          ],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: AppFont.bold(17, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void onDone(BuildContext context) async {
    int count = 4;
    Navigator.of(context).popUntil((_) => count-- <= 0);
  }
}
