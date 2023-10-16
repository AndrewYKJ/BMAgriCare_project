import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LogoutApi extends DioRepo {
  LogoutApi(BuildContext context) {
    dioContext = context;
  }

  Future<void> logout(
      BuildContext context, String deviceId, String deviceType) async {
    try {
      Response response = await mDio.post('logout');
      if (response.statusCode == 200) {
        Util.printInfo('Logout success');
      }
    } catch (e) {
      throw e;
    }
  }
}
