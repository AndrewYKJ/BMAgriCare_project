import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/setting/checknow_point.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CheckNowCollectPointApi extends DioRepo {
  var bodyData;

  CheckNowCollectPointApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<CheckNowPointDTO> call() async {
    try {
      Response response =
          await mDio.post("checkNow/collectPoint", data: this.bodyData);
      return CheckNowPointDTO.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
