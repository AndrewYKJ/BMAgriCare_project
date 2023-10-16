import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/delete_account_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/login_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AccountSetting extends StatefulWidget {
  final User user;
  AccountSetting({Key key, @required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AccountSetting();
  }
}

class _AccountSetting extends State<AccountSetting> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_account_setting);
  }

  Future<void> deleteSocialAccount(BuildContext context) async {
    DeleteAccountApi deleteAccountApi = DeleteAccountApi(context);
    return deleteAccountApi.deleteSocialAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            child: backButton(context),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                accountLabelText(
                  labelName: Util.getTranslated(context, "account_setting"),
                  labelTextStyle: AppFont.bold(
                    20,
                    color: AppColor.appBlue(),
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(height: 20),
                changePassword(context),
                deleteAccount(context),
                SizedBox(height: 20),
                dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
              ],
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

  Widget accountLabelText({String labelName, TextStyle labelTextStyle}) {
    return Text(
      labelName,
      style: labelTextStyle,
    );
  }

  Widget changePassword(BuildContext context) {
    if (widget.user.userType == LoginType.Email.name ||
      widget.user.userType == LoginType.Mobile.name) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, MyRoute.changePasswordRoute);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Text(
                      Util.getTranslated(context, "setting_change_password"),
                      style: AppFont.bold(
                        16,
                        color: AppColor.appBlack(),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  Constants.ASSET_IMAGES + "blue_right_arrow_icon.png",
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          dottedLineSeperator(height: 1.5, color: AppColor.appBlue()),
          SizedBox(height: 20),
        ],
      );
    } else {
      return new Container();
    }
  }

  Widget deleteAccount(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => new CupertinoAlertDialog(
            title: new Text(
                Util.getTranslated(context, "delete_account_info")),
            content: new Text(
                Util.getTranslated(context, "delete_account_irreversible")),
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
                    context, 'yes_btn')),
                onPressed: () {
                  if (widget.user.userType == LoginType.Email.name ||
                    widget.user.userType == LoginType.Mobile.name) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, MyRoute.accountDeleteDetailsRoute);  
                  } else {
                    Navigator.pop(context);
                    EasyLoading.show(maskType: EasyLoadingMaskType.black);
                    deleteSocialAccount(context).then((value) {
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
                      Util.printInfo('DELETE SOCIAL ACCOUNT ERROR: $error');
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Text(
                Util.getTranslated(context, "delete_account"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
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
