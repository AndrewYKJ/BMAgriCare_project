import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CropCategoryApi extends DioRepo {
  CropCategoryApi(BuildContext context) {
    dioContext = context;
  }

  Future<List<dynamic>> call(bool hasQuestion) async {
    try {
      Map<String, dynamic> queryParameters = {"hasQuestionOnly": hasQuestion};
      Response response =
          await mDio.get("crops/categories", queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
