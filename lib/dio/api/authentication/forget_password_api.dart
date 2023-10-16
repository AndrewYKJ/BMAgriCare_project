
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ForgetPasswordApi extends DioRepo {
  ForgetPasswordApi(BuildContext context) {
    dioContext = context;
  }

  Future<void> forgetPassword(String email, String language) async {
    var params = {
      'email' : email,
      'language': language,
    };
    try {
      Response response = await mDio.post('password/forgot',data: params);
      if (response.statusCode == 200) {
        Util.printInfo('ForgetPassword success');
      }
    } catch (e) {
      throw e;
    }
  }

    
}