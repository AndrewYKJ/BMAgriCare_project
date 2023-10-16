import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/dealer/outlet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DealerApi extends DioRepo {
  DealerApi(BuildContext context) {
    dioContext = context;
  }

  Future<List<Outlet>> fetchOutletList(double currentLat, double currentLng,
      int productCatId, int page, int size) async {
    try {
      Map<String, dynamic> queryParameters = {
        "lat": currentLat,
        "lng": currentLng,
        "page": page,
        "size": size
      };

      if (productCatId != null && productCatId > 0) {
        queryParameters["categoryId"] = productCatId;
      }

      Response response =
          await mDio.get('dealers', queryParameters: queryParameters);
      return (response.data as List).map((x) => Outlet.fromJson(x)).toList();
    } catch (e) {
      throw e;
    }
  }
}
