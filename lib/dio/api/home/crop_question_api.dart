import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CropQuestionApi extends DioRepo {
  CropQuestionApi(BuildContext context) {
    dioContext = context;
  }

  Future<List<dynamic>> call(int cropCategoryId) async {
    try {
      Map<String, dynamic> queryParameters = {"categoryIds": cropCategoryId};
      Response response =
          await mDio.get("crops/questions", queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
