import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CreateQnaCommentApi extends DioRepo {
  var bodyData;

  CreateQnaCommentApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<Response> call(int qnaId) async {
    try {
      Response response =
          await mDio.post("qnas/$qnaId/comments", data: bodyData);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
