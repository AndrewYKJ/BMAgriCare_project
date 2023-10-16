import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class QnaCommentApi extends DioRepo {
  QnaCommentApi(BuildContext context) {
    dioContext = context;
  }

  Future<List<dynamic>> call(int qnaId, int pageNo, int pageSize) async {
    try {
      Map<String, dynamic> queryParams = {"page": pageNo, "size": pageSize};

      Response response =
          await mDio.get("qnas/$qnaId/comments", queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
