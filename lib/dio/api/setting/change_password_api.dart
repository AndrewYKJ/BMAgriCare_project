import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ChangePasswordApi extends DioRepo {
  var bodyData;

  ChangePasswordApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<Response> call() async {
    try {
      Response response = await mDio.put("password", data: this.bodyData);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
