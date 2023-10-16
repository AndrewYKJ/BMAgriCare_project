import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/setting/update_user_profile_api.dart';
import 'package:behn_meyer_flutter/dio/api/upload_photo_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:behn_meyer_flutter/widget/custom_app_bar.dart';
import 'package:behn_meyer_flutter/widget/dotted_line.dart';
import 'package:behn_meyer_flutter/widget/image_url.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final User user;

  EditProfile({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditProfile();
  }
}

class _EditProfile extends State<EditProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController myEmailController;
  TextEditingController myMobileController;
  TextEditingController myFullnameController;
  TextEditingController myCompanyController;
  TextEditingController myAreaController;
  bool isReceiveMargetingUpd;
  bool hasFillInAll = true;

  File _imageFile;
  final picker = ImagePicker();

  Future getCameraImage() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.camera);

      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
          hasFillInAll = true;
        } else {
          Util.printInfo('No image selected.');
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
          _imageFile = File(pickedFile.path);
          hasFillInAll = true;
        } else {
          Util.printInfo('No image selected.');
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

  void textFieldOnChange() {
    setState(() {
      if (myFullnameController.text.trim().isNotEmpty) {
        hasFillInAll = true;
      } else {
        hasFillInAll = false;
      }
    });
  }

  void updateUserProfile(BuildContext ctx) {
    if (_imageFile != null) {
      _callUploadPhoto(ctx);
    } else {
      var bodyData = widget.user.country == Constants.COUNTRY_CODE_MALAYSIA
          ? {
              'name': myFullnameController.text.trim(),
              'company': myCompanyController.text.trim(),
              'agreeMarketingUpdate': isReceiveMargetingUpd
            }
          : {
              'name': myFullnameController.text.trim(),
              'area': myAreaController.text.trim(),
              'agreeMarketingUpdate': isReceiveMargetingUpd
            };
      _callUpdateUserProfile(ctx, bodyData);
    }
  }

  void _callUploadPhoto(BuildContext ctx) {
    UploadPhotoApi uploadPhotoApi = UploadPhotoApi(ctx);
    uploadPhotoApi.uploadPhoto(_imageFile).then((value) {
      _updateUserProfileWithNewPhoto(ctx, value);
    }).catchError((error) {
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
                  ctx, "general_alert_message_update_profile_failed"),
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
  }

  void _updateUserProfileWithNewPhoto(BuildContext ctx, int photoId) {
    var bodyData = {
      'photo': photoId,
      'name': myFullnameController.text,
      'agreeMarketingUpdate': isReceiveMargetingUpd
    };

    if (myCompanyController.text.isNotEmpty) {
      bodyData['company'] = myCompanyController.text.trim();
    }

    if (myAreaController.text.isNotEmpty) {
      bodyData['area'] = myAreaController.text.trim();
    }

    _callUpdateUserProfile(ctx, bodyData);
  }

  void _callUpdateUserProfile(BuildContext ctx, dynamic bodyData) {
    Util.printInfo(">>> UPDATE PROFILE PARAMS: " + bodyData.toString());
    UpdateUserProfileApi updateUserProfileApi =
        UpdateUserProfileApi(ctx, bodyData: bodyData);
    updateUserProfileApi.call().then((value) {
      if (value.statusCode == HttpStatus.ok) {
        AppCache.me = User.fromJson(value.data);
        EasyLoading.showSuccess(
            Util.getTranslated(
                context, "general_alert_message_update_profile_success"),
            duration: Duration(milliseconds: 2000),
            maskType: EasyLoadingMaskType.black);
      } else {
        EasyLoading.showError(
            Util.getTranslated(
                context, "general_alert_message_update_profile_failed"),
            duration: Duration(milliseconds: 2000),
            maskType: EasyLoadingMaskType.black);
      }
    }).catchError((error) {
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
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_edit_profile);
    myEmailController = TextEditingController(text: widget.user.email);
    myMobileController = TextEditingController(text: widget.user.mobileNo);
    myFullnameController = TextEditingController(text: widget.user.name);
    myCompanyController = TextEditingController(text: widget.user.company);
    myAreaController = TextEditingController(text: widget.user.area);
    isReceiveMargetingUpd = widget.user.agreeMarketingUpdate;
    myFullnameController.addListener(textFieldOnChange);
  }

  @override
  void dispose() {
    myEmailController.dispose();
    myMobileController.dispose();
    myFullnameController.dispose();
    myCompanyController.dispose();
    myAreaController.dispose();
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
                          profileLabelText(
                            Util.getTranslated(
                                context, "setting_edit_profile_title"),
                            AppFont.bold(
                              20,
                              color: AppColor.appBlue(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 10),
                          profileLabelText(
                            Util.getTranslated(
                                context, "setting_edit_profile_subtitle"),
                            AppFont.regular(
                              14,
                              color: AppColor.appDarkGreyColor(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 20),
                          avatarImg(context),
                          SizedBox(height: 20),
                          widget.user.userType == "mobile_no"
                              ? profileLabelText(
                                  Util.getTranslated(context, "phoneno_title"),
                                  AppFont.bold(
                                    16,
                                    color: AppColor.appBlue(),
                                    decoration: TextDecoration.none,
                                  ),
                                )
                              : profileLabelText(
                                  Util.getTranslated(
                                      context, "setting_edit_profile_email"),
                                  AppFont.bold(
                                    16,
                                    color: AppColor.appBlue(),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                          SizedBox(height: 10),
                          widget.user.userType == "mobile_no"
                              ? profileInfoTextField(myMobileController, false)
                              : profileInfoTextField(myEmailController, false),
                          dottedLineSeperator(
                            height: 1.5,
                            color: AppColor.appHintTextGreyColor(),
                          ),
                          SizedBox(height: 20),
                          profileLabelText(
                            Util.getTranslated(
                                context, "setting_edit_profile_fullname"),
                            AppFont.bold(
                              16,
                              color: AppColor.appBlue(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 10),
                          profileInfoTextField(myFullnameController, true),
                          dottedLineSeperator(
                            height: 1.5,
                            color: AppColor.appBlue(),
                          ),
                          SizedBox(height: 20),
                          profileLabelTextWithSubLabel(),
                          SizedBox(height: 10),
                          widget.user.country == Constants.COUNTRY_CODE_MALAYSIA
                              ? profileInfoTextField(myCompanyController, true)
                              : profileInfoTextField(myAreaController, true),
                          dottedLineSeperator(
                            height: 1.5,
                            color: AppColor.appBlue(),
                          ),
                          SizedBox(height: 20),
                          agreementMarketingUpdate(context),
                          SizedBox(height: 20),
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

  Widget profileLabelText(String labelName, TextStyle profileLabelTextStyle) {
    return Text(
      labelName,
      style: profileLabelTextStyle,
    );
  }

  Widget profileInfoTextField(
      TextEditingController myController, bool isEdited) {
    return TextField(
      enabled: isEdited,
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

  Widget profileLabelTextWithSubLabel() {
    return RichText(
      text: TextSpan(
        text: widget.user.country == Constants.COUNTRY_CODE_MALAYSIA
            ? Util.getTranslated(context, "setting_edit_profile_company") + " "
            : Util.getTranslated(context, "signup_area_title") + " ",
        style: AppFont.bold(
          16,
          color: AppColor.appBlue(),
          decoration: TextDecoration.none,
        ),
        children: <TextSpan>[
          TextSpan(
            text: Util.getTranslated(
                context, "setting_edit_profile_company_optional"),
            style: AppFont.regular(
              14,
              color: AppColor.appDarkGreyColor(),
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }

  Widget avatarImg(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        showImagePicker(context);
      },
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            child: (_imageFile != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Image.file(
                      _imageFile,
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: (widget.user != null && widget.user.photo.isNotEmpty)
                        ? DisplayImage(
                            widget.user.photo,
                            'profile_placeholder.png',
                            width: 80.0,
                            height: 80.0,
                            boxFit: BoxFit.cover,
                          )
                        // FadeInImage.assetNetwork(
                        //     placeholder: Constants.ASSET_IMAGES +
                        //         'profile_placeholder.png',
                        //     image: widget.user.photo,
                        //     height: 80.0,
                        //     width: 80.0,
                        //     fit: BoxFit.cover,
                        //   )
                        : Image.asset(
                            Constants.ASSET_IMAGES + 'profile_placeholder.png',
                            height: 80.0,
                            width: 80.0,
                            fit: BoxFit.cover,
                          ),
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              Constants.ASSET_IMAGES + "blue_add_icon.png",
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget agreementMarketingUpdate(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Text(
              Util.getTranslated(context,
                  "setting_edit_profile_agreement_receive_marketing_upt"),
              style: AppFont.bold(
                16,
                color: AppColor.appBlue(),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              isReceiveMargetingUpd = !isReceiveMargetingUpd;
            });
          },
          child: isReceiveMargetingUpd
              ? Image.asset(
                  Constants.ASSET_IMAGES + "on.png",
                  height: 30,
                  width: 50,
                  fit: BoxFit.fill,
                )
              : Image.asset(
                  Constants.ASSET_IMAGES + "off.png",
                  height: 30,
                  width: 50,
                  fit: BoxFit.fill,
                ),
        ),
      ],
    );
  }

  Widget saveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: () async {
          if (hasFillInAll) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            await EasyLoading.show(maskType: EasyLoadingMaskType.black);
            updateUserProfile(context);
          }
        },
        color: (hasFillInAll) ? AppColor.appBlue() : AppColor.appAirForceBlue(),
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
}
