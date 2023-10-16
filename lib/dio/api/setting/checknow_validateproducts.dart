import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/setting/checknow_validateproduct.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CheckNowValidateProductsApi extends DioRepo {
  var bodyData;

  CheckNowValidateProductsApi(BuildContext context, {bodyData}) {
    dioContext = context;
    this.bodyData = bodyData;
  }

  Future<CheckNowValidateProductDTO> call() async {
    try {
      Util.printInfo(
          ">>>>> VALIDATE PRODUCT BODY DATA: " + this.bodyData.toString());
      Response response =
          await mDio.post("checkNow/productAuth", data: this.bodyData);
      return CheckNowValidateProductDTO.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
