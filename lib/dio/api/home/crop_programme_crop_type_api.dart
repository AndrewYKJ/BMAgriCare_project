import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CropProgrammeCropTypeApi extends DioRepo {
  CropProgrammeCropTypeApi(BuildContext context) {
    dioContext = context;
  }

  Future<List<dynamic>> call(bool hasCropProgramme) async {
    try {
      Map<String, dynamic> queryParameters = {
        "hasCropProgrammeOnly": hasCropProgramme
      };
      Response response =
          await mDio.get("crops/categories", queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}
