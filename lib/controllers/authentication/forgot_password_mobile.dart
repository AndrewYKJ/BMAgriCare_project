import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/forget_password_mobile_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/otp_verify_argument.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'auth_widgets.dart';

class ForgetPasswordMobile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgetPasswordMobileState();
  }
}

class _ForgetPasswordMobileState extends State<ForgetPasswordMobile> {
  final phoneNoField = TextEditingController();
  String cachedCountry = "";

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.analytics_forget_password_mobile);

    AppCache.getCountry().then((value) {
      setState(() {
        cachedCountry = value;
      });
    });

    phoneNoField.addListener(() {
      setState(() {});
    });
  }

  Future<Response> forgetPassword(
      BuildContext context, String phoneNo, String country) async {
    ForgetPasswordMobileApi forgetPasswordApi =
        ForgetPasswordMobileApi(context);
    return forgetPasswordApi.forgetPassword(phoneNo, country);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
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
                        SizedBox(height: 16),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [AuthWidget.backButton(context)]),
                        SizedBox(height: 10),
                        Row(children: [forgetHeaderLbl()]),
                        Row(children: [forgetSubHeaderLbl()]),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            AuthWidget.phoneNoTextFieldForm(
                                context,
                                Util.getTranslated(context, "phoneno_title"),
                                Util.getTranslated(
                                    context, "phoneno_placeholder"),
                                phoneNoField)
                          ],
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
      ),
    );
  }

  Widget forgetHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 60,
        height: 25,
        child: Text(
          Util.getTranslated(context, "forgot_password_header_title"),
          style: AppFont.bold(20,
              color: AppColor.appBlue(), decoration: TextDecoration.none),
        ));
  }

  Widget forgetSubHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 60,
        // height: 25,
        child: Text(
          Util.getTranslated(
              context, "forgot_password_phoneno_subheader_title"),
          style: AppFont.regular(14,
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
          if (phoneNoField.text.isNotEmpty) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }

            onSubmit(context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(Util.getTranslated(context, "btn_submit"))],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: phoneNoField.text.isEmpty
              ? AppColor.appAirForceBlue()
              : AppColor.appBlue(),
          textStyle: AppFont.bold(17, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void onSubmit(BuildContext context) async {
    Util.printInfo('on forget submit');
    if (phoneNoField.text.isNotEmpty) {
      String mPhoneNo = "";
      if (phoneNoField.text.trim().startsWith('0')) {
        mPhoneNo = Constants.PHONE_CODE_VIETNAM + phoneNoField.text.trim();
      } else {
        mPhoneNo =
            Constants.PHONE_CODE_VIETNAM + "0" + phoneNoField.text.trim();
      }
      await EasyLoading.show(maskType: EasyLoadingMaskType.black);

      String country;
      if (cachedCountry.length > 0) {
        country = cachedCountry;
      } else {
        country = "MY";
      }

      forgetPassword(context, mPhoneNo, country).then((value) {
        EasyLoading.dismiss();
        Navigator.pushNamed(context, MyRoute.otpVerificationRoute,
            arguments: OtpVerifyArguments(
                mPhoneNo, null, null, null, null, false, null, false));
      }, onError: (error) {
        EasyLoading.dismiss();
        if (error is DioError) {
          if (error.response != null) {
            if (error.response.data != null) {
              ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  errorDTO.message);
            } else {
              Util.showAlertDialog(
                  context,
                  Util.getTranslated(context, 'alert_dialog_title_error_text'),
                  Util.getTranslated(
                      context, 'general_alert_message_error_response'));
            }
          } else {
            Util.showAlertDialog(
                context,
                Util.getTranslated(context, 'alert_dialog_title_error_text'),
                Util.getTranslated(
                    context, 'general_alert_message_error_response'));
          }
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, 'alert_dialog_title_error_text'),
              Util.getTranslated(
                  context, 'general_alert_message_error_response_2'));
        }
      });
    } else {
      Util.showAlertDialog(
          context,
          Util.getTranslated(context, 'alert_dialog_title_info_text'),
          Util.getTranslated(context, 'phoneno_empty'));
    }
  }
}
