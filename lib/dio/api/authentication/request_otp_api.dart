import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RequestOtpApi extends DioRepo {
  RequestOtpApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> requestOtp(String name, String password, String language,
      String phoneNo, String countryCode) async {
    var params = {
      "mobileNo": phoneNo,
      "password": password,
      "name": name,
      "language": language,
      "country": countryCode
    };

    Util.printInfo(">>>>>>>>>>>>> REQUEST OTP: " + params.toString());

    try {
      Response response = await mDio.post("register/mobile/otp",
          data: FormData.fromMap(params));
      return response;
    } catch (e) {
      throw e;
    }
  }
}
