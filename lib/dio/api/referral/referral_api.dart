import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/referral/referral-model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ReferralApi extends DioRepo {
  ReferralApi(BuildContext context) {
    dioContext = context;
  }

  Future<ReferralModel> getReferralInfo() async {
    try {
      Response response = await mDio.get("referral/reward/info");
      return ReferralModel.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
