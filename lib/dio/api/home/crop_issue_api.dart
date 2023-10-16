import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_issue_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CropIssueApi extends DioRepo {
  CropIssueApi(BuildContext context) {
    dioContext = context;
  }

  Future<CropIssuesDTO> call(int cropCatId) async {
    try {
      Response response = await mDio.get("crops/categories/$cropCatId/issues");
      return CropIssuesDTO.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
