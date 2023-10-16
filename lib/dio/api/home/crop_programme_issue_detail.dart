import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/home/crop/crop_programme_issue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CropProgrammeIssueApi extends DioRepo {
  CropProgrammeIssueApi(BuildContext context) {
    dioContext = context;
  }

  Future<CropProgrammeIssuesDTO> call(int cropCatId) async {
    try {
      Map<String, dynamic> queryParameters = {"type": "crop_programme"};
      Response response = await mDio.get("crops/categories/$cropCatId/issues",
          queryParameters: queryParameters);
      return CropProgrammeIssuesDTO.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
