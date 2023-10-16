import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/dio/dio_repo.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UserProfileApi extends DioRepo {
  UserProfileApi(BuildContext context) {
    dioContext = context;
  }

  Future<User> completeProfile(
      String email, String name, int photo, bool agreeMarketingUpdate,
      {String company, String area, String referralCode}) async {
    var params = {
      "email": email,
      "name": name,
      "photo": photo,
      "agreeMarketingUpdate": agreeMarketingUpdate
    };
    if (company != null && company.length > 0) {
      params['company'] = company;
    }

    if (area != null && area.length > 0) {
      params['area'] = area;
    }

    if (referralCode != null && referralCode.length > 0) {
      params['referralCode'] = referralCode;
    }

    Util.printInfo(">>> COMPLETE PROFILE PARAMS: " + params.toString());

    try {
      Response response = await mDio.post("users/complete", data: params);
      return User.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<User> getOwnUserProfile() async {
    try {
      Response response = await mDio.get("users/profile");
      AppCache.me = User.fromJson(response.data);
      return User.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
