import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class QnaListApi extends DioRepo {
  QnaListApi(BuildContext context) {
    dioContext = context;
  }

  Future<List<dynamic>> call(String filter, int pageNo, int pageSize) async {
    try {
      Map<String, dynamic> queryParams = {
        "filter": filter,
        "page": pageNo,
        "size": pageSize
      };

      Response response = await mDio.get("qnas", queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
