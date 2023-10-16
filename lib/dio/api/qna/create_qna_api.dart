import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CreateQnaApi extends DioRepo {
  var bodyData;

  CreateQnaApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<Response> call() async {
    try {
      Response response = await mDio.post("qnas", data: bodyData);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
