import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/app_color.dart';
import 'package:behn_meyer_flutter/const/app_font.dart';
import 'package:behn_meyer_flutter/const/constants.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/api/authentication/login_api.dart';
import 'package:behn_meyer_flutter/dio/api/upload_photo_api.dart';
import 'package:behn_meyer_flutter/models/error/error.dart';
import 'package:behn_meyer_flutter/models/user/user.dart' as appUser;
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:behn_meyer_flutter/routes/my_route.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io' show File, Platform;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../main.dart';
import 'auth_widgets.dart';
import 'authentication.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  final firebaseAuth.FirebaseAuth auth = firebaseAuth.FirebaseAuth.instance;
  // Map<String, dynamic> _fbUserData;
  AccessToken _fbAccessToken;
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  final phoneNoField = TextEditingController();
  bool _fireAuthenticationAvailable = false;
  bool _isiOS13Above = false;
  String cachedLanguage = "";
  String cachedCountry = "";

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: Constants.analytics_login);

    initPlatformState();
    _checkFirebaseAuthentication();
    AppCache.getStringValue(AppCache.LANGUAGE_CODE_PREF).then((value) {
      setState(() {
        cachedLanguage = value;
      });
    });
    AppCache.getCountry().then((value) {
      setState(() {
        cachedCountry = value;
      });
    });
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

  Future<appUser.User> login(
      BuildContext context,
      String email,
      String password,
      String language,
      String country,
      Map<String, dynamic> deviceInfo) async {
    LoginApi loginApi = LoginApi(context);
    return loginApi.onEmailLogin(
        email, password, Platform.isIOS, language, country,
        deviceId: deviceInfo['uuid'],
        deviceModel: deviceInfo['model'],
        deviceOSVersion: deviceInfo['deviceVersion']);
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

  Future<appUser.User> mobilelogin(
      BuildContext context,
      String phoneNo,
      String password,
      String language,
      String country,
      Map<String, dynamic> deviceInfo) async {
    LoginApi loginApi = LoginApi(context);
    return loginApi.onMobileLogin(
        phoneNo, password, Platform.isIOS, language, country,
        deviceId: deviceInfo['uuid'],
        deviceModel: deviceInfo['model'],
        deviceOSVersion: deviceInfo['deviceVersion']);
  }

  Future<String> downloadImage(BuildContext context, String imageUrl) {
    UploadPhotoApi uploadPhotoApi = UploadPhotoApi(context);
    return uploadPhotoApi.downloadPhoto(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      children: [
                        headerButton(),
                      ],
                    ),
                  ),
                ))));
  }

  Widget headerButton() {
    return SizedBox(
      // height: 650,
      child: Container(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [backButton(context)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Util.getTranslated(context, "login_header_title"),
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
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cachedCountry == Constants.COUNTRY_CODE_VIETNAM
                  ? mobileLogin(context)
                  : manualLogin(context)
            ],
          ),
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
          // fbButton(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [fbButton(context)],
          ),
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

  Widget manualLogin(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        height: 300,
        width: screenWidth - 35,
        child: Container(
            child: Column(children: [
          Row(
            children: [
              AuthWidget.textFieldForm(
                  context,
                  Util.getTranslated(context, "login_email_title"),
                  Util.getTranslated(context, "login_email_placeholder"),
                  emailField)
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              AuthWidget.passwordFieldForm(
                  context,
                  Util.getTranslated(context, "login_password_title"),
                  Util.getTranslated(context, "login_password_placeholder"),
                  passwordField,
                  "login")
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Util.printInfo('tap forget');
                  Navigator.pushNamed(context, MyRoute.forgetPasswordRoute);
                },
                child: SizedBox(
                    height: 20,
                    child: Text(
                      Util.getTranslated(context, "login_forget_password"),
                      style: AppFont.regular(15,
                          color: Colors.black,
                          decoration: TextDecoration.underline),
                    )),
              )
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [signInButton(context)],
          ),
        ])));
  }

  Widget mobileLogin(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        height: 300,
        width: screenWidth - 35,
        child: Container(
            child: Column(children: [
          Row(
            children: [
              AuthWidget.phoneNoTextFieldForm(
                  context,
                  Util.getTranslated(context, "phoneno_title"),
                  Util.getTranslated(context, "phoneno_placeholder"),
                  phoneNoField)
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              AuthWidget.passwordFieldForm(
                  context,
                  Util.getTranslated(context, "login_password_title"),
                  Util.getTranslated(context, "login_password_placeholder"),
                  passwordField,
                  "login")
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Util.printInfo('tap forget');
                  Navigator.pushNamed(
                      context, MyRoute.forgetPasswordMobileRoute);
                },
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(),
                    ),
                  ),
                  child: Text(
                    Util.getTranslated(context, "login_forget_password"),
                    style: AppFont.regular(15,
                        color: Colors.black, decoration: TextDecoration.none),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [signInButton(context)],
          ),
        ])));
  }

  Widget backButton(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.black.withOpacity(0.5), // button color
        child: InkWell(
          splashColor: Colors.black.withOpacity(0.5), // inkwell color
          child: SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.close_rounded, size: 20, color: Colors.white)),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget googleButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // return GestureDetector(
    //   onTap: () async {
    //     onGoogle(context);
    //   },
    //   child: Container(
    //     width: screenWidth,
    //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     height: 50,
    //     // color: AppColor.googleRed(),
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

  Widget signInButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth - 60,
      height: 50,
      child: TextButton(
        onPressed: () async {
          if (cachedCountry == Constants.COUNTRY_CODE_VIETNAM) {
            await onMobileLogin(context);
          } else {
            await onLogin(context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(Util.getTranslated(context, "login_btn"))],
        ),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: AppColor.appBlue(),
          textStyle: AppFont.bold(16, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0)),
        ),
      ),
    );
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
      final firebaseAuth.OAuthCredential credential =
          firebaseAuth.FacebookAuthProvider.credential(
              result.accessToken.token);
      // _printCredentials();
      await EasyLoading.show(maskType: EasyLoadingMaskType.black);
      firebaseAuth.UserCredential authResult =
          await auth.signInWithCredential(credential);
      firebaseAuth.User user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      firebaseAuth.User currentUser = auth.currentUser;
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
        if (value.status == UserStatus.Active.name) {
          AppCache.me = value;
          MyApp.setLocale(context, Util.mylocale(value.language));
          Navigator.pushNamedAndRemoveUntil(
              context, MyRoute.homebaseRoute, (Route<dynamic> route) => false);
        } else if (value.status == UserStatus.Incomplete.name) {
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
    firebaseAuth.User user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final firebaseAuth.AuthCredential credential =
          firebaseAuth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final firebaseAuth.UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        firebaseAuth.User currentUser = auth.currentUser;
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
          if (value.status == UserStatus.Active.name) {
            AppCache.me = value;
            MyApp.setLocale(context, Util.mylocale(value.language));
            Navigator.pushNamedAndRemoveUntil(context, MyRoute.homebaseRoute,
                (Route<dynamic> route) => false);
          } else if (value.status == UserStatus.Incomplete.name) {
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
      } on firebaseAuth.FirebaseAuthException catch (e) {
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
          final firebaseAuth.AuthCredential credential =
              firebaseAuth.OAuthProvider('apple.com').credential(
            accessToken:
                String.fromCharCodes(appleResult.credential.authorizationCode),
            idToken: String.fromCharCodes(appleResult.credential.identityToken),
          );
          await EasyLoading.show(maskType: EasyLoadingMaskType.black);
          final firebaseAuth.UserCredential userCredential =
              await auth.signInWithCredential(credential);
          firebaseAuth.User user = userCredential.user;
          assert(!user.isAnonymous);
          assert(await user.getIdToken() != null);
          firebaseAuth.User currentUser = auth.currentUser;
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
            if (value.status == UserStatus.Active.name) {
              AppCache.me = value;
              MyApp.setLocale(context, Util.mylocale(value.language));
              Navigator.pushNamedAndRemoveUntil(context, MyRoute.homebaseRoute,
                  (Route<dynamic> route) => false);
            } else if (value.status == UserStatus.Incomplete.name) {
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
          Util.printInfo("APPLE SIGN IN ERROR");

          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: appleResult.error.toString(),
          );

        case AuthorizationStatus.cancelled:
          Util.printInfo("APPLE SIGN IN CANCELLED");
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Apple Sign In is cancelled',
          );
        default:
          Util.printInfo("APPLE SIGN IN DEFAULT");
          throw PlatformException(
            code: 'ERROR_PLATFORM',
            message: 'We encountered an error, please try again later.',
          );
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

  Future<void> onLogin(BuildContext context) async {
    Util.printInfo('on Login');
    if (cachedCountry == Constants.COUNTRY_CODE_MALAYSIA) {
      if (emailField.text.isEmpty)
        return Util.showAlertDialog(
            context,
            Util.getTranslated(context, "alert_dialog_title_info_text"),
            Util.getTranslated(context, "login_email_empty"));

      if (passwordField.text.isEmpty)
        return Util.showAlertDialog(
            context,
            Util.getTranslated(context, "alert_dialog_title_info_text"),
            Util.getTranslated(context, "login_password_empty"));

      if (emailField.text.length > 0 && passwordField.text.length > 0) {
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

        if (passwordField.text.isEmpty)
          return Util.showAlertDialog(
              context,
              Util.getTranslated(context, "alert_dialog_title_info_text"),
              Util.getTranslated(context, "login_password_empty"));
      }

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
      Util.printInfo('emailField ${emailField.text}');
      Util.printInfo('passwordField ${passwordField.text}');
      login(context, emailField.text.trim(), passwordField.text.trim(),
              language, country, _deviceData)
          .then((appUser.User value) {
        EasyLoading.dismiss();
        Util.printInfo("LOGIN SUCCESS: $value");
        if (value.status == UserStatus.Active.name) {
          AppCache.me = value;
          MyApp.setLocale(context, Util.mylocale(value.language));
          Navigator.pushNamedAndRemoveUntil(
              context, MyRoute.homebaseRoute, (Route<dynamic> route) => false);
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
        Util.printInfo("LOGIN ERROR: $error");
      });
    }
  }

  Future<void> onMobileLogin(BuildContext context) async {
    Util.printInfo('on Login');
    if (phoneNoField.text.isEmpty)
      return Util.showAlertDialog(
          context,
          Util.getTranslated(context, "alert_dialog_title_info_text"),
          Util.getTranslated(context, "phoneno_empty"));

    if (passwordField.text.isEmpty)
      return Util.showAlertDialog(
          context,
          Util.getTranslated(context, "alert_dialog_title_info_text"),
          Util.getTranslated(context, "login_password_empty"));

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
    Util.printInfo('mobileField ${phoneNoField.text}');
    Util.printInfo('passwordField ${passwordField.text}');
    String mPhoneNo = "";
    if (phoneNoField.text.trim().startsWith('0')) {
      mPhoneNo = Constants.PHONE_CODE_VIETNAM + phoneNoField.text.trim();
    } else {
      mPhoneNo = Constants.PHONE_CODE_VIETNAM + "0" + phoneNoField.text.trim();
    }
    mobilelogin(context, mPhoneNo, passwordField.text.trim(), language, country,
            _deviceData)
        .then((appUser.User value) {
      EasyLoading.dismiss();
      Util.printInfo("LOGIN SUCCESS: $value");
      if (value.status == UserStatus.Active.name) {
        AppCache.me = value;
        MyApp.setLocale(context, Util.mylocale(value.language));
        Navigator.pushNamedAndRemoveUntil(
            context, MyRoute.homebaseRoute, (Route<dynamic> route) => false);
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
      Util.printInfo("LOGIN ERROR: $error");
    });
  }
}
