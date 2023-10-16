import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/controllers/authentication/auth_widgets.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/login_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/request_otp_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/sign_up_api.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/user_profile_api.dart';
import 'package:behn_meyer_flutter/dio/api/upload_photo_api.dart';
import 'package:behn_meyer_flutter/main.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/page_argument/otp_verify_argument.dart';
import 'package:behn_meyer_flutter/models/user/user.dart' as appUser;
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import 'authentication.dart';

class SignUp extends StatefulWidget {
  final User firebaseUser;
  final File imageUrl;

  SignUp({Key key, this.firebaseUser, this.imageUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  bool _isSocial = false;
  bool haveAvatar = false;
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  final nameField = TextEditingController();
  final companyField = TextEditingController();
  final referralField = TextEditingController();
  bool _enableReceiveUpdates = true;
  bool _agreeTerms = false;

  bool _fireAuthenticationAvailable = false;
  bool _isiOS13Above = false;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  final FirebaseAuth auth = FirebaseAuth.instance;
  // Map<String, dynamic> _fbUserData;
  AccessToken _fbAccessToken;
  bool isApple = false;

  String cachedLanguage = "";

  File _image;

  final picker = ImagePicker();
  final phoneNoField = TextEditingController();
  final areaField = TextEditingController();
  String cachedCountry = "";

  final ScrollController _scrollController = ScrollController();

  void _scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics()
        .setCurrentScreen(screenName: Constants.analytics_sign_up);

    if (widget.firebaseUser != null) {
      if (widget.firebaseUser.email != null &&
          widget.firebaseUser.email.length > 0) {
        _isSocial = true;
        emailField.text = widget.firebaseUser.email;
        if (widget.firebaseUser.displayName != null &&
            widget.firebaseUser.displayName.length > 0) {
          nameField.text = widget.firebaseUser.displayName;
        }
      } else {
        if (widget.firebaseUser.providerData != null &&
            widget.firebaseUser.providerData.length > 0) {
          if (widget.firebaseUser.providerData[0].providerId == "apple.com") {
            isApple = true;
          }
          if (widget.firebaseUser.providerData[0].email != null &&
              widget.firebaseUser.providerData[0].email.length > 0) {
            _isSocial = true;
            emailField.text = widget.firebaseUser.providerData[0].email;
            if (widget.firebaseUser.providerData[0].displayName != null &&
                widget.firebaseUser.providerData[0].displayName.length > 0) {
              nameField.text = widget.firebaseUser.providerData[0].displayName;
            } else if (widget.firebaseUser.displayName != null &&
                widget.firebaseUser.displayName.length > 0) {
              nameField.text = widget.firebaseUser.displayName;
            }
          }
        }
      }
    }

    if (widget.imageUrl != null) {
      haveAvatar = true;
      _image = widget.imageUrl;
    }

    initPlatformState();
    _checkFirebaseAuthentication();

    AppCache.getStringValue(AppCache.LANGUAGE_CODE_PREF).then((value) {
      setState(() {
        cachedLanguage = value;
      });
    });

    AppCache.getCountry().then((value) {
      if (value != null && value.length > 0) {
        setState(() {
          cachedCountry = value;
        });
      }
    });
  }

  Future<appUser.User> completeProfile(BuildContext context, String email,
      String name, int photoId, bool agreeMarketingUpdate,
      {String company, String area, String referralCode}) async {
    UserProfileApi userProfileApi = UserProfileApi(context);
    return userProfileApi.completeProfile(
        email, name, photoId, agreeMarketingUpdate,
        company: company, area: area, referralCode: referralCode);
  }

  Future<int> uploadPhoto(BuildContext context, File file) async {
    UploadPhotoApi uploadPhotoApi = UploadPhotoApi(context);
    return uploadPhotoApi.uploadPhoto(file);
  }

  Future<void> signUp(
      BuildContext context,
      String email,
      String password,
      String name,
      File photo,
      bool agreeMarketingUpdate,
      String language,
      String country,
      {String company,
      String referralCode}) async {
    SignUpApi signUpApi = SignUpApi(context);
    return signUpApi.signUp(
        email, name, photo, password, agreeMarketingUpdate, language, country,
        company: company, referralCode: referralCode);
  }

  Future<Response> requestOtp(BuildContext context, String password,
      String name, String language, String phoneNo, String countryCode) async {
    RequestOtpApi requestOtpApi = RequestOtpApi(context);
    return requestOtpApi.requestOtp(
        name, password, language, phoneNo, countryCode);
  }

  Future<appUser.User> userProfile(BuildContext context) async {
    UserProfileApi userProfileApi = UserProfileApi(context);
    return userProfileApi.getOwnUserProfile();
  }

  Future<appUser.User> socialLogin(
      BuildContext context,
      String firebaseToken,
      String firebaseUserId,
      String socialType,
      String accountId,
      String accountToken,
      String language,
      String country,
      Map<String, dynamic> deviceInfo) async {
    LoginApi loginApi = LoginApi(context);
    return loginApi.onSocialLogin(firebaseUserId, firebaseToken, accountId,
        accountToken, socialType, Platform.isIOS, language, country,
        deviceId: deviceInfo['uuid'],
        deviceModel: deviceInfo['model'],
        deviceOSVersion: deviceInfo['deviceVersion']);
  }

  Future<String> downloadImage(BuildContext context, String imageUrl) {
    UploadPhotoApi uploadPhotoApi = UploadPhotoApi(context);
    return uploadPhotoApi.downloadPhoto(imageUrl);
  }

  Future<void> _checkFirebaseAuthentication() async {
    setState(() {
      _fireAuthenticationAvailable = false;
    });
    final isFirebaseAvailable = await Authentication.initializeFirebase();
    if (isFirebaseAvailable != null) {
      setState(() {
        _fireAuthenticationAvailable = true;
      });
    }
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};
    setState(() {
      _isiOS13Above = false;
    });

    try {
      if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        final isAppleSignInAvailable = await AppleSignInAvailable.check();
        if (isAppleSignInAvailable.isAvailable) {
          setState(() {
            _isiOS13Above = true;
          });
        }
      } else if (Platform.isAndroid) {
        deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'deviceVersion': data.systemVersion,
      'model': data.model,
      'isPhysicalDevice': data.isPhysicalDevice,
      'uuid': data.identifierForVendor
    };
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'deviceVersion': build.version.sdkInt.toString(),
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'uuid': build.androidId, //uuid
    };
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
                color: Colors.white,
                child: SafeArea(
                    child: SingleChildScrollView(
                        child: Column(children: [
                  Row(
                    children: [
                      Container(
                        height: onCheckDeviceHeight(screenHeight),
                        width: screenWidth,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: ConstrainedBox(
                              constraints: constraints.copyWith(
                                minHeight: constraints.maxHeight - 100,
                                maxHeight: double.infinity,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  children: <Widget>[
                                    // Your body widgets here
                                    SizedBox(height: 8),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AuthWidget.backButton(context)
                                        ]),
                                    _isSocial
                                        ? SizedBox(height: 0)
                                        : socialHeaders(),
                                    SizedBox(height: 10),
                                    Row(children: [signUpHeaderLbl()]),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : Row(children: [signUpSubHeaderLbl()]),
                                    SizedBox(height: 10),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : Row(children: [
                                            avatarImg(haveAvatar, context)
                                          ]),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : SizedBox(height: 20),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : Row(
                                            children: [
                                              (cachedCountry ==
                                                      Constants
                                                          .COUNTRY_CODE_MALAYSIA)
                                                  ? _isSocial
                                                      ? AuthWidget.textFieldForm(
                                                          context,
                                                          Util.getTranslated(
                                                              context, "signup_email_title"),
                                                          Util.getTranslated(
                                                              context, "signup_email_placeholder"),
                                                          emailField,
                                                          readOnly: true)
                                                      : AuthWidget.textFieldForm(
                                                          context,
                                                          Util.getTranslated(
                                                              context, "signup_email_title"),
                                                          Util.getTranslated(
                                                              context, "signup_email_placeholder"),
                                                          emailField)
                                                  : _isSocial
                                                      ? AuthWidget.textFieldForm(
                                                          context,
                                                          Util.getTranslated(
                                                              context,
                                                              "signup_email_title"),
                                                          Util.getTranslated(
                                                              context,
                                                              "signup_email_placeholder"),
                                                          emailField,
                                                          readOnly: true)
                                                      : AuthWidget.phoneNoTextFieldForm(
                                                          context,
                                                          Util.getTranslated(
                                                              context,
                                                              "signup_phoneno_title"),
                                                          Util.getTranslated(
                                                              context,
                                                              "signup_phoneno_placeholder"),
                                                          phoneNoField,
                                                        )
                                            ],
                                          ),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : SizedBox(height: 16),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : Row(
                                            children: [
                                              AuthWidget.textFieldForm(
                                                  context,
                                                  Util.getTranslated(context,
                                                      "signup_name_title"),
                                                  Util.getTranslated(context,
                                                      "signup_name_placeholder"),
                                                  nameField)
                                            ],
                                          ),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : SizedBox(height: 16),
                                    _isSocial
                                        ? SizedBox(
                                            height: 0,
                                          )
                                        : Row(
                                            children: [
                                              AuthWidget.passwordFieldForm(
                                                  context,
                                                  Util.getTranslated(context,
                                                      "signup_password_title"),
                                                  Util.getTranslated(context,
                                                      "signup_password_placeholder"),
                                                  passwordField,
                                                  "signup")
                                            ],
                                          ),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : SizedBox(height: 16),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : Row(children: [
                                            (cachedCountry ==
                                                    Constants
                                                        .COUNTRY_CODE_MALAYSIA)
                                                ? companyFieldForm(context)
                                                : areaFieldForm(context),
                                          ]),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : SizedBox(height: 16),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : Row(children: [
                                            (cachedCountry ==
                                                    Constants
                                                        .COUNTRY_CODE_VIETNAM)
                                                ? referralFieldForm(context)
                                                : Container(),
                                          ]),
                                    isApple
                                        ? SizedBox(height: 0)
                                        : (cachedCountry ==
                                                Constants.COUNTRY_CODE_VIETNAM)
                                            ? SizedBox(height: 16)
                                            : SizedBox(height: 0),
                                    isApple
                                        ? (cachedCountry ==
                                                Constants.COUNTRY_CODE_VIETNAM)
                                            ? referralFieldForm(context)
                                            : Container()
                                        : SizedBox(height: 0),

                                    isApple
                                        ? SizedBox(height: 16)
                                        : SizedBox(height: 0),
                                    agreementMarketingUpdate(context),
                                    SizedBox(
                                      height: 65,
                                      child: const MySeparator(
                                          color:
                                              Color.fromRGBO(18, 51, 119, 1.0)),
                                    ),
                                    SizedBox(height: 0),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: 30, // 20%
                                            child: customRadio(_agreeTerms)),
                                        SizedBox(
                                          width: 15, // 60%
                                          child: SizedBox(width: 15),
                                        ),
                                        Expanded(
                                          // flex: 8, // 20%
                                          child: termsLbl(),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [signupBtn(context)],
                  )
                ]))))));
  }

  Widget socialHeaders() {
    return SizedBox(
      child: Container(
          child: Column(
        children: [
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Util.getTranslated(context, "signup_header"),
                style: AppFont.bold(20,
                    color: AppColor.appBlue(), decoration: TextDecoration.none),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _fireAuthenticationAvailable
              ? socialButtons(context)
              : SizedBox(height: 0),
          // SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget socialButtons(BuildContext context) {
    return SizedBox(
        height: 240,
        child: Container(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [googleButton(context)],
          ),
          // googleButton(context),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [fbButton(context)],
          ),
          // fbButton(context),
          SizedBox(
            height: 20,
          ),
          defaultTargetPlatform == TargetPlatform.iOS
              ? _isiOS13Above
                  ? appleButton(context)
                  : SizedBox(height: 0)
              : SizedBox(height: 0),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Util.getTranslated(context, "login_header_or"),
                style: AppFont.bold(20,
                    color: Colors.black, decoration: TextDecoration.none),
              )
            ],
          ),
        ])));
  }

  Widget googleButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // return GestureDetector(
    //   onTap: () async {
    //     onGoogle(context);
    //   },
    //   child: Container(
    //     width: screenWidth,
    //     height: 50,
    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     decoration: BoxDecoration(
    //       color: AppColor.googleRed(),
    //       borderRadius: BorderRadius.all(
    //         Radius.circular(25.0),
    //       ),
    //     ),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         FaIcon(
    //           FontAwesomeIcons.google,
    //           size: 24,
    //           color: Colors.white,
    //         ),
    //         SizedBox(width: 20),
    //         Text(
    //           Util.getTranslated(context, "login_google"),
    //           style: AppFont.bold(16, color: Colors.white),
    //           overflow: TextOverflow.visible,
    //         )
    //       ],
    //     ),
    //   ),
    // );
    return SizedBox(
      width: screenWidth - 60,
      height: 50,
      child: TextButton(
        onPressed: () async {
          onGoogle(context);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: ((screenWidth - 60) / 2) - 115,
            ),
            FaIcon(
              FontAwesomeIcons.google,
              size: 24,
            ),
            SizedBox(width: 20),
            Text(Util.getTranslated(context, "login_google"))
          ],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.googleRed(),
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget fbButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // return GestureDetector(
    //   onTap: () async {
    //     onFb(context);
    //   },
    //   child: Container(
    //     width: screenWidth,
    //     height: 50,
    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     decoration: BoxDecoration(
    //       color: AppColor.fbBlue(),
    //       borderRadius: BorderRadius.all(
    //         Radius.circular(25.0),
    //       ),
    //     ),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         FaIcon(
    //           FontAwesomeIcons.facebookF,
    //           size: 24,
    //           color: Colors.white,
    //         ),
    //         SizedBox(width: 20),
    //         Text(
    //           Util.getTranslated(context, "login_facebook"),
    //           style: AppFont.bold(16, color: Colors.white),
    //           overflow: TextOverflow.visible,
    //         )
    //       ],
    //     ),
    //   ),
    // );
    return SizedBox(
      width: screenWidth - 60,
      height: 50,
      child: TextButton(
        onPressed: () async {
          onFb(context);
        },
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: ((screenWidth - 60) / 2) - 115,
            ),
            FaIcon(
              FontAwesomeIcons.facebookF,
              size: 24,
            ),
            SizedBox(width: 25),
            Text(Util.getTranslated(context, "login_facebook"))
          ],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.fbBlue(),
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget appleButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // return GestureDetector(
    //   onTap: () async {
    //     onApple(context);
    //   },
    //   child: Container(
    //     width: screenWidth,
    //     height: 50,
    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     decoration: BoxDecoration(
    //       color: Colors.black,
    //       borderRadius: BorderRadius.all(
    //         Radius.circular(25.0),
    //       ),
    //     ),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         FaIcon(
    //           FontAwesomeIcons.apple,
    //           size: 24,
    //           color: Colors.white,
    //         ),
    //         SizedBox(width: 20),
    //         Text(
    //           Util.getTranslated(context, "login_apple"),
    //           style: AppFont.bold(16, color: Colors.white),
    //           overflow: TextOverflow.visible,
    //         )
    //       ],
    //     ),
    //   ),
    // );
    return SizedBox(
      width: screenWidth - 60,
      height: 50,
      child: TextButton(
        onPressed: () async {
          onApple(context);
        },
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: ((screenWidth - 60) / 2) - 115,
            ),
            FaIcon(
              FontAwesomeIcons.apple,
              size: 24,
            ),
            SizedBox(width: 25),
            Text(Util.getTranslated(context, "login_apple"))
          ],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Colors.black,
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget signUpHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 60,
        height: 25,
        child: Text(
          _isSocial
              ? (isApple
                  ? Util.getTranslated(context, "sign_up_continue")
                  : Util.getTranslated(context, "signup_header_social_title"))
              : (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA)
                  ? Util.getTranslated(context, "signup_header_title")
                  : Util.getTranslated(context, "signup_header_vietnam_title"),
          style: AppFont.bold(17,
              color: AppColor.appBlue(), decoration: TextDecoration.none),
        ));
  }

  Widget signUpSubHeaderLbl() {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 60,
        height: 25,
        child: Text(
          Util.getTranslated(context, "signup_subheader_title"),
          style: AppFont.regular(15,
              color: Colors.grey, decoration: TextDecoration.none),
        ));
  }

  Widget avatarImg(bool hasAvatar, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Util.printInfo('on Avatar');
        _showPicker(context);
      },
      child: Stack(children: [
        SizedBox(
          width: 80,
          height: 80,
          child: haveAvatar
              ? CircleAvatar(
                  radius: 40,
                  backgroundImage: _image == null
                      ? AssetImage(Constants.ASSET_IMAGES + 'userdefault.png')
                      : FileImage(_image),
                  backgroundColor: Colors.white,
                )
              : CircleAvatar(
                  radius: 45,
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.grey),
        ),
        haveAvatar
            ? SizedBox(
                height: 0,
              )
            : SizedBox(
                width: 80,
                height: 80,
                child: Container(
                    width: 30,
                    height: 30,
                    color: Colors.transparent,
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                        radius: 15,
                        child: FaIcon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: 15,
                        ),
                        backgroundColor: AppColor.appBlue())))
      ]),
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
              Util.getTranslated(context, "signup_marketing"),
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
              _enableReceiveUpdates = !_enableReceiveUpdates;
            });
          },
          child: _enableReceiveUpdates
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

  Widget customRadio(bool agreeTnc) {
    return GestureDetector(
      onTap: () {
        print('tap radio');
        setState(() {
          if (_agreeTerms) {
            _agreeTerms = false;
          } else {
            _agreeTerms = true;
          }
          agreeTnc = _agreeTerms;
        });
      },
      child: SizedBox(
          width: 30,
          height: 30,
          child: agreeTnc
              ? CircleAvatar(
                  radius: 15,
                  backgroundImage:
                      AssetImage(Constants.ASSET_IMAGES + 'blue_tick_icon.png'))
              : Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                      color: Colors.white),
                )),
    );
  }

  Widget termsLbl() {
    TextStyle defaultStyle = AppFont.regular(15,
        color: Colors.black, decoration: TextDecoration.none);
    TextStyle linkStyle = AppFont.bold(15,
        color: Colors.blue, decoration: TextDecoration.underline);
    return RichText(
      maxLines: 2,
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          TextSpan(text: Util.getTranslated(context, "signup_agree")),
          TextSpan(
              text: Util.getTranslated(context, "signup_terms"),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Util.printInfo('Terms of Service');
                  Navigator.pushNamed(context, MyRoute.termsAndConditionsRoute);
                }),
        ],
      ),
    );
  }

  Widget signupBtn(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth - 60,
      height: 50,
      child: TextButton(
        onPressed: () {
          onSignUp(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isApple
                ? Text(Util.getTranslated(context, "sign_up_continue"))
                : Text(Util.getTranslated(context, "signup_btn"))
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

  Widget companyFieldForm(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        height: 75,
        width: screenWidth - 35,
        child: Container(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      text: Util.getTranslated(context, "signup_company_title"),
                      style: AppFont.bold(15,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none),
                      children: <TextSpan>[
                    TextSpan(
                        text: Util.getTranslated(
                            context, "signup_company_optional"),
                        style: AppFont.regular(13,
                            color: Colors.grey,
                            decoration: TextDecoration.none))
                  ]))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth - 35,
                height: 50,
                child: TextField(
                  controller: companyField,
                  maxLines: 1,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintStyle: AppFont.regular(15,
                          color: Colors.grey[500],
                          decoration: TextDecoration.none),
                      hintText: Util.getTranslated(
                          context, "signup_company_placeholder")),
                ),
              )
            ],
          ),
          const MySeparator(color: Color.fromRGBO(18, 51, 119, 1.0)),
        ])));
  }

  Widget referralFieldForm(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
        height: 75,
        width: screenWidth - 35,
        child: Container(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      text:
                          Util.getTranslated(context, "signup_referral_title"),
                      style: AppFont.bold(15,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none),
                      children: <TextSpan>[
                    TextSpan(
                        text: Util.getTranslated(
                            context, "signup_company_optional"),
                        style: AppFont.regular(13,
                            color: Colors.grey,
                            decoration: TextDecoration.none))
                  ]))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth - 35,
                height: 50,
                child: TextField(
                  controller: referralField,
                  maxLines: 1,
                  // textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintStyle: AppFont.regular(15,
                          color: Colors.grey[500],
                          decoration: TextDecoration.none),
                      hintText: Util.getTranslated(
                          context, "signup_referral_placeholder")),
                ),
              )
            ],
          ),
          const MySeparator(color: Color.fromRGBO(18, 51, 119, 1.0)),
        ])));
  }

  // Widget referralAreaFieldForm(BuildContext context) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   return SizedBox(
  //       height: 75,
  //       width: screenWidth - 35,
  //       child: Container(
  //           child: Column(children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             RichText(
  //                 text: TextSpan(
  //                     text: Util.getTranslated(context, "signup_area_title"),
  //                     style: AppFont.bold(15,
  //                         color: AppColor.appBlue(),
  //                         decoration: TextDecoration.none),
  //                     children: <TextSpan>[
  //                   TextSpan(
  //                       text: Util.getTranslated(
  //                           context, "signup_company_optional"),
  //                       style: AppFont.regular(13,
  //                           color: Colors.grey,
  //                           decoration: TextDecoration.none))
  //                 ]))
  //           ],
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Container(
  //               width: screenWidth - 35,
  //               height: 50,
  //               child: TextField(
  //                 controller: areaField,
  //                 maxLines: 1,
  //                 decoration: InputDecoration(
  //                     border: InputBorder.none,
  //                     focusedBorder: InputBorder.none,
  //                     enabledBorder: InputBorder.none,
  //                     errorBorder: InputBorder.none,
  //                     disabledBorder: InputBorder.none,
  //                     hintStyle: AppFont.regular(15,
  //                         color: Colors.grey[500],
  //                         decoration: TextDecoration.none),
  //                     hintText: Util.getTranslated(
  //                         context, "signup_area_placeholder")),
  //               ),
  //             )
  //           ],
  //         ),
  //         const MySeparator(color: Color.fromRGBO(18, 51, 119, 1.0)),
  //       ])));
  // }

  Widget areaFieldForm(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        height: 75,
        width: screenWidth - 35,
        child: Container(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      text: Util.getTranslated(context, "signup_area_title"),
                      style: AppFont.bold(15,
                          color: AppColor.appBlue(),
                          decoration: TextDecoration.none),
                      children: <TextSpan>[
                    TextSpan(
                        text: Util.getTranslated(
                            context, "signup_company_optional"),
                        style: AppFont.regular(13,
                            color: Colors.grey,
                            decoration: TextDecoration.none))
                  ]))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth - 35,
                height: 50,
                child: TextField(
                  controller: areaField,
                  maxLines: 1,
                  // textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintStyle: AppFont.regular(15,
                          color: Colors.grey[500],
                          decoration: TextDecoration.none),
                      hintText: Util.getTranslated(
                          context, "signup_area_placeholder")),
                ),
              )
            ],
          ),
          const MySeparator(color: Color.fromRGBO(18, 51, 119, 1.0)),
        ])));
  }

  double onCheckDeviceHeight(double screenHeight) {
    if (screenHeight > 736) {
      return screenHeight - 140;
    } else {
      return screenHeight - 100;
    }
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/image.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  void onSignUp(BuildContext context) async {
    Util.printInfo('on SignUp');
    if (_isSocial) {
      if (isApple) {
        _image = await getImageFileFromAssets('images/userdefault.png');

        if (nameField.text.length == 0) {
          nameField.text = "Anonymous";
        }

        if (!_agreeTerms)
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "signup_tnc_empty"));
      } else {
        if (emailField.text.isEmpty)
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "signup_email_empty"));

        if (nameField.text.isEmpty)
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "signup_name_empty"));

        if (_image == null)
          _image = await getImageFileFromAssets('images/userdefault.png');

        if (!_agreeTerms)
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "signup_tnc_empty"));

        bool emailValid = RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(emailField.text);
        if (!emailValid) {
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(
                  context, "authentication_invalid_email_format"));
        }
      }

      await EasyLoading.show(maskType: EasyLoadingMaskType.black);
      var imageId = await uploadPhoto(context, _image);

      if (imageId != null) {
        print('REF CODE');
        print(referralField.text.trim());

        completeProfile(context, emailField.text.trim(), nameField.text.trim(),
                imageId, _enableReceiveUpdates,
                company: companyField.text.isNotEmpty
                    ? companyField.text.trim()
                    : null,
                area: areaField.text.isNotEmpty ? areaField.text.trim() : null,
                referralCode: referralField.text.isNotEmpty
                    ? referralField.text.trim()
                    : null)
            .then((value) {
          EasyLoading.dismiss();
          AppCache.me = value;
          Navigator.pushNamedAndRemoveUntil(context, MyRoute.signUpSuccessRoute,
              (Route<dynamic> route) => false);
        }, onError: (error) {
          EasyLoading.dismiss();
          if (error is DioError) {
            if (error.response != null) {
              if (error.response.data != null) {
                ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
                if (errorDTO.message == 'Invalid referral code' ||
                    errorDTO.message ==
                        'Object not found for value entered in referral') {
                  Util.showAlertDialog(
                      context,
                      Util.getTranslated(
                          context, 'alert_dialog_title_error_text'),
                      Util.getTranslated(context, 'invalid_referral_code'));
                } else {
                  Util.showAlertDialog(
                      context,
                      Util.getTranslated(
                          context, 'alert_dialog_title_error_text'),
                      errorDTO.message);
                }
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, 'alert_dialog_title_error_text'),
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
          Util.printInfo("COMPLETE PROFILE ERROR: $error");
        });
      } else {
        Util.showAlertDialog(
            context,
            Util.getTranslated(context, 'alert_dialog_title_error_text'),
            Util.getTranslated(
                context, 'general_alert_message_error_response_2'));
      }
    } else {
      if (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA) {
        if (emailField.text.isEmpty)
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "signup_email_empty"));

        bool emailValid = RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(emailField.text);

        if (!emailValid) {
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(
                  context, "authentication_invalid_email_format"));
        }
      } else {
        if (phoneNoField.text.isEmpty)
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "phoneno_empty"));
      }

      if (nameField.text.isEmpty)
        return Util.showAlertDialog(
            context,
            Util.getTranslated(context, "alert_dialog_title_info_text"),
            Util.getTranslated(context, "signup_name_empty"));

      if (_image == null)
        _image = await getImageFileFromAssets('images/userdefault.png');

      if (passwordField.text.isEmpty)
        return Util.showAlertDialog(
            context,
            Util.getTranslated(context, "alert_dialog_title_info_text"),
            Util.getTranslated(context, "signup_password_empty"));

      if (!_agreeTerms)
        return Util.showAlertDialog(
            context,
            Util.getTranslated(context, "alert_dialog_title_info_text"),
            Util.getTranslated(context, "signup_tnc_empty"));

      String language;
      if (cachedLanguage.length > 0) {
        language = cachedLanguage;
      } else {
        if (cachedCountry != null && cachedCountry.length > 0) {
          if (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA) {
            language = "EN";
          } else {
            language = "VT";
          }
        } else {
          language = "EN";
        }
      }
      String country;
      if (cachedCountry != null && cachedCountry.length > 0) {
        country = cachedCountry;
      } else {
        country = Constants.COUNTRY_CODE_MALAYSIA;
      }

      await EasyLoading.show(maskType: EasyLoadingMaskType.black);
      if (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA) {
        print('REF CODE');

        print(referralField.text.trim());
        signUp(
                context,
                emailField.text.trim(),
                passwordField.text.trim(),
                nameField.text.trim(),
                _image,
                _enableReceiveUpdates,
                language,
                country,
                company: companyField.text.isNotEmpty
                    ? companyField.text.trim()
                    : null,
                referralCode: referralField.text.isNotEmpty
                    ? referralField.text.trim()
                    : null)
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
                if (errorDTO.message == 'Invalid referral code' ||
                    errorDTO.message ==
                        'Object not found for value entered in referral') {
                  Util.showAlertDialog(
                      context,
                      Util.getTranslated(
                          context, 'alert_dialog_title_error_text'),
                      Util.getTranslated(context, 'invalid_referral_code'));
                } else {
                  Util.showAlertDialog(
                      context,
                      Util.getTranslated(
                          context, 'alert_dialog_title_error_text'),
                      errorDTO.message);
                }
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, 'alert_dialog_title_error_text'),
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
          Util.printInfo("SIGN UP ERROR: $error");
        });
      } else {
        String viePhone = "";
        if (phoneNoField.text.trim().startsWith('0')) {
          viePhone = Constants.PHONE_CODE_VIETNAM + phoneNoField.text.trim();
        } else {
          viePhone =
              Constants.PHONE_CODE_VIETNAM + "0" + phoneNoField.text.trim();
        }
        requestOtp(context, passwordField.text.trim(), nameField.text.trim(),
                language, viePhone, country)
            .then((value) {
          EasyLoading.dismiss();
          Navigator.pushNamed(context, MyRoute.otpVerificationRoute,
              arguments: OtpVerifyArguments(
                  viePhone,
                  nameField.text.trim(),
                  passwordField.text.trim(),
                  areaField.text,
                  referralField.text.trim(),
                  _enableReceiveUpdates,
                  _image,
                  true));
        }, onError: (error) {
          EasyLoading.dismiss();
          if (error is DioError) {
            if (error.response != null) {
              if (error.response.data != null) {
                ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, 'alert_dialog_title_error_text'),
                    errorDTO.message);
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, 'alert_dialog_title_error_text'),
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
  }

  _imgFromCamera() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          haveAvatar = true;
        } else {
          print('No image selected.');
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

  _imgFromGallery() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          haveAvatar = true;
        } else {
          print('No image selected.');
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

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(Util.getTranslated(
                          context, 'choose_from_gallery_text')),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(
                        Util.getTranslated(context, 'choose_from_camera_text')),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void onFb(BuildContext context) async {
    Util.printInfo('on FB');
    await _fbLogin(context);
  }

  Future<void> _fbLogin(BuildContext context) async {
    final LoginResult result = await FacebookAuth.instance
        .login(); // by the fault we request the email and the public profile

    // loginBehavior is only supported for Android devices, for ios it will be ignored
    // final result = await FacebookAuth.instance.login(
    //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
    //   loginBehavior: LoginBehavior
    //       .DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
    // );

    if (result.status == LoginStatus.success) {
      _fbAccessToken = result.accessToken;
      // final userData = await FacebookAuth.instance.getUserData();
      // _fbUserData = userData;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken.token);
      // _printCredentials();
      await EasyLoading.show(maskType: EasyLoadingMaskType.black);
      UserCredential authResult = await auth.signInWithCredential(credential);
      User user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      User currentUser = auth.currentUser;
      assert(user.uid == currentUser.uid);
      var firebaseToken = await user.getIdToken();
      String language;
      if (cachedLanguage.length > 0) {
        language = cachedLanguage;
      } else {
        if (cachedCountry != null && cachedCountry.length > 0) {
          if (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA) {
            language = "EN";
          } else {
            language = "VT";
          }
        } else {
          language = "EN";
        }
      }
      String country;
      if (cachedCountry != null && cachedCountry.length > 0) {
        country = cachedCountry;
      } else {
        country = Constants.COUNTRY_CODE_MALAYSIA;
      }

      socialLogin(
              context,
              firebaseToken.toString(),
              user.uid,
              LoginType.Facebook.name,
              _fbAccessToken.userId,
              _fbAccessToken.token,
              language,
              country,
              _deviceData)
          .then((value) async {
        EasyLoading.dismiss();
        Util.printInfo("SOCIAL LOGIN SUCCESS: $value");
        Util.printInfo("FACEBOOK USER: $user");
        if (value.status == appUser.UserStatus.Active.name) {
          AppCache.me = value;
          MyApp.setLocale(context, Util.mylocale(value.language));
          Navigator.pushNamedAndRemoveUntil(
              context, MyRoute.homebaseRoute, (Route<dynamic> route) => false);
        } else if (value.status == appUser.UserStatus.Incomplete.name) {
          if (user.photoURL != null && user.photoURL.length > 0) {
            var imageUrl = await downloadImage(
                context,
                user.photoURL +
                    "?type=large&access_token=${_fbAccessToken.token}");
            Util.printInfo('IMAGE URL FB: $imageUrl');
            Navigator.popAndPushNamed(context, MyRoute.signUpRoute,
                arguments: [user, File(imageUrl)]);
          } else {
            Navigator.popAndPushNamed(context, MyRoute.signUpRoute,
                arguments: [user]);
          }
        }
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
        Util.printInfo("SOCIAL LOGIN ERROR: $error");
      });
    } else {
      EasyLoading.dismiss();
      Util.printInfo(
          "FACEBOOK LOGIN ERROR: ${result.status} MESSAGE: ${result.message}");
    }
  }

  void onGoogle(BuildContext context) async {
    Util.printInfo('on Google');
    await _googleLogin(context);
  }

  Future<void> _googleLogin(BuildContext context) async {
    User user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        User currentUser = auth.currentUser;
        assert(user.uid == currentUser.uid);
        var firebaseToken = await user.getIdToken();
        Util.printInfo('FIREBASE TOKEN: $firebaseToken');
        Util.printInfo('FIREBASE USER ID: ${user.uid}');
        Util.printInfo('GOOGLE IDTOKEN: ${googleSignInAuthentication.idToken}');
        Util.printInfo(
            'GOOGLE ACCESSTOKEN: ${googleSignInAuthentication.accessToken}');
        await EasyLoading.show(maskType: EasyLoadingMaskType.black);
        String language;
        if (cachedLanguage.length > 0) {
          language = cachedLanguage;
        } else {
          if (cachedCountry != null && cachedCountry.length > 0) {
            if (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA) {
              language = "EN";
            } else {
              language = "VT";
            }
          } else {
            language = "EN";
          }
        }
        String country;
        if (cachedCountry != null && cachedCountry.length > 0) {
          country = cachedCountry;
        } else {
          country = Constants.COUNTRY_CODE_MALAYSIA;
        }

        socialLogin(
                context,
                firebaseToken.toString(),
                user.uid,
                LoginType.Google.name,
                googleSignInAuthentication.idToken,
                googleSignInAuthentication.accessToken,
                language,
                country,
                _deviceData)
            .then((value) async {
          EasyLoading.dismiss();
          Util.printInfo("GOOGLE USER: $user");
          Util.printInfo("SOCIAL LOGIN SUCCESS: $value");
          if (value.status == appUser.UserStatus.Active.name) {
            AppCache.me = value;
            MyApp.setLocale(context, Util.mylocale(value.language));
            Navigator.pushNamedAndRemoveUntil(context, MyRoute.homebaseRoute,
                (Route<dynamic> route) => false);
          } else if (value.status == appUser.UserStatus.Incomplete.name) {
            if (user.photoURL != null && user.photoURL.length > 0) {
              var imageUrl = await downloadImage(context, user.photoURL);
              Util.printInfo('IMAGE URL GOOGLE: $imageUrl');
              Navigator.popAndPushNamed(context, MyRoute.signUpRoute,
                  arguments: [user, File(imageUrl)]);
            } else {
              Navigator.popAndPushNamed(context, MyRoute.signUpRoute,
                  arguments: [user]);
            }
          }
        }, onError: (error) {
          EasyLoading.dismiss();
          if (error is DioError) {
            if (error.response != null) {
              if (error.response.data != null) {
                ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, 'alert_dialog_title_error_text'),
                    errorDTO.message);
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, 'alert_dialog_title_error_text'),
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
          Util.printInfo("SOCIAL LOGIN ERROR: $error");
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content:
                  'The account already exists with a different credential.',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }
    }
  }

  void onApple(BuildContext context) async {
    Util.printInfo('on Apple');
    await _appleLogin(context);
  }

  Future<void> _appleLogin(BuildContext context) async {
    try {
      final AuthorizationResult appleResult =
          await TheAppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (appleResult.status) {
        case AuthorizationStatus.authorized:
          final AuthCredential credential =
              OAuthProvider('apple.com').credential(
            accessToken:
                String.fromCharCodes(appleResult.credential.authorizationCode),
            idToken: String.fromCharCodes(appleResult.credential.identityToken),
          );

          await EasyLoading.show(maskType: EasyLoadingMaskType.black);
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          User user = userCredential.user;
          assert(!user.isAnonymous);
          assert(await user.getIdToken() != null);
          User currentUser = auth.currentUser;
          assert(user.uid == currentUser.uid);
          var firebaseToken = await user.getIdToken();

          String language;
          if (cachedLanguage.length > 0) {
            language = cachedLanguage;
          } else {
            if (cachedCountry != null && cachedCountry.length > 0) {
              if (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA) {
                language = "EN";
              } else {
                language = "VT";
              }
            } else {
              language = "EN";
            }
          }
          String country;
          if (cachedCountry != null && cachedCountry.length > 0) {
            country = cachedCountry;
          } else {
            country = Constants.COUNTRY_CODE_MALAYSIA;
          }

          if (appleResult.credential.fullName.givenName != null &&
              appleResult.credential.fullName.familyName != null) {
            setState(() {
              user.updateProfile(
                  displayName: appleResult.credential.fullName.givenName +
                      " " +
                      appleResult.credential.fullName.familyName);
            });
          } else {
            if (appleResult.credential.fullName.givenName != null) {
              setState(() {
                user.updateProfile(
                    displayName: appleResult.credential.fullName.givenName);
              });
            } else if (appleResult.credential.fullName.familyName != null) {
              setState(() {
                user.updateProfile(
                    displayName: appleResult.credential.fullName.familyName);
              });
            }
          }

          Util.printInfo("APPLE USER BEFORE: $user");

          socialLogin(
                  context,
                  firebaseToken.toString(),
                  user.uid,
                  LoginType.Apple.name,
                  String.fromCharCodes(appleResult.credential.identityToken),
                  String.fromCharCodes(
                      appleResult.credential.authorizationCode),
                  language,
                  country,
                  _deviceData)
              .then((value) async {
            EasyLoading.dismiss();
            Util.printInfo("APPLE USER: $user");
            Util.printInfo("SOCIAL LOGIN SUCCESS: ${value.email}");
            if (value.status == appUser.UserStatus.Active.name) {
              AppCache.me = value;
              MyApp.setLocale(context, Util.mylocale(value.language));
              Navigator.pushNamedAndRemoveUntil(context, MyRoute.homebaseRoute,
                  (Route<dynamic> route) => false);
            } else if (value.status == appUser.UserStatus.Incomplete.name) {
              if (user.photoURL != null && user.photoURL.length > 0) {
                var imageUrl = await downloadImage(context, user.photoURL);
                Navigator.popAndPushNamed(context, MyRoute.signUpRoute,
                    arguments: [user, File(imageUrl)]);
              } else {
                Navigator.popAndPushNamed(context, MyRoute.signUpRoute,
                    arguments: [user]);
              }
            }
          }, onError: (error) {
            EasyLoading.dismiss();
            if (error is DioError) {
              if (error.response != null) {
                if (error.response.data != null) {
                  ErrorDTO errorDTO = ErrorDTO.fromJson(error.response.data);
                  Util.showAlertDialog(
                      context,
                      Util.getTranslated(
                          context, 'alert_dialog_title_error_text'),
                      errorDTO.message);
                } else {
                  Util.showAlertDialog(
                      context,
                      Util.getTranslated(
                          context, 'alert_dialog_title_error_text'),
                      Util.getTranslated(
                          context, 'general_alert_message_error_response'));
                }
              } else {
                Util.showAlertDialog(
                    context,
                    Util.getTranslated(
                        context, 'alert_dialog_title_error_text'),
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
            Util.printInfo("SOCIAL LOGIN ERROR: $error");
          });
          break;
        case AuthorizationStatus.error:
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: appleResult.error.toString(),
          );

        case AuthorizationStatus.cancelled:
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Apple Sign In is cancelled',
          );
        default:
          throw UnimplementedError();
      }
    } catch (error) {
      Util.printInfo("APPLE SIGN IN Error: $error");
      if (error != null) {
        if (error.message != null) {
          Util.showAlertDialog(context, 'Apple Sign In Error', error.message);
        } else {
          Util.showAlertDialog(
              context,
              'Apple Sign In Error',
              Util.getTranslated(
                  context, 'general_alert_message_error_response_2'));
        }
      } else {
        Util.showAlertDialog(
            context,
            'Apple Sign In Error',
            Util.getTranslated(
                context, 'general_alert_message_error_response_2'));
      }
    }
  }
}
