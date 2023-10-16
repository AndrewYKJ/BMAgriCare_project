import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/home/crop_programme_issue_detail.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_programme_issue.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CropProgrammeWebBrowser extends StatefulWidget {
  final int id;

  CropProgrammeWebBrowser({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CropProgrammeWebBrowser();
  }
}

class _CropProgrammeWebBrowser extends State<CropProgrammeWebBrowser> {
  String appBarTitle = "";
  String sharePdf = "";
  WebViewController myWebViewController;
  CropProgrammeIssuesDTO crops;

  Future<CropProgrammeIssuesDTO> fetchCropProgrammeIssue(BuildContext ctx) {
    CropProgrammeIssueApi cropProgrammeIssueApi = CropProgrammeIssueApi(ctx);
    return cropProgrammeIssueApi.call(widget.id);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(
        screenName: Constants.analytics_crop_programme_web_browser);
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    getCropIssue();
  }

  getCropIssue() async {
    EasyLoading.show();
    await fetchCropProgrammeIssue(context).then((value) {
      if (value.programmes != null && value.programmes.length > 0) {
        setState(() {
          crops = value;
          sharePdf = value.programmes.first.shareUrl; 
        });
      } else {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, "error_title"),
            Util.getTranslated(context, "general_error"),
        );
      }
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
    }).whenComplete(() => EasyLoading.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              child: appBar(context),
              height: 50,
            ),
            body: crops != null ? SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height-50,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height-50,
                    child: PDF().cachedFromUrl(
                      crops.programmes.first.viewUrl, 
                      placeholder: (progress) {
                        return Center(
                          child: Text(Util.getTranslated(context, 'product_details_loading')),
                        );        
                      },
                    ),
                  ),
                ),
              ),
            ) : Container(),
          )
        ),
        onWillPop: () async {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          return true;
        });
  }

  Widget appBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.appHintTextGreyColor(),
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                if (EasyLoading.isShow) {
                  EasyLoading.dismiss();
                }
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    Util.getTranslated(
                        context, "crop_programme_web_browser_back_text"),
                    style: AppFont.regular(
                      18,
                      color: Colors.blue,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                appBarTitle,
                textAlign: TextAlign.center,
                style: AppFont.semibold(
                  18,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                if (sharePdf != null && sharePdf.length > 0) {
                  Share.share(sharePdf);
                }
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.share,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

fetchCropProgrammeIssue(BuildContext context) {}
