import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/mobile_reset_password.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ResetPassword extends StatefulWidget {
  final String otpCode;
  final String mobileNo;

  ResetPassword({Key key, this.otpCode, this.mobileNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ResetPassword();
  }
}

class _ResetPassword extends State<ResetPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final myNewPassController = TextEditingController();
  final myRetypePassController = TextEditingController();

  bool hasFillInAll = false;

  void _callResetPassword(BuildContext ctx, String otp, String newPass) {
    MobileResetPasswordApi resetPasswordApi = MobileResetPasswordApi(ctx);
    resetPasswordApi
        .resetPassword(otp, newPass, widget.mobileNo)
        .then((value) {
          if (value.statusCode == HttpStatus.ok) {
            myNewPassController.clear();
            myRetypePassController.clear();
            Navigator.pushNamed(context, MyRoute.resetPasswordSuccessRoute);
          } else {
            EasyLoading.showError(
                Util.getTranslated(context, "reset_password_failed"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
          }
        })
        .whenComplete(() => EasyLoading.dismiss())
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
                Util.showAlertDialog(
                  _scaffoldKey.currentContext,
                  Util.getTranslated(context, "alert_dialog_title_error_text"),
                  Util.getTranslated(
                      context, 'general_alert_message_error_response'));
              }
            } else {
              EasyLoading.showError(
                  Util.getTranslated(context, "reset_password_failed"),
                  duration: Duration(milliseconds: 2000),
                  maskType: EasyLoadingMaskType.black);
            }
          } else {
            EasyLoading.showError(
                Util.getTranslated(context, "reset_password_failed"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
          }
        });
  }

  void textFieldOnChange() {
    setState(() {
      if (myNewPassController.text.trim().isNotEmpty &&
          myRetypePassController.text.trim().isNotEmpty) {
        hasFillInAll = true;
      } else {
        hasFillInAll = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.anayltics_reset_password_mobile);
    myNewPassController.addListener(textFieldOnChange);
    myRetypePassController.addListener(textFieldOnChange);
  }

  @override
  void dispose() {
    myNewPassController.dispose();
    myRetypePassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(
            child: backButton(context),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            labelText(
                              Util.getTranslated(
                                  context, "reset_password_mobile_head_title"),
                              AppFont.bold(
                                20,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 10),
                            labelText(
                              Util.getTranslated(context,
                                  "reset_password_mobile_head_subtitle"),
                              AppFont.regular(
                                14,
                                color: AppColor.appDarkGreyColor(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 30),
                            labelText(
                              Util.getTranslated(
                                  context, "setting_change_password_new_pass"),
                              AppFont.bold(
                                16,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 10),
                            passwordTextField(
                                myController: myNewPassController),
                            dottedLineSeperator(
                              height: 1.5,
                              color: AppColor.appBlue(),
                            ),
                            SizedBox(height: 20),
                            labelText(
                              Util.getTranslated(context,
                                  "setting_change_password_confirm_pass"),
                              AppFont.bold(
                                16,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 10),
                            passwordTextField(
                                myController: myRetypePassController),
                            dottedLineSeperator(
                              height: 1.5,
                              color: AppColor.appBlue(),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    saveButton(context),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: () async => false,
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
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => new CupertinoAlertDialog(
                content: new Text(Util.getTranslated(
                    context, 'dialog_quit_reset_password_title')),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                        Util.getTranslated(context, 'alert_dialog_no_text')),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                        Util.getTranslated(context, 'alert_dialog_yes_text')),
                    onPressed: () {
                      int count = 4;
                      Navigator.of(context).popUntil((_) => count-- <= 0);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget labelText(String labelName, TextStyle labelTextStyle) {
    return Text(
      labelName,
      style: labelTextStyle,
    );
  }

  Widget passwordTextField({TextEditingController myController}) {
    return TextField(
      controller: myController,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      style: AppFont.regular(
        16,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget saveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: () {
          if (hasFillInAll) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }

            onResetPassword(context);
          }
        },
        color: hasFillInAll ? AppColor.appBlue() : AppColor.appAirForceBlue(),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            Util.getTranslated(context, "btn_save"),
            style: AppFont.bold(
              16,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  onResetPassword(BuildContext context) {
    if (myNewPassController.text != myRetypePassController.text) {
      Util.showAlertDialog(
          context,
          Util.getTranslated(context, "alert_dialog_title_info_text"),
          Util.getTranslated(
              context, "general_alert_message_password_not_match"));
    } else {
      EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
      );
      _callResetPassword(
          context, widget.otpCode, myNewPassController.text.trim());
    }
  }
}
