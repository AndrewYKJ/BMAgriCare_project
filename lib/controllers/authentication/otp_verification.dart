import 'dart:async';
import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/forget_password_mobile_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/request_otp_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/sign_up_vietnam_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/verify_otp_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/reset_password_argument.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'auth_widgets.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phonenNo;
  final String fullname;
  final String password;
  final String area;
  final bool agreeMarketUpdate;
  final File photo;
  final bool isRegister;
  final String referralCode;

  OtpVerificationPage({
    Key key,
    this.phonenNo,
    this.fullname,
    this.password,
    this.area,
    this.referralCode,
    this.agreeMarketUpdate,
    this.photo,
    this.isRegister,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OtpVerificationPageState();
  }
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType> errorController;

  String cacheLanguage = "";
  String cacheCountry = "";
  bool hasError = false;
  String errorMsg = "";
  String otpCode = "";
  final formKey = GlobalKey<FormState>();
  final interval = const Duration(seconds: 1);
  final int timerMaxSeconds = 60;
  int currentSeconds = 0;
  bool hasResendOtp = false;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}  ';

  startTimeout([int milliseconds]) {
    var duration = interval;
    Timer.periodic(duration, (timer) {
      if (this.mounted) {
        setState(() {
          currentSeconds = timer.tick;
          if (timer.tick >= timerMaxSeconds) timer.cancel();
        });
      }
    });
  }

  Future<Response> requestOtp(BuildContext context, String password,
      String name, String language, String phoneNo, String countryCode) async {
    RequestOtpApi requestOtpApi = RequestOtpApi(context);
    return requestOtpApi.requestOtp(
        name, password, language, phoneNo, countryCode);
  }

  Future<void> signUpMobile(
      BuildContext context,
      String phoneNo,
      String password,
      String name,
      File photo,
      bool agreeMarketingUpdate,
      String otpCode,
      String area,
      String countryCode,
      String referralCode) async {
    SignUpMobileApi signUpMobileApi = SignUpMobileApi(context);
    return signUpMobileApi.signUp(name, photo, password, agreeMarketingUpdate,
        otpCode, phoneNo, countryCode,
        area: area, referralCode: referralCode);
  }

  Future<Response> resendOtpCode(
      BuildContext context, String phoneNo, String country) async {
    ForgetPasswordMobileApi forgetPasswordApi =
        ForgetPasswordMobileApi(context);
    return forgetPasswordApi.forgetPassword(phoneNo, country);
  }

  Future<Response> verifyOtpCode(String otpCode) async {
    VerifyOtpApi verifyOtpApi = VerifyOtpApi(context);
    return verifyOtpApi.verifyOtp(otpCode);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_otp_verification);
    errorController = StreamController<ErrorAnimationType>();
    startTimeout();

    AppCache.getStringValue(AppCache.LANGUAGE_CODE_PREF).then((value) {
      cacheLanguage = value;
    });

    AppCache.getCountry().then((value) {
      cacheCountry = value;
    });

    textEditingController.addListener(() {
      setState(() {});
    });

    Util.printInfo(
        ">>>>>>> PhoneNo: ${widget.phonenNo} | ${widget.isRegister}");
  }

  @override
  void dispose() {
    errorController.close();
    textEditingController.dispose();
    super.dispose();
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
          color: Colors.white,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 16),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [AuthWidget.backButton(context)]),
                        SizedBox(height: 10),
                        Row(children: [otpHeaderLbl()]),
                        SizedBox(height: 10),
                        Row(children: [otpSubHeaderLbl()]),
                        SizedBox(height: 20),
                        Text(
                          errorMsg,
                          style: AppFont.regular(
                            14,
                            color: AppColor.errorRed(),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 80),
                        otpFormField(context),
                        SizedBox(height: 20),
                        Text(
                          Util.getTranslated(context,
                              "otp_verification_not_receive_code_text"),
                          style: AppFont.regular(
                            14,
                            color: Colors.grey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        resendCodeLayout(context),
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

  Widget otpHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 60,
        height: 25,
        child: Text(
          Util.getTranslated(context, "otp_vertification_title"),
          style: AppFont.bold(20,
              color: AppColor.appBlue(), decoration: TextDecoration.none),
        ));
  }

  Widget otpSubHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth - 60,
      child: RichText(
        text: TextSpan(
          text: Util.getTranslated(context, "otp_vertification_subtitle"),
          children: [
            TextSpan(
              text: " ${widget.phonenNo}",
              style: AppFont.regular(14,
                  color: AppColor.appBlue(), decoration: TextDecoration.none),
            ),
          ],
          style: AppFont.regular(14,
              color: Colors.grey, decoration: TextDecoration.none),
        ),
      ),
    );
  }

  Widget otpFormField(BuildContext context) {
    return Form(
      key: formKey,
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        backgroundColor: Colors.white,
        obscureText: false,
        textStyle: AppFont.semibold(
          20,
          color: hasError ? AppColor.errorRed() : AppColor.appBlue(),
          decoration: TextDecoration.none,
        ),
        pinTheme: PinTheme(
          inactiveFillColor:
              hasError ? AppColor.errorRed() : AppColor.appBlue(),
          inactiveColor: hasError ? AppColor.errorRed() : AppColor.appBlue(),
          activeColor: hasError ? AppColor.errorRed() : AppColor.appBlue(),
          activeFillColor: hasError ? AppColor.errorRed() : AppColor.appBlue(),
          selectedColor: hasError ? AppColor.errorRed() : AppColor.appBlue(),
          selectedFillColor:
              hasError ? AppColor.errorRed() : AppColor.appBlue(),
        ),
        cursorColor: AppColor.appBlue(),
        animationType: AnimationType.fade,
        animationDuration: Duration(milliseconds: 100),
        errorAnimationController: errorController,
        keyboardType: TextInputType.number,
        controller: textEditingController,
        onChanged: (value) {
          setState(() {
            if (hasError) {
              hasError = false;
              errorMsg = "";
            }
          });
        },
        onCompleted: (value) {
          setState(() {
            otpCode = value;
          });
        },
      ),
    );
  }

  resendCodeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            if (currentSeconds >= timerMaxSeconds) {
              await EasyLoading.show(maskType: EasyLoadingMaskType.black);
              if (widget.isRegister) {
                onRequestOtp(context);
              } else {
                onResendOtp(context);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColor.appBlue(),
                ),
              ),
            ),
            child: Text(
              Util.getTranslated(context, "otp_verification_resend_code_text"),
              style: AppFont.semibold(
                14,
                color: AppColor.appBlue(),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                timerText,
                style: AppFont.regular(
                  14,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget submitBtn(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth - 60,
      height: 50,
      child: TextButton(
        onPressed: () {
          if (textEditingController.text.isNotEmpty &&
              textEditingController.text.length == 6) {
            onSubmit(context);
          }
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
          backgroundColor: (textEditingController.text.isNotEmpty &&
                  textEditingController.text.length == 6)
              ? AppColor.appBlue()
              : AppColor.appAirForceBlue(),
          textStyle: AppFont.bold(17, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  void onSubmit(BuildContext context) async {
    Util.printInfo('on register submit : $otpCode');
    await EasyLoading.show(maskType: EasyLoadingMaskType.black);
    if (widget.isRegister) {
      String mArea =
          widget.area != null && widget.area.length > 0 ? widget.area : null;
      String refCode =
          widget.referralCode != null && widget.referralCode.length > 0
              ? widget.referralCode
              : null;
      signUpMobile(
              context,
              widget.phonenNo,
              widget.password,
              widget.fullname,
              widget.photo,
              widget.agreeMarketUpdate,
              otpCode,
              mArea,
              cacheCountry,
              refCode)
          .then((value) {
        EasyLoading.dismiss();
        Navigator.pushNamed(context, MyRoute.signUpSuccessRoute,
            arguments: [true]);
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
      verifyOtpCode(otpCode).then((value) {
        EasyLoading.dismiss();
        Navigator.pushNamed(context, MyRoute.resetPasswordMobileRoute,
            arguments: ResetPasswordArguments(otpCode, widget.phonenNo));
      }, onError: (error) {
        EasyLoading.dismiss();
        if (error is DioError) {
          if (error.response != null) {
            if (error.response.data != null) {
              ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
              setState(() {
                errorMsg = errorDTO.message;
                hasError = true;
              });
            } else {
              setState(() {
                errorMsg = Util.getTranslated(
                    context, 'general_alert_message_error_response');
                hasError = true;
              });
            }
          } else {
            setState(() {
              errorMsg = Util.getTranslated(
                  context, 'general_alert_message_error_response');
              hasError = true;
            });
          }
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, 'alert_dialog_title_error_text'),
              Util.getTranslated(
                  context, 'general_alert_message_error_response_2'));
        }
      });
    }
  }

  void onRequestOtp(BuildContext context) {
    requestOtp(context, widget.password, widget.fullname, cacheLanguage,
            widget.phonenNo, cacheCountry)
        .then((value) {
      EasyLoading.dismiss();
      setState(() {
        hasResendOtp = true;
        otpCode = "";
        textEditingController.clear();
        currentSeconds = 0;
        startTimeout();
      });
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
  }

  void onResendOtp(BuildContext context) {
    resendOtpCode(context, widget.phonenNo, cacheCountry).then((value) {
      EasyLoading.dismiss();
      setState(() {
        hasResendOtp = true;
        otpCode = "";
        textEditingController.clear();
        currentSeconds = 0;
        startTimeout();
      });
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
  }
}
