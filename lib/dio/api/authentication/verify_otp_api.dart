import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class VerifyOtpApi extends DioRepo {
  VerifyOtpApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> verifyOtp(String otpCode) async {
    Map<String, dynamic> queryParameters = {
      "otp": otpCode,
      "type": "RESET_PWD_BY_MOBILE"
    };

    Util.printInfo(
        ">>>>>>>>>>>>> VERIFY OTP PARAMS: " + queryParameters.toString());

    try {
      Response response =
          await mDio.get("verify/otp", queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
