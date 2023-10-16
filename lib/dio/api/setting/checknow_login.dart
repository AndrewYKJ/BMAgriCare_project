import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/setting/checknow.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CheckNowLoginApi extends DioRepo {
  var bodyData;

  CheckNowLoginApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<CheckNowDTO> call() async {
    try {
      Response response = await mDio.get("checkNow/login");
      return CheckNowDTO.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
