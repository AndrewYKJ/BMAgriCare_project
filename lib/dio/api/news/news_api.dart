import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/news/article.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NewsApi extends DioRepo {
  NewsApi(BuildContext context) {
    dioContext = context;
  }

  Future<List<Article>> fetchNewsList(String page, String size) async {
    try {
      Response response = await mDio.get('news', queryParameters: {"page": page, "size": size});
      return (response.data as List)
          .map((x) => Article.fromJson(x))
          .toList();
    } catch (e) {
      throw e;
    }
  }
}