import 'dart:io';

import 'package:behn_meyer_flutter/controllers/authentication/forget_password.dart';
import 'package:behn_meyer_flutter/controllers/authentication/forget_password_confirm.dart';
import 'package:behn_meyer_flutter/controllers/authentication/forgot_password_mobile.dart';
import 'package:behn_meyer_flutter/controllers/authentication/otp_verification.dart';
import 'package:behn_meyer_flutter/controllers/authentication/reset_password.dart';
import 'package:behn_meyer_flutter/controllers/authentication/reset_password_success.dart';
import 'package:behn_meyer_flutter/controllers/authentication/signup.dart';
import 'package:behn_meyer_flutter/controllers/authentication/signup_success.dart';
import 'package:behn_meyer_flutter/controllers/authentication/signup_tnc.dart';
import 'package:behn_meyer_flutter/controllers/dealer/dealer.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_programme_crop_type_list.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_issue_detail.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_issue_list.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_category_list.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_category_question_selection.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_programme_web_browser.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_questions_list.dart';
import 'package:behn_meyer_flutter/controllers/home/crop_questions_result.dart';
import 'package:behn_meyer_flutter/controllers/home/home.dart';
import 'package:behn_meyer_flutter/controllers/home/search.dart';
import 'package:behn_meyer_flutter/controllers/home/video_list.dart';
import 'package:behn_meyer_flutter/controllers/news/news.dart';
import 'package:behn_meyer_flutter/controllers/news/news_article.dart';
import 'package:behn_meyer_flutter/controllers/photo_view_multiple.dart';
import 'package:behn_meyer_flutter/controllers/photo_view_single.dart';
import 'package:behn_meyer_flutter/controllers/product/product.dart';
import 'package:behn_meyer_flutter/controllers/product/product_useful_info.dart';
import 'package:behn_meyer_flutter/controllers/product/product_useful_info_details.dart';
import 'package:behn_meyer_flutter/controllers/qna/create_qna.dart';
import 'package:behn_meyer_flutter/controllers/qna/qna.dart';
import 'package:behn_meyer_flutter/controllers/qna/qna_detail.dart';
import 'package:behn_meyer_flutter/controllers/settings/about_us.dart';
import 'package:behn_meyer_flutter/controllers/settings/account_setting.dart';
import 'package:behn_meyer_flutter/controllers/settings/change_country.dart';
import 'package:behn_meyer_flutter/controllers/settings/change_language.dart';
import 'package:behn_meyer_flutter/controllers/settings/change_password.dart';
import 'package:behn_meyer_flutter/controllers/settings/delete_account_details.dart';
import 'package:behn_meyer_flutter/controllers/settings/edit_profile.dart';
import 'package:behn_meyer_flutter/controllers/settings/privacy_policy.dart';
import 'package:behn_meyer_flutter/controllers/settings/qrcode_scanner.dart';
import 'package:behn_meyer_flutter/controllers/settings/referral_code.dart';
import 'package:behn_meyer_flutter/controllers/settings/settings.dart';
import 'package:behn_meyer_flutter/controllers/product/product_details.dart';
import 'package:behn_meyer_flutter/controllers/settings/terms_and_conditions.dart';
import 'package:behn_meyer_flutter/controllers/web_browser.dart';
import 'package:behn_meyer_flutter/models/news/article.dart';
import 'package:behn_meyer_flutter/models/page_argument/crop_question_result_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/detect_country_arguments.dart';
import 'package:behn_meyer_flutter/models/page_argument/otp_verify_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/page_arguments.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_multiple_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/photo_view_single_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/product_dealer_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/qna_arguments.dart';
import 'package:behn_meyer_flutter/models/page_argument/qrcode_scanner_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/reset_password_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/user_profile_argument.dart';
import 'package:behn_meyer_flutter/models/page_argument/web_browser_argument.dart';
import 'package:behn_meyer_flutter/models/product/product_article.dart';
import 'package:behn_meyer_flutter/models/user/user.dart' as appUser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import '../controllers/tab/homebase.dart';
import '../controllers/landing.dart';
import '../controllers/authentication/login.dart';
import '../controllers/splash_screen.dart';

