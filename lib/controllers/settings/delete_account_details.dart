import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/delete_account_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DeleteAccountDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeleteAccountDetails();
  }
}

class _DeleteAccountDetails extends State<DeleteAccountDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final myCurrPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_delete_account);
    
  }

  Future<void> deleteAccount(BuildContext context, String password) async {
    DeleteAccountApi deleteAccountApi = DeleteAccountApi(context);
    return deleteAccountApi.deleteAccount(password);
  }

  @override
  void dispose() {
    myCurrPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
              padding: EdgeInsets.only(left: 16, right: 16),
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
                              Util.getTranslated(context, "delete_account"),
                              AppFont.bold(
                                20,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 10),
                            labelText(
                              Util.getTranslated(context, "cfm_password_delete_account"),
                              AppFont.regular(
                                14,
                                color: AppColor.appDarkGreyColor(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 30),
                            labelText(
                              Util.getTranslated(
                                context, "delete_acc_password"),
                              AppFont.bold(
                                16,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            passwordTextField(myController: myCurrPassController),
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
                    submitButton(context),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
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
      obscureText: true,
      obscuringCharacter: "*",
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: Util.getTranslated(context, "enter_password_delete_account"),
        hintStyle: AppFont.regular(15,
          decoration: TextDecoration.none),
      ),
      style: AppFont.regular(
        16,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget submitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: () {
          if (myCurrPassController.text.length > 0){
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            confirmDeleteAccount(context);
          }
        },
        color: myCurrPassController.text.length > 0 ? AppColor.appBlue() : AppColor.appAirForceBlue(),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            Util.getTranslated(context, "btn_submit"),
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

  confirmDeleteAccount(BuildContext context) {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    
    deleteAccount(context, myCurrPassController.text).then((value) {
      EasyLoading.dismiss();
      accountDeleteSuccess();
    }, onError: (error){
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
      Util.printInfo('DELETE ACCOUNT ERROR: $error');
    });
  }
  
  void accountDeleteSuccess(){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => new CupertinoAlertDialog(
        title: new Text(
            Util.getTranslated(context, "delete_account_success")),
        content: new Text(
            Util.getTranslated(context, "delete_account_success_content")),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(Util.getTranslated(context, "done_lbl"),),
            onPressed: () {
              Navigator.pop(context);
              AppCache.removeValues();
              Navigator.pushNamedAndRemoveUntil(context, MyRoute.landingRoute, (route) => false);
            },
          ),
          
        ],
      ),
    );
  }
}
