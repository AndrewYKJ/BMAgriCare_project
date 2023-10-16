import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/forget_password_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'auth_widgets.dart';

class ForgetPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgetPasswordState();
  }
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailField = TextEditingController();
  bool _hasError = false;
  String errorMsg =
      "Your email address doesn't match our records. Please try again or check your spelling";
  String cachedLanguage = "";

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_forget_password);

    AppCache.getStringValue(AppCache.LANGUAGE_CODE_PREF).then((value) {
      setState(() {
        cachedLanguage = value;
      });
    });
  }

  Future<void> forgetPassword(
      BuildContext context, String email, String language) async {
    ForgetPasswordApi forgetPasswordApi = ForgetPasswordApi(context);
    return forgetPasswordApi.forgetPassword(email, language);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                            AuthWidget.textFieldForm(
                                context,
                                Util.getTranslated(
                                    context, "forgot_password_email_title"),
                                Util.getTranslated(context,
                                    "forgot_password_email_placeholder"),
                                emailField)
                          ],
                        ),
                        Row(
                          children: [
                            _hasError
                                ? SizedBox(
                                    width: screenWidth - 32,
                                    child: Text(errorMsg,
                                        style: AppFont.regular(14,
                                            color: AppColor.errorRed(),
                                            decoration: TextDecoration.none)))
                                : SizedBox(height: 0),
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
        height: 25,
        child: Text(
          Util.getTranslated(context, "forgot_password_subheader_title"),
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
          onSubmit(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Util.getTranslated(context, "forgot_password_submit_btn"))
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

  void onSubmit(BuildContext context) async {
    Util.printInfo('on forget submit');
    if (emailField.text.isNotEmpty) {
      bool emailValid = RegExp(
              r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
          .hasMatch(emailField.text);
      if (!emailValid) {
        return Util.showAlertDialog(
            context,
            Util.getTranslated(context, "alert_dialog_title_info_text"),
            Util.getTranslated(context, "authentication_invalid_email_format"));
      }

      await EasyLoading.show(maskType: EasyLoadingMaskType.black);

      String language;
      if (cachedLanguage.length > 0) {
        language = cachedLanguage;
      } else {
        language = "EN";
      }
      forgetPassword(context, emailField.text.trim(), language).then((value) {
        EasyLoading.dismiss();
        Navigator.pushNamed(context, MyRoute.forgetPasswordConfirmRoute);
      }, onError: (error) {
        EasyLoading.dismiss();
        if (error is DioError) {
          if (error.response != null){
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
        Util.printInfo('FORGET PASSWORD [ERROR]: $error');
      });
    } else {
      Util.showAlertDialog(
          context,
          Util.getTranslated(context, 'alert_dialog_title_info_text'),
          Util.getTranslated(context, 'forgot_password_email_empty'));
    }
  }
}