class MyRoute {
  static const String splashScreenRoute = "splash_screen";
  static const String landingRoute = "landing";
  static const String homebaseRoute = "homebase";
  static const String homeRoute = "home";
  static const String productRoute = "product";
  static const String dealerRoute = "dealer";
  static const String settingsRoute = "settings";
  static const String newsRoute = "news";
  static const String qnaRoute = "qna";

  //Auth
  static const String signInRoute = "signin";
  static const String signUpRoute = "signup";
  static const String signUpTncRoute = "signup_tnc";
  static const String signUpSuccessRoute = "signup_success";
  static const String forgetPasswordRoute = "forget_password";
  static const String forgetPasswordConfirmRoute = "forget_password_confirm";
  static const String otpVerificationRoute = "otp_verify";
  static const String forgetPasswordMobileRoute = "forget_password_mobile";
  static const String resetPasswordMobileRoute = "reset_password_mobile";
  static const String resetPasswordSuccessRoute = "reset_password_success";

  //Home
  static const String homeSearchRoute = "home_search";
  static const String cropListRoute = "crop_list";
  static const String cropListSelectionRoute = "crop_list_selection";
  static const String cropIssueListRoute = "crop_issue_list";
  static const String cropIssueDetailRoute = "crop_issue_detail";
  static const String cropQuestionListRoute = "crop_question_list";
  static const String cropQuestionResultRoute = "crop_question_result";
  static const String videoListRoute = "video_list";
  static const String cropProgrammeCropTypeListRoute =
      "crop_programme_crop_type_list";

  //Product
  static const String productDetailsRoute = "product_details";
  static const String productDealerRoute = "product_dealer";
  static const String productUsefulInfoRoute = "product_useful_info";
  static const String productUsefulInfoDetailsRoute =
      "product_useful_info_details";

  //News
  static const String newsArticleRoute = "news_article";

  //Q&A
  static const String qnaSubmitRoute = "qna_submit";
  static const String qnaDetailRoute = "qna_detail";

  //Setting
  static const String changeLanguageRoute = "change_language";
  static const String aboutUsRoute = "about_us";
  static const String changePasswordRoute = "change_password";
  static const String editProfileRoute = "edit_profile";
  static const String termsAndConditionsRoute = "terms_and_conditions";
  static const String privacyPolicyRoute = "privacy_policy";
  static const String changeCountryRoute = "change_country";
  static const String qrcodeScannerRoute = "qrcode_scanner";
  static const String accountSettingRoute = "account_setting";
  static const String accountDeleteDetailsRoute = "account_delete_details";
  static const String referralCodeRoute = "referral_code";

  static const String webBrowserRoute = "web_browser";
  static const String photoViewSingleRoute = "photo_view_single";
  static const String photoViewMultipleRoute = "photo_view_multiple";
  static const String cropProgrammeWebBrowserRoute =
      "crop_programme_web_browser";

