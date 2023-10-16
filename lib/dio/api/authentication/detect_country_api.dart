import 'package:behn_meyer_flutter/models/detect-country/detect-country.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../dio_repo.dart';

class DetectCountryApi extends DioRepo {
  DetectCountryApi(BuildContext context) {
    dioContext = context;
  }

  Future<DetectCountryModel> getCountryInfo(String apiKey) async {
    var params = {
      'apiKey': apiKey,
    };

    try {
      Response response =
          await mDio.get("detect/country", queryParameters: params);
      return DetectCountryModel.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
