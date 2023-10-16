import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class ForgetPasswordConfirm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgetPasswordConfirmState();
  }
}

class _ForgetPasswordConfirmState extends State<ForgetPasswordConfirm> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.analytics_forget_password_success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: ConstrainedBox(
                constraints: constraints.copyWith(
                  minHeight: constraints.maxHeight,
                  maxHeight: double.infinity,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 250),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              child: Image.asset(
                                Constants.ASSET_IMAGES + "sent_email_icon.png",
                                fit: BoxFit.contain,
                                width: 70,
                              ))
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(children: [confirmHeaderLbl()]),
                      Row(children: [confirmSubHeaderLbl()]),
                      SizedBox(height: 20),
                      Row(
                        children: [],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            color: Colors.transparent,
                            padding: EdgeInsets.all(12.0),
                            child: submitBtn(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget confirmHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 40,
        height: 100,
        child: Text(
          Util.getTranslated(context, "forgot_confirm_header_title"),
          textAlign: TextAlign.center,
          maxLines: 3,
          style: AppFont.bold(30,
              color: AppColor.appBlue(), decoration: TextDecoration.none),
        ));
  }

  Widget confirmSubHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 40,
        height: 40,
        child: Text(
          Util.getTranslated(context, "forgot_confirm_subheader_title"),
          textAlign: TextAlign.center,
          style: AppFont.regular(16,
              color: Colors.grey, decoration: TextDecoration.none),
        ));
  }

  Widget submitBtn(BuildContext context) {
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
            Text(Util.getTranslated(context, "forgot_confirm_done_btn"))
          ],
        ),
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

  void onDone(BuildContext context) async {
    Util.printInfo('on forget confirm');
    int count = 2;
    Navigator.of(context).popUntil((_) => count-- <= 0);
  }
}
