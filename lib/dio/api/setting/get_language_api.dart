import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GetLanguageApi extends DioRepo {
  GetLanguageApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> call() async {
    try {
      Response response = await mDio.get("languages");
      return response;
    } catch (e) {
      throw e;
    }
  }
}
