import 'dart:io';

import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/qna/create_qna_api.dart';
import 'package:behn_meyer_flutter/dio/api/upload_photo_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

class CreateQna extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateQna();
  }
}

class _CreateQna extends State<CreateQna> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final qnaTitleController = TextEditingController();
  final qnaDescController = TextEditingController();

  List<int> qnaImagesId = [];
  List<File> imageFiles = [];
  bool hasFillInAll = false;
  final picker = ImagePicker();

  Future getCameraImage() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.camera);

      setState(() {
        if (pickedFile != null) {
          imageFiles.add(File(pickedFile.path));
        }
      });
    } catch (error) {
      if (error is PlatformException) {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, 'alert_dialog_title_error_text'),
            error.message);
      } else {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, 'alert_dialog_title_error_text'),
            Util.getTranslated(
                context, 'general_alert_message_error_response_2'));
      }
    }
  }

  Future getGalleryImage() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          imageFiles.add(File(pickedFile.path));
        }
      });
    } catch (error) {
      if (error is PlatformException) {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, 'alert_dialog_title_error_text'),
            error.message);
      } else {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, 'alert_dialog_title_error_text'),
            Util.getTranslated(
                context, 'general_alert_message_error_response_2'));
      }
    }
  }

  void _callUploadPhoto(BuildContext ctx, int index) {
    if (imageFiles != null && imageFiles.length > 0) {
      if (index < imageFiles.length) {
        UploadPhotoApi uploadPhotoApi = UploadPhotoApi(ctx);
        uploadPhotoApi.uploadPhoto(imageFiles[index]).then((value) {
          qnaImagesId.add(value);
          _callUploadPhoto(ctx, index + 1);
        }).catchError((error) {
          EasyLoading.dismiss();
          if (error is DioError) {
            if (error.response != null) {
              if (error.response.data != null){
                 Util.showAlertDialog(
                  ctx,
                  Util.getTranslated(context, "alert_dialog_title_error_text"),
                  ErrorDTO.fromJson(error.response.data).message +
                      "(${ErrorDTO.fromJson(error.response.data).code})");
              } else {
                EasyLoading.showError(
                  Util.getTranslated(
                      context, "general_alert_message_update_profile_failed"),
                  duration: Duration(milliseconds: 2000),
                  maskType: EasyLoadingMaskType.black);
              }
            } else {
              EasyLoading.showError(
                  Util.getTranslated(
                      context, "general_alert_message_update_profile_failed"),
                  duration: Duration(milliseconds: 2000),
                  maskType: EasyLoadingMaskType.black);
            }
          } else {
            EasyLoading.showError(
                Util.getTranslated(
                    context, "general_alert_message_update_profile_failed"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
          }
        });
      } else {
        _callCreateQna(context, qnaTitleController.text.trim(),
            qnaDescController.text.trim());
      }
    }
  }

  void _callCreateQna(BuildContext ctx, String title, String desc) {
    var bodyData = {};
    if (qnaImagesId != null && qnaImagesId.length > 0) {
      bodyData = {"title": title, "content": desc, "images": qnaImagesId};
    } else {
      bodyData = {"title": title, "content": desc};
    }

    CreateQnaApi createQnaApi = CreateQnaApi(ctx, bodyData: bodyData);
    createQnaApi
        .call()
        .then((value) {
          if (value.statusCode == HttpStatus.ok) {
            qnaTitleController.clear();
            qnaDescController.clear();
            imageFiles.clear();
            qnaImagesId.clear();
            EasyLoading.showSuccess(
                Util.getTranslated(
                    context, "general_alert_message_create_qna_success"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
            Navigator.pop(context);
          } else {
            EasyLoading.showError(
                Util.getTranslated(
                    context, "general_alert_message_create_qna_fail"),
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
                EasyLoading.showError(
                  Util.getTranslated(
                      context, "general_alert_message_create_qna_fail"),
                  duration: Duration(milliseconds: 2000),
                  maskType: EasyLoadingMaskType.black);
              }
            } else {
              EasyLoading.showError(
                  Util.getTranslated(
                      context, "general_alert_message_create_qna_fail"),
                  duration: Duration(milliseconds: 2000),
                  maskType: EasyLoadingMaskType.black);
            }
          } else {
            EasyLoading.showError(
                Util.getTranslated(
                    context, "general_alert_message_create_qna_fail"),
                duration: Duration(milliseconds: 2000),
                maskType: EasyLoadingMaskType.black);
          }
        });
  }

  void textFieldOnChange() {
    setState(() {
      if (qnaTitleController.text.trim().isNotEmpty &&
          qnaDescController.text.trim().isNotEmpty) {
        hasFillInAll = true;
      } else {
        hasFillInAll = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_create_qna);
    qnaTitleController.addListener(textFieldOnChange);
    qnaDescController.addListener(textFieldOnChange);
    imageFiles.add(File(""));
  }

  @override
  void dispose() {
    qnaTitleController.dispose();
    qnaDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                                context, "qna_question_header_title"),
                            AppFont.bold(
                              20,
                              color: AppColor.appBlue(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 30),
                          labelText(
                            Util.getTranslated(
                                context, "qna_question_title_label"),
                            AppFont.bold(
                              16,
                              color: AppColor.appBlue(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 10),
                          qnaTextField(
                              myController: qnaTitleController,
                              hintText: Util.getTranslated(
                                  context, "qna_question_title_hint_text")),
                          dottedLineSeperator(
                            height: 1.5,
                            color: AppColor.appBlue(),
                          ),
                          SizedBox(height: 20),
                          labelText(
                            Util.getTranslated(
                                context, "qna_question_desc_label"),
                            AppFont.bold(
                              16,
                              color: AppColor.appBlue(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 10),
                          qnaDescTextField(
                              myController: qnaDescController,
                              hintText: Util.getTranslated(
                                  context, "qna_question_desc_hint_text")),
                          dottedLineSeperator(
                            height: 1.5,
                            color: AppColor.appBlue(),
                          ),
                          SizedBox(height: 20),
                          labelText(
                            Util.getTranslated(
                                context, "qna_question_attachement_label"),
                            AppFont.bold(
                              16,
                              color: AppColor.appBlue(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 10),
                          qnaGridImages(context),
                          SizedBox(height: 20)
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

  Widget qnaTextField({TextEditingController myController, String hintText}) {
    return TextField(
      controller: myController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: AppFont.regular(
          16,
          color: Colors.grey[500],
          decoration: TextDecoration.none,
        ),
      ),
      style: AppFont.regular(
        16,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget qnaDescTextField(
      {TextEditingController myController, String hintText}) {
    return TextField(
      controller: myController,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: AppFont.regular(
          16,
          color: Colors.grey[500],
          decoration: TextDecoration.none,
        ),
      ),
      style: AppFont.regular(
        16,
        color: AppColor.appBlack(),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget qnaGridImages(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: imageFiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        crossAxisCount: 3,
        childAspectRatio: 1 / 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return createAddLayout(context);
        }
        return qnaImagesItem(context, imageFiles[index], index);
      },
    );
  }

  Widget createAddLayout(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        if (imageFiles != null && (imageFiles.length - 1) < 5) {
          showImagePicker(context);
        } else {
          Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "alert_message_qna_add_attachement"));
        }
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            child: Stack(
              children: [
                Container(
                  color: AppColor.appLightBlue().withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          Constants.ASSET_IMAGES + "ic_add_attachment_icon.png",
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          Util.getTranslated(
                              context, "qna_question_add_btn_text"),
                          style: AppFont.bold(
                            15,
                            color: AppColor.appBlue(),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget qnaImagesItem(context, File _imageFile, int index) {
    return Container(
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.file(
                _imageFile,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                setState(() {
                  imageFiles.removeAt(index);
                });
              },
              child: Image.asset(
                Constants.ASSET_IMAGES + "false_icon.png",
                width: 25,
                height: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showImagePicker(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                getGalleryImage();
              },
              child:
                  Text(Util.getTranslated(context, "choose_from_gallery_text")),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                getCameraImage();
              },
              child:
                  Text(Util.getTranslated(context, "choose_from_camera_text")),
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
          children: [
            ListTile(
              leading: new Icon(Icons.photo_library),
              title: Text(
                Util.getTranslated(context, "choose_from_gallery_text"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                getGalleryImage();
              },
            ),
            ListTile(
              leading: new Icon(Icons.photo_camera),
              title: Text(
                Util.getTranslated(context, "choose_from_camera_text"),
                style: AppFont.bold(
                  16,
                  color: AppColor.appBlack(),
                  decoration: TextDecoration.none,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                getCameraImage();
              },
            ),
          ],
        ),
      );
    }
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

            submitQuestion(context);
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

  Future<void> submitQuestion(BuildContext context) async {
    await EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
    if (imageFiles != null && imageFiles.length > 1) {
      imageFiles.removeAt(0);
      _callUploadPhoto(context, 0);
    } else {
      _callCreateQna(context, qnaTitleController.text.trim(),
          qnaDescController.text.trim());
    }
  }
}
