import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CheckNowUnlinkApi extends DioRepo {
  var bodyData;

  CheckNowUnlinkApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<Response> call() async {
    try {
      Response response = await mDio.delete("checkNow/unlink");
      return response;
    } catch (e) {
      throw e;
    }
  }
}
