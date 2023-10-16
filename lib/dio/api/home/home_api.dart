import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/home/dashboard/home.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeApi extends DioRepo {
  HomeApi(BuildContext context) {
    dioContext = context;
  }

  Future<HomeDTO> call() async {
    try {
      Response response = await mDio.get("dashboard");
      return HomeDTO.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
