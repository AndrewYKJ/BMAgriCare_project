import 'package:behn_meyer_flutter/const/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../dio_repo.dart';

class DeleteAccountApi extends DioRepo {
  DeleteAccountApi(BuildContext context) {
    dioContext = context;
  }

  Future<void> deleteAccount(String password) async {
    var params = {
      'password' : password,
    };
    try {
      Response response = await mDio.delete('users', queryParameters: params);
      if (response.statusCode == 200) {
        Util.printInfo('delete account success');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteSocialAccount() async {
    try {
      Response response = await mDio.delete('users');
      if (response.statusCode == 200) {
        Util.printInfo('delete account success');
      }
    } catch (e) {
      throw e;
    }
  }

    
}