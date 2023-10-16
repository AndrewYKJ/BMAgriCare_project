import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchApi extends DioRepo {
  SearchApi(BuildContext context) {
    dioContext = context;
  }

  Future<Response> call(String keyword, int pageNo, int pageSize) async {
    try {
      Map<String, dynamic> queryParams = {
        "keyword": keyword,
        "page": pageNo,
        "size": pageSize
      };
      Response response =
          await mDio.get("crops/issues", queryParameters: queryParams);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<Response> search(String keyword, int pageNo, int pageSize) async {
    try {
      Map<String, dynamic> queryParams = {
        "keyword": keyword,
        "page": pageNo,
        "size": pageSize
      };
      Response response =
          await mDio.get("search", queryParameters: queryParams);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
