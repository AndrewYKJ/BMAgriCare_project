import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class QnaDetailApi extends DioRepo {
  QnaDetailApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> call(int qnaId) async {
    try {
      Response response = await mDio.get("qnas/$qnaId");
      return response;
    } catch (e) {
      throw e;
    }
  }
}
