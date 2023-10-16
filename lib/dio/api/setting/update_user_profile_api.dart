import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UpdateUserProfileApi extends DioRepo {
  var bodyData;

  UpdateUserProfileApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<Response> call() async {
    try {
      Response response = await mDio.put("users/profile", data: bodyData);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