  static Route<dynamic> generatedRoute(RouteSettings settings) {
    switch (settings.name) {
      case landingRoute:
        List<dynamic> args = settings.arguments;
        if (args != null && args.length > 0) {
          RemoteConfig config = args[0] as RemoteConfig;
          // DetectCountryArgument arguments = args[1] as DetectCountryArgument;
          return MaterialPageRoute(
              builder: (_) => Landing(
                    config: config,
                    // detectedCountry: arguments.detectedCountry,
                  ));
        }
        return MaterialPageRoute(builder: (_) => Landing());
      case signInRoute:
        return MaterialPageRoute(
            builder: (_) => Login(), fullscreenDialog: true);
      case signUpRoute:
        List<dynamic> args = settings.arguments;
        if (args != null && args.length > 1) {
          User firebaseUser = args[0] as User;
          File imageFile = args[1] as File;
          return MaterialPageRoute(
              builder: (_) => SignUp(
                    firebaseUser: firebaseUser,
                    imageUrl: imageFile,
                  ));
        } else {
          if (args != null && args.length > 0) {
            User firebaseUser = args[0] as User;
            return MaterialPageRoute(
                builder: (_) => SignUp(firebaseUser: firebaseUser));
          }
          return MaterialPageRoute(builder: (_) => SignUp());
        }
        break;
      case signUpTncRoute:
        return MaterialPageRoute(
            builder: (_) => SignUpTnc(), fullscreenDialog: true);
      case signUpSuccessRoute:
        List<dynamic> args = settings.arguments;
        if (args != null && args.length > 0) {
          bool isFromSignUp = args[0] as bool;
          return MaterialPageRoute(
              builder: (_) => SignUpSuccess(
                    isFromSignUp: isFromSignUp,
                  ));
        } else {
          return MaterialPageRoute(builder: (_) => SignUpSuccess());
        }
        break;
      case forgetPasswordRoute:
        return MaterialPageRoute(builder: (_) => ForgetPassword());
      case forgetPasswordConfirmRoute:
        return MaterialPageRoute(builder: (_) => ForgetPasswordConfirm());
      case homebaseRoute:
        List<dynamic> args = settings.arguments;
        if (args != null && args.length > 0) {
          RemoteConfig config = args[0] as RemoteConfig;
          return MaterialPageRoute(
              builder: (_) => HomeBase(
                    config: config,
                  ));
        }
        return MaterialPageRoute(builder: (_) => HomeBase());
      case splashScreenRoute:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => Home());
      case homeSearchRoute:
        return MaterialPageRoute(builder: (_) => HomeSearch());
      case cropListRoute:
        return MaterialPageRoute(builder: (_) => CropCategoryList());
      case cropListSelectionRoute:
        return MaterialPageRoute(
            builder: (_) => CropCategoryQuestionSelection());
      case cropIssueListRoute:
        PageArguments arguments = settings.arguments as PageArguments;
        return MaterialPageRoute(
            builder: (_) => CropIssueList(
                  id: arguments.id,
                ));
      case cropIssueDetailRoute:
        PageArguments arguments = settings.arguments as PageArguments;
        return MaterialPageRoute(
            builder: (_) => CropIssueDetail(
                  issueId: arguments.id,
                  issueType: arguments.cropIssueType,
                ));
      case cropQuestionListRoute:
        PageArguments arguments = settings.arguments as PageArguments;
        return MaterialPageRoute(
            builder: (_) => CropQuestionList(
                  cropCategoryId: arguments.id,
                ));
      case cropQuestionResultRoute:
        CropQuestionResultArgument arguments =
            settings.arguments as CropQuestionResultArgument;
        return MaterialPageRoute(
            builder: (_) => CropQuestionsResult(
                cropQuesstionResult: arguments.questionResult));
      case videoListRoute:
        return MaterialPageRoute(builder: (_) => VideoList());
      case productRoute:
        return MaterialPageRoute(builder: (_) => Product());
      case productDetailsRoute:
        PageArguments arguments = settings.arguments as PageArguments;
        return MaterialPageRoute(
            builder: (_) => ProductDetails(
                  productId: arguments.id,
                ));
      case productDealerRoute:
        ProductDealerArguments arguments =
            settings.arguments as ProductDealerArguments;
        return MaterialPageRoute(
            builder: (_) => Dealer(
                  productCatId: arguments.productCatId,
                  isFromProducts: arguments.isFromProduct,
                ),
            fullscreenDialog: true);
      case productUsefulInfoRoute:
        PageArguments arguments = settings.arguments as PageArguments;
        return MaterialPageRoute(
            builder: (_) => ProductUsefulInfo(
                  productId: arguments.id,
                ));
      case productUsefulInfoDetailsRoute:
        ProductArticle article = settings.arguments as ProductArticle;
        return MaterialPageRoute(
            builder: (_) => ProductUsefulInfoDetails(
                  infoDetails: article,
                ));
      case dealerRoute:
        return MaterialPageRoute(
            builder: (_) => Dealer(
                  isFromProducts: false,
                ));
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => Settings());
      case editProfileRoute:
        UserProfileArgument argument =
            settings.arguments as UserProfileArgument;
        return MaterialPageRoute(
            builder: (_) => EditProfile(
                  user: argument.user,
                ));
      case changeLanguageRoute:
        return MaterialPageRoute(builder: (_) => ChangeLanguage());
      case aboutUsRoute:
        return MaterialPageRoute(builder: (_) => AboutUs());
      case changePasswordRoute:
        return MaterialPageRoute(builder: (_) => ChangePassword());
      case termsAndConditionsRoute:
        return MaterialPageRoute(builder: (_) => TermsAndConditions());
      case privacyPolicyRoute:
        return MaterialPageRoute(builder: (_) => PrivacyPolicy());
      case newsRoute:
        return MaterialPageRoute(builder: (_) => News());
      case referralCodeRoute:
        return MaterialPageRoute(builder: (_) => ReferralCode());
      case newsArticleRoute:
        Article article = settings.arguments as Article;
        return MaterialPageRoute(
            builder: (_) => NewsArticle(
                  article: article,
                ));
      case webBrowserRoute:
        WebBrowserArgument argument = settings.arguments as WebBrowserArgument;
        return MaterialPageRoute(
          builder: (_) => WebBrowser(
            url: argument.url,
          ),
        );
      case photoViewSingleRoute:
        PhotoViewSingleArgument argument =
            settings.arguments as PhotoViewSingleArgument;
        return MaterialPageRoute(
          builder: (_) => PhotoViewSingleWrapper(
            imgUrl: argument.imgUrl,
          ),
        );
      case photoViewMultipleRoute:
        PhotoViewMultipleArgument argument =
            settings.arguments as PhotoViewMultipleArgument;
        return MaterialPageRoute(
          builder: (_) => GalleryPhotoViewWrapper(
            initialIndex: argument.initialIndex,
            galleryItems: argument.imgUrlList,
          ),
        );
      case cropProgrammeCropTypeListRoute:
        return MaterialPageRoute(builder: (_) => CropProgrammeCropTypeList());
      case cropProgrammeWebBrowserRoute:
        PageArguments argument = settings.arguments as PageArguments;
        return MaterialPageRoute(
          builder: (_) => CropProgrammeWebBrowser(
            id: argument.id,
          ),
        );
      case otpVerificationRoute:
        OtpVerifyArguments argument = settings.arguments as OtpVerifyArguments;
        return MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
                  phonenNo: argument.phoneNo,
                  fullname: argument.name,
                  password: argument.password,
                  area: argument.area,
                  referralCode: argument.referralCode,
                  agreeMarketUpdate: argument.agreeMarketUpdate,
                  photo: argument.photo,
                  isRegister: argument.isRegister,
                  //otp: argument.otp,
                ));
      case forgetPasswordMobileRoute:
        return MaterialPageRoute(builder: (_) => ForgetPasswordMobile());
      case resetPasswordMobileRoute:
        ResetPasswordArguments argument =
            settings.arguments as ResetPasswordArguments;
        return MaterialPageRoute(
            builder: (_) => ResetPassword(
                  otpCode: argument.otpCode,
                  mobileNo: argument.mobileNo,
                ));
      case resetPasswordSuccessRoute:
        return MaterialPageRoute(builder: (_) => ResetPasswordSuccess());
      case qnaRoute:
        return MaterialPageRoute(builder: (_) => QnA());
      case qnaSubmitRoute:
        return MaterialPageRoute(builder: (_) => CreateQna());
      case qnaDetailRoute:
        QnaArguments argument = settings.arguments as QnaArguments;
        return MaterialPageRoute(
            builder: (_) => QnaDetail(
                  qnaId: argument.id,
                  isAvailableGiveComment: argument.isAvailableGiveComment,
                ));
      case changeCountryRoute:
        return MaterialPageRoute(builder: (_) => ChangeCountry());
      case qrcodeScannerRoute:
        QrcodeScannerArgument argument =
            settings.arguments as QrcodeScannerArgument;
        return MaterialPageRoute(
            builder: (_) => QrcodeScanner(
                  scannerType: argument.scannerType,
                ));
      case accountSettingRoute:
        List<dynamic> args = settings.arguments as List;
        appUser.User myUser = args[0] as appUser.User;
        return MaterialPageRoute(
            builder: (_) => AccountSetting(
                  user: myUser,
                ));
      case accountDeleteDetailsRoute:
        return MaterialPageRoute(builder: (_) => DeleteAccountDetails());
      default:
        return MaterialPageRoute(builder: (_) => Landing());
    }
  }
}
