import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MobileResetPasswordApi extends DioRepo {
  MobileResetPasswordApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> resetPassword(
      String otpCode, String newPassword, String phoneNo) async {
    var params = {
      'otp': otpCode,
      'password': newPassword,
      'mobileNo': phoneNo,
    };

    Util.printInfo(">>> MOBILE RESET PASSWORD: " + params.toString());

    try {
      Response response =
          await mDio.post('password/reset/mobile', data: params);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
