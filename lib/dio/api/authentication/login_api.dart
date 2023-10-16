import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum LoginType { Email, Facebook, Google, Apple, Mobile }

extension CatExtension on LoginType {
  String get name {
    return ["email", "facebook", "google", "apple", "mobile_no"][this.index];
  }
}

class LoginApi extends DioRepo {
  LoginApi(BuildContext context) {
    dioContext = context;
  }

  Future<User> onEmailLogin(String email, String password, bool isiOS,
      String language, String country,
      {String deviceId,
      String deviceModel,
      String deviceOSVersion,
      String appVersion}) async {
    var params = {
      'type': 'email',
      'accountId': email,
      'accountToken': password,
      'deviceType': isiOS ? 'ios' : 'android',
      'deviceId': deviceId != null ? deviceId : '',
      'deviceModel': deviceModel != null ? deviceModel : '',
      'deviceOSVersion': deviceOSVersion != null ? deviceOSVersion : '',
      'appVersion': appVersion != null ? appVersion : '1.0.0',
      'language': language,
      'country': country
    };

    Util.printInfo(">>> EMAIL LOGIN : " + params.toString());
    try {
      Response response = await mDio.post('login', data: params);
      if (response.data != null) {
        var accessToken;
        var refreshToken;
        if (response.data['status'] == UserStatus.Active.name) {
          if (response.data['accessToken'] != null) {
            Util.printInfo(
                '[LOGIN API] AccessToken: ${response.data['accessToken']}');
            accessToken = response.data['accessToken'];
          }

          if (response.data['refreshToken'] != null) {
            Util.printInfo(
                '[LOGIN API] RefreshToken: ${response.data['refreshToken']}');
            refreshToken = response.data['refreshToken'];
          }

          AppCache.setAuthToken(accessToken, refreshToken);
        }
      }
      return User.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<User> onSocialLogin(
      String firebaseUserId,
      String firebaseToken,
      String accountId,
      String accountToken,
      String type,
      bool isiOS,
      String language,
      String country,
      {String deviceId,
      String deviceModel,
      String deviceOSVersion,
      String appVersion}) async {
    var params = {
      'firebaseToken': firebaseToken,
      'firebaseUserId': firebaseUserId,
      'type': type,
      'accountId': accountId,
      'accountToken': accountToken,
      'deviceType': isiOS ? 'ios' : 'android',
      'deviceId': deviceId != null ? deviceId : '',
      'deviceModel': deviceModel != null ? deviceModel : '',
      'deviceOSVersion': deviceOSVersion != null ? deviceOSVersion : '',
      'appVersion': appVersion != null ? appVersion : '1.0.0',
      'language': language,
      'country': country
    };

    Util.printInfo(">>> SOCIAL LOGIN : " + params.toString());
    try {
      Response response = await mDio.post('login', data: params);
      if (response.data != null) {
        var accessToken;
        var refreshToken;

        if (response.data['accessToken'] != null) {
          Util.printInfo(
              '[LOGIN API] AccessToken: ${response.data['accessToken']}');
          accessToken = response.data['accessToken'];
        }

        if (response.data['refreshToken'] != null) {
          Util.printInfo(
              '[LOGIN API] RefreshToken: ${response.data['refreshToken']}');
          refreshToken = response.data['refreshToken'];
        }
        AppCache.setAuthToken(accessToken, refreshToken);
      }
      return User.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<User> onMobileLogin(String phoneNo, String password, bool isiOS,
      String language, String country,
      {String deviceId,
      String deviceModel,
      String deviceOSVersion,
      String appVersion}) async {
    var params = {
      'type': 'mobile_no',
      'accountId': phoneNo,
      'accountToken': password,
      'deviceType': isiOS ? 'ios' : 'android',
      'deviceId': deviceId != null ? deviceId : '',
      'deviceModel': deviceModel != null ? deviceModel : '',
      'deviceOSVersion': deviceOSVersion != null ? deviceOSVersion : '',
      'appVersion': appVersion != null ? appVersion : '1.0.0',
      'language': language,
      'country': country
    };

    Util.printInfo(">>> MOBILE LOGIN : " + params.toString());
    try {
      Response response = await mDio.post('login', data: params);
      if (response.data != null) {
        var accessToken;
        var refreshToken;
        if (response.data['status'] == UserStatus.Active.name) {
          if (response.data['accessToken'] != null) {
            Util.printInfo(
                '[LOGIN API] AccessToken: ${response.data['accessToken']}');
            accessToken = response.data['accessToken'];
          }

          if (response.data['refreshToken'] != null) {
            Util.printInfo(
                '[LOGIN API] RefreshToken: ${response.data['refreshToken']}');
            refreshToken = response.data['refreshToken'];
          }

          AppCache.setAuthToken(accessToken, refreshToken);
        }
      }
      return User.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
