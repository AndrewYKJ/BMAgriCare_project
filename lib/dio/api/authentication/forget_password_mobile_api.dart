import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ForgetPasswordMobileApi extends DioRepo {
  ForgetPasswordMobileApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> forgetPassword(String phoneNo, String country) async {
    var params = {
      'mobileNo': phoneNo,
      'country': country,
    };

    Util.printInfo(">>> MOBILE FORGOT PASSWORD PARAMS: " + params.toString());
    try {
      Response response =
          await mDio.post('password/forgot/mobile', data: params);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
