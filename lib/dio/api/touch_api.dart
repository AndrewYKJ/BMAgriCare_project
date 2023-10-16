import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TouchApi extends DioRepo {
  var bodyData;

  TouchApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<Response> call() async {
    try {
      Response response = await mDio.put("touch", data: bodyData);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
