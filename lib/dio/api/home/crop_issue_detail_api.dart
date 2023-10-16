import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CropIssueDetailApi extends DioRepo {
  CropIssueDetailApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> call(int issueId) async {
    try {
      Response response = await mDio.get("crops/issues/$issueId");
      return response;
    } catch (e) {
      throw e;
    }
  }
}
