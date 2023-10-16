import 'dart:convert';
import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/setting/checknow_collectpoints.dart';
import 'package:behn_meyer_flutter/dio/api/setting/checknow_validateproducts.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/setting/checknow_point.dart';
import 'package:behn_meyer_flutter/models/setting/checknow_validateproduct.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QrcodeScanner extends StatefulWidget {
  final String scannerType;

  QrcodeScanner({Key key, this.scannerType}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QrcodeScanner();
  }
}

class _QrcodeScanner extends State<QrcodeScanner> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final textEditController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isCameraPause = false;
  var errorMsgMap = {
    'URL_NOT_FOUND': 'checknow_error_url_not_found',
    'LOYALTY_NOT_AVAILABLE': 'checknow_error_loyalty_not_available',
    'LOYALTY_NO_POINT_FOR_COLLECTION':
        'checknow_error_loyalty_no_point_for_collecion',
    'POINT_COLLECTED': 'checknow_error_point_collected',
    'UNKNOWN_ERROR': 'general_alert_message_check_now_error',
    'INVALID_TOKEN': 'general_alert_message_check_now_error',
    'PERMISSION_DENIED': 'general_alert_message_check_now_error',
    'IP_REQUIRED': 'general_alert_message_check_now_error',
    'INVALID_PIN': 'checknow_error_invalid_pin',
    'INVALID_AUTHORIZATION_TOKEN': 'general_alert_message_check_now_error',
  };

  Future<CheckNowPointDTO> callCollectPoints(
      BuildContext context, String qrcodeContent) async {
    var body = {'url': qrcodeContent};
    CheckNowCollectPointApi checkNowCollectPointApi =
        CheckNowCollectPointApi(context, bodyData: body);
    return checkNowCollectPointApi.call();
  }

  Future<CheckNowValidateProductDTO> callValidateProduct(
      BuildContext context, String qrcodeContent) {
    var body = {'url': qrcodeContent};
    CheckNowValidateProductsApi checkNowValidateProductsApi =
        CheckNowValidateProductsApi(context, bodyData: body);
    return checkNowValidateProductsApi.call();
  }

  Future<CheckNowValidateProductDTO> callValidateProductWithPin(
      BuildContext context, String qrcodeContent, String pin) {
    var body = {'url': qrcodeContent, 'pin': pin};
    CheckNowValidateProductsApi checkNowValidateProductsApi =
        CheckNowValidateProductsApi(context, bodyData: body);
    return checkNowValidateProductsApi.call();
  }

  _launchBrowser(String website) async {
    String url = website;
    if (await canLaunch(url)) {
      if (Platform.isIOS) {
        await launch(url, forceSafariVC: false);
      } else {
        await launch(url);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    if (widget.scannerType == Constants.SCANNER_TYPE_EARN_POINT) {
      FirebaseAnalytics()
          .setCurrentScreen(screenName: Constants.analytics_checknow_earnpoint);
    } else {
      FirebaseAnalytics().setCurrentScreen(
          screenName: Constants.analytics_checknow_validate_product);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    textEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _buildQrView(context),
              ),
              backButton(context),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 10),
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

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (ctrl) => _onQRViewCreated(context, ctrl),
      overlay: QrScannerOverlayShape(
          borderColor: AppColor.appLightGreyColor(),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(BuildContext context, QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (scanData != null &&
          scanData.code != null &&
          scanData.code.length > 0 &&
          !this.isCameraPause) {
        setState(() {
          this.isCameraPause = true;
        });
        controller.pauseCamera();
        EasyLoading.show(maskType: EasyLoadingMaskType.black);
        if (widget.scannerType == Constants.SCANNER_TYPE_EARN_POINT) {
          callCollectPoints(context, scanData.code).then((value) {
            if (value != null) {
              if (value.statusCode == "200") {
                showResultInfo(
                    context,
                    Util.getTranslated(
                        context, "setting_checknow_earned_point_title"),
                    Util.getTranslated(context,
                            "setting_checknow_earned_point_message_1") +
                        " ${value.points} " +
                        Util.getTranslated(
                            context, "setting_checknow_earned_point_message_2"),
                    false,
                    controller);
              } else {
                if (value.error != null && value.error.length > 0) {
                  if (value.error == 'POINT_COLLECTED') {
                    showPointCollectedByOthersInfo(
                        context,
                        Util.getTranslated(
                            context, "alert_dialog_title_error_text"),
                        Util.getTranslated(context, errorMsgMap[value.error]),
                        value.reportUrl,
                        false,
                        controller);
                  } else {
                    showResultInfo(
                        context,
                        Util.getTranslated(
                            context, "alert_dialog_title_error_text"),
                        Util.getTranslated(context, errorMsgMap[value.error]),
                        false,
                        controller);
                  }
                } else {
                  showResultInfo(
                      context,
                      Util.getTranslated(
                          context, "alert_dialog_title_error_text"),
                      Util.getTranslated(
                          context, "general_alert_message_error_response_2"),
                      false,
                      controller);
                }
              }
            }
          }).whenComplete(() {
            EasyLoading.dismiss();
          }).catchError((error) {
            if (error is DioError) {
              if (error.response != null) {
                if (error.response.data != null) {
                  showResultInfo(
                      context,
                      Util.getTranslated(
                          context, "alert_dialog_title_error_text"),
                      ErrorDTO.fromJson(error.response.data).message +
                          "(${ErrorDTO.fromJson(error.response.data).code})",
                      false,
                      controller);
                } else {
                  showResultInfo(
                      context,
                      Util.getTranslated(
                          context, "alert_dialog_title_error_text"),
                      Util.getTranslated(
                          context, "general_alert_message_error_response_2"),
                      false,
                      controller);
                }
              } else {
                if (error.type == DioErrorType.other){
                  if (error.message.contains("Failed host lookup")){
                      showResultInfo(
                        context,
                        Util.getTranslated(
                            context, "alert_dialog_title_error_text"),
                        Util.getTranslated(
                            context, "general_internet_connection_message_check_now"),
                        false,
                        controller);
                  }
                } else {
                  showResultInfo(
                    context,
                    Util.getTranslated(
                        context, "alert_dialog_title_error_text"),
                    Util.getTranslated(
                        context, "general_alert_message_error_response_2"),
                    false,
                    controller);
                }
              }
            } else {
              showResultInfo(
                  context,
                  Util.getTranslated(context, "alert_dialog_title_error_text"),
                  Util.getTranslated(
                      context, "general_alert_message_error_response_2"),
                  false,
                  controller);
            }
          });
        } else if (widget.scannerType ==
            Constants.SCANNER_TYPE_VALIDATE_PRODUCT) {
          callValidateProduct(context, scanData.code).then((value) {
            if (value != null) {
              if (value.statusCode == "200") {
                showProductInfo(context, value, false, controller);
              } else if (value.statusCode == "403") {
                showInputPinCodeDialog(context, scanData.code, controller);
              } else {
                if (value.error != null && value.error.length > 0) {
                  showResultInfo(
                      context,
                      Util.getTranslated(
                          context, "alert_dialog_title_error_text"),
                      Util.getTranslated(context, errorMsgMap[value.error]),
                      false,
                      controller);
                } else {
                  showResultInfo(
                      context,
                      Util.getTranslated(
                          context, "alert_dialog_title_error_text"),
                      Util.getTranslated(
                          context, "general_alert_message_error_response_2"),
                      false,
                      controller);
                }
              }
            }
          }).whenComplete(() {
            EasyLoading.dismiss();
          }).catchError((error) {
            if (error is DioError) {
              if (error.response != null) {
                if (error.response.data != null) {
                  if (error.response.data['code'].toString() != null &&
                      error.response.data['code'].toString().length > 0) {
                    showResultInfo(
                        context,
                        Util.getTranslated(
                            context, "alert_dialog_title_error_text"),
                        ErrorDTO.fromJson(error.response.data).message +
                            "(${ErrorDTO.fromJson(error.response.data).code})",
                        false,
                        controller);
                  } else {
                    showResultInfo(
                        context,
                        Util.getTranslated(
                            context, "alert_dialog_title_error_text"),
                        Util.getTranslated(
                            context, "general_alert_message_error_response_2"),
                        false,
                        controller);
                  }
                } else {
                  showResultInfo(
                      context,
                      Util.getTranslated(
                          context, "alert_dialog_title_error_text"),
                      Util.getTranslated(
                          context, "general_alert_message_error_response_2"),
                      false,
                      controller);
                }
              } else {
                if (error.type == DioErrorType.other){
                  if (error.message.contains("Failed host lookup")){
                      showResultInfo(
                        context,
                        Util.getTranslated(
                            context, "alert_dialog_title_error_text"),
                        Util.getTranslated(
                            context, "general_internet_connection_message_check_now"),
                        false,
                        controller);
                  }
                } else {
                  showResultInfo(
                    context,
                    Util.getTranslated(
                        context, "alert_dialog_title_error_text"),
                    Util.getTranslated(
                        context, "general_alert_message_error_response_2"),
                    false,
                    controller);
                }
              }
            } else {
              showResultInfo(
                  context,
                  Util.getTranslated(context, "alert_dialog_title_error_text"),
                  Util.getTranslated(
                      context, "general_alert_message_error_response_2"),
                  false,
                  controller);
            }
          });
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    Util.printInfo('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The user did not allow camera access')),
      );
    }
  }

  void showProductInfo(
      BuildContext context,
      CheckNowValidateProductDTO productDTO,
      bool isGoBack,
      QRViewController controller) {
    showDialog(
      barrierDismissible: false,
      context: _scaffoldKey.currentContext,
      builder: (productDialogContext) {
        return WillPopScope(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: productDTO.authenticationStatus.toUpperCase() == "VALID"
                  ? productValidContentBox(
                      productDialogContext, isGoBack, productDTO)
                  : productSuspendContentBox(
                      productDialogContext, isGoBack, productDTO, controller),
            ),
            onWillPop: () async {
              return false;
            });
      },
    );
  }

  void showResultInfo(BuildContext context, String title, String message,
      bool isGoBack, QRViewController controller) {
    showDialog(
      barrierDismissible: false,
      context: _scaffoldKey.currentContext,
      builder: (normalDialogContext) {
        return WillPopScope(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: resultContentBox(
                  normalDialogContext, title, message, isGoBack, controller),
            ),
            onWillPop: () async {
              return false;
            });
      },
    );
  }

  void showPointCollectedByOthersInfo(
      BuildContext context,
      String title,
      String message,
      String reportUrl,
      bool isGoBack,
      QRViewController controller) {
    showDialog(
      barrierDismissible: false,
      context: _scaffoldKey.currentContext,
      builder: (pointCollectedDialogContext) {
        return WillPopScope(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: pointHaveCollectedByOthers(pointCollectedDialogContext,
                  isGoBack, title, message, reportUrl, controller),
            ),
            onWillPop: () async {
              return false;
            });
      },
    );
  }

  void showInputPinCodeDialog(
      BuildContext context, String scanData, QRViewController controller) {
    showDialog(
      barrierDismissible: false,
      context: _scaffoldKey.currentContext,
      builder: (inputDialogContext) {
        return WillPopScope(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: inputPinCodeContentBox(
                  inputDialogContext, scanData, controller),
            ),
            onWillPop: () async {
              return false;
            });
      },
    );
  }

  Widget productValidContentBox(BuildContext validContext, bool isGoBack,
      CheckNowValidateProductDTO productDTO) {
    return Container(
      padding:
          EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 12.0),
      margin: EdgeInsets.only(top: 45),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColor.checknowProductValidBgColor(),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Constants.ASSET_IMAGES + "Original_icon.png",
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10.0),
          Text(
            productDTO.productName,
            textAlign: TextAlign.center,
            style: AppFont.bold(
              20,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            Util.getTranslated(context,
                    "setting_checknow_validate_product_serial_number") +
                productDTO.serialNumber,
            style: AppFont.bold(
              16,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            Util.getTranslated(
                    context, "setting_checknow_validate_product_total_check") +
                productDTO.scanCount,
            style: AppFont.bold(
              16,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            Util.getTranslated(
                    context, "setting_checknow_validate_product_status") +
                productDTO.authenticationStatus.toUpperCase(),
            style: AppFont.bold(
              16,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 16.0),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _launchBrowser(productDTO.viewMoreUrl);
                    },
                    child: Container(
                      height: 60.0,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              Util.getTranslated(validContext, "view_more_btn"),
                              textAlign: TextAlign.center,
                              style: AppFont.bold(
                                16,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isGoBack) {
                        Navigator.of(validContext).pop();
                        Navigator.of(validContext).pop();
                      } else {
                        Navigator.of(validContext).pop();
                        setState(() {
                          this.isCameraPause = false;
                        });
                        controller.resumeCamera();
                      }
                    },
                    child: Container(
                      height: 60.0,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            Util.getTranslated(validContext, "close_btn"),
                            textAlign: TextAlign.center,
                            style: AppFont.bold(
                              16,
                              color: AppColor.appBlue(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // child: InkWell(
            //   onTap: () {
            //     if (isGoBack) {
            //       Navigator.of(validContext).pop();
            //       Navigator.of(validContext).pop();
            //     } else {
            //       Navigator.of(validContext).pop();
            //       controller.resumeCamera();
            //     }
            //   },
            //   child: Container(
            //     height: 40.0,
            //     padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            //     margin: EdgeInsets.only(left: 10.0),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(5),
            //       color: Colors.white,
            //     ),
            //     child: Text(
            //       Util.getTranslated(validContext, "alert_dialog_ok_text"),
            //       textAlign: TextAlign.center,
            //       style: AppFont.bold(
            //         16,
            //         color: AppColor.appBlue(),
            //         decoration: TextDecoration.none,
            //       ),
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }

  Widget productSuspendContentBox(BuildContext susContext, bool isGoBack,
      CheckNowValidateProductDTO productDTO, QRViewController controller) {
    return Container(
      padding:
          EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 12.0),
      margin: EdgeInsets.only(top: 45),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColor.checknowProductSuspendBgColor(),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Constants.ASSET_IMAGES + "suspended_icon.png",
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10.0),
          Text(
            productDTO.productName,
            textAlign: TextAlign.center,
            style: AppFont.bold(
              20,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            Util.getTranslated(context,
                    "setting_checknow_validate_product_serial_number") +
                productDTO.serialNumber,
            style: AppFont.bold(
              16,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            Util.getTranslated(
                    context, "setting_checknow_validate_product_status") +
                productDTO.authenticationStatus.toUpperCase(),
            style: AppFont.bold(
              16,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 16.0),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _launchBrowser(productDTO.reportUrl);
                    },
                    child: Container(
                      height: 60.0,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              Util.getTranslated(susContext, "report_now_btn"),
                              textAlign: TextAlign.center,
                              style: AppFont.bold(
                                16,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _launchBrowser(productDTO.viewMoreUrl);
                    },
                    child: Container(
                      height: 60.0,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              Util.getTranslated(susContext, "view_more_btn"),
                              textAlign: TextAlign.center,
                              style: AppFont.bold(
                                16,
                                color: AppColor.appBlue(),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (isGoBack) {
                Navigator.of(susContext).pop();
                Navigator.of(susContext).pop();
              } else {
                Navigator.of(susContext).pop();
                setState(() {
                  this.isCameraPause = false;
                });
                controller.resumeCamera();
              }
            },
            child: Container(
              height: 60.0,
              width: MediaQuery.of(susContext).size.width,
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  Util.getTranslated(susContext, "close_btn"),
                  textAlign: TextAlign.center,
                  style: AppFont.bold(
                    16,
                    color: AppColor.appBlue(),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pointHaveCollectedByOthers(
      BuildContext pointContext,
      bool isGoBack,
      String dialogTitle,
      String dialogContent,
      String reportUrl,
      QRViewController controller) {
    return Container(
      padding:
          EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 12.0),
      margin: EdgeInsets.only(top: 45),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            dialogTitle,
            style: AppFont.bold(17,
                color: AppColor.appBlue(), decoration: TextDecoration.none),
          ),
          SizedBox(height: 15),
          Text(
            dialogContent,
            style: AppFont.regular(15, color: AppColor.appBlack()),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _launchBrowser(reportUrl);
                      },
                      child: Container(
                        // height: 60.0,
                        // padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(right: 10.0),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColor.appBlue(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                Util.getTranslated(
                                    pointContext, "report_now_btn"),
                                textAlign: TextAlign.center,
                                style: AppFont.bold(
                                  16,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isGoBack) {
                          Navigator.of(pointContext).pop();
                          Navigator.of(pointContext).pop();
                        } else {
                          Navigator.of(pointContext).pop();
                          setState(() {
                            this.isCameraPause = false;
                          });
                          controller.resumeCamera();
                        }
                      },
                      child: Container(
                        // height: 60.0,
                        // padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(left: 10.0),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColor.appBlue(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Util.getTranslated(pointContext, "close_btn"),
                              textAlign: TextAlign.center,
                              style: AppFont.bold(
                                16,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultContentBox(BuildContext mContext, String dialogTitle,
      String dialogContent, bool isGoBack, QRViewController controller) {
    return Container(
      padding:
          EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 12.0),
      margin: EdgeInsets.only(top: 45),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            dialogTitle,
            style: AppFont.bold(17,
                color: AppColor.appBlue(), decoration: TextDecoration.none),
          ),
          SizedBox(height: 15),
          Text(
            dialogContent,
            style: AppFont.regular(15, color: AppColor.appBlack()),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
                onPressed: () {
                  if (isGoBack) {
                    Navigator.of(mContext).pop();
                    Navigator.of(mContext).pop();
                  } else {
                    Navigator.of(mContext).pop();
                    setState(() {
                      this.isCameraPause = false;
                    });
                    controller.resumeCamera();
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                    color: AppColor.appBlue(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    Util.getTranslated(mContext, "alert_dialog_ok_text"),
                    style: AppFont.bold(
                      16,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget inputPinCodeContentBox(
      BuildContext pinContext, String scanData, QRViewController controller) {
    return Container(
      padding:
          EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 12.0),
      margin: EdgeInsets.only(top: 45),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            Util.getTranslated(context, "setting_checknow_pincode_title"),
            style: AppFont.bold(17,
                color: AppColor.appBlue(), decoration: TextDecoration.none),
          ),
          SizedBox(height: 15),
          TextField(
            controller: textEditController,
            autofocus: true,
            decoration: new InputDecoration(
              hintText: Util.getTranslated(
                  context, "setting_checknow_pincode_hint_text"),
              hintStyle: AppFont.regular(
                16,
                color: AppColor.appHintTextGreyColor(),
                decoration: TextDecoration.none,
              ),
              focusColor: AppColor.appBlack(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColor.appBlack()),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColor.appBlack()),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColor.appBlack()),
              ),
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  if (textEditController.text != null &&
                      textEditController.text.trim().length > 0) {
                    Navigator.of(context).pop();
                    EasyLoading.show(maskType: EasyLoadingMaskType.black);
                    callValidateProductWithPin(
                            context, scanData, textEditController.text.trim())
                        .then((value) {
                      if (value != null) {
                        if (value.statusCode == "200") {
                          showProductInfo(context, value, false, controller);
                          // String productInfo = Util.getTranslated(context,
                          //         "setting_checknow_validate_product_serial_number") +
                          //     value.serialNumber +
                          //     "\n" +
                          //     Util.getTranslated(context,
                          //         "setting_checknow_validate_product_name") +
                          //     value.productName +
                          //     "\n" +
                          //     Util.getTranslated(context,
                          //         "setting_checknow_validate_product_status") +
                          //     value.authenticationStatus.toUpperCase();

                          // showResultInfo(
                          //     context,
                          //     Util.getTranslated(context,
                          //         "setting_checknow_validate_product_title"),
                          //     productInfo,
                          //     true,
                          //     controller);
                        } else {
                          if (value.error != null && value.error.length > 0) {
                            showResultInfo(
                                context,
                                Util.getTranslated(
                                    context, "alert_dialog_title_error_text"),
                                Util.getTranslated(
                                    context, errorMsgMap[value.error]),
                                false,
                                controller);
                          } else {
                            showResultInfo(
                                context,
                                Util.getTranslated(
                                    context, "alert_dialog_title_error_text"),
                                Util.getTranslated(context,
                                    "general_alert_message_error_response_2"),
                                false,
                                controller);
                          }
                        }
                      }
                    }).whenComplete(() {
                      EasyLoading.dismiss();
                      textEditController.clear();
                    }).catchError((error) {
                      if (error is DioError) {
                        if (error.response != null) {
                          if (error.response.data != null) {
                            showResultInfo(
                                context,
                                Util.getTranslated(
                                    context, "alert_dialog_title_error_text"),
                                ErrorDTO.fromJson(error.response.data).message +
                                    "(${ErrorDTO.fromJson(error.response.data).code})",
                                false,
                                controller);
                          } else {
                            showResultInfo(
                                context,
                                Util.getTranslated(
                                    context, "alert_dialog_title_error_text"),
                                Util.getTranslated(context,
                                    "general_alert_message_error_response_2"),
                                false,
                                controller);
                          }
                        } else {
                          showResultInfo(
                              context,
                              Util.getTranslated(
                                  context, "alert_dialog_title_error_text"),
                              Util.getTranslated(context,
                                  "general_alert_message_error_response_2"),
                              false,
                              controller);
                        }
                      } else {
                        showResultInfo(
                            context,
                            Util.getTranslated(
                                context, "alert_dialog_title_error_text"),
                            Util.getTranslated(context,
                                "general_alert_message_error_response_2"),
                            false,
                            controller);
                      }
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                    color: AppColor.appBlue(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    Util.getTranslated(context, "alert_dialog_ok_text"),
                    style: AppFont.bold(
                      16,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
