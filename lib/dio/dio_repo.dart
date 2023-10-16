import 'dart:io';

import 'package:behn_meyer_flutter/cache/appcache.dart';
import 'package:behn_meyer_flutter/controllers/landing.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'interceptor/logging.dart';

class DioRepo {
  Dio mDio;
  int retryCount = 0;
  BuildContext dioContext;

  String host = "http://behn-meyer-api.thewellmall.com/";
  String devHost = "http://behn-meyer-api-dev.thewellmall.com/";
  String stgHost = "https://api-agricarestg.behnmeyer.com.my/";
  String production = "https://api-agricare.behnmeyer.com.my/";

  Dio baseConfig() {
    Dio dio = Dio();
    dio..options.baseUrl = stgHost;
    // dio..options.baseUrl = production;
    dio..options.connectTimeout = 15000;
    dio..options.receiveTimeout = 15000;
    dio..httpClientAdapter;

    return dio;
  }

  DioRepo() {
    this.mDio = baseConfig();
    this.mDio
      ..interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            this.mDio.interceptors.requestLock.lock();
            AppCache.getStringValue(AppCache.ACCESS_TOKEN_PREF).then((value) {
              if (value != null) {
                options.headers[HttpHeaders.authorizationHeader] =
                    'Bearer ' + value;
              }
            }).whenComplete(() {
              this.mDio.interceptors.requestLock.unlock();
            });
            return handler.next(options);
          },
          onError: (e, handler) async {
            if (e.response?.statusCode == 401) {
              if (this.retryCount < 3) {
                this.mDio.lock();
                this.mDio.interceptors.requestLock.lock();
                this.mDio.interceptors.responseLock.lock();
                return refreshTokenAndRetry(e.response.requestOptions, handler);
              }

              showAlertDialog(
                  e.response.data['code'], e.response.data['message']);
              return e.response;
            }

            return handler.next(e);
          },
          onResponse: (response, handler) async {
            return handler.next(response);
          },
        ),
        LoggingInterceptors()
      ]);
  }

  Future<void> refreshTokenAndRetry(
      RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    bool isError = false;
    Dio tokenDio = baseConfig();
    tokenDio..interceptors.add(LoggingInterceptors());
    await AppCache.getStringValue(AppCache.REFRESH_TOKEN_PREF)
        .then((value) async {
      final refreshToken = value;
      tokenDio
        ..options.headers = {
          'Authorization': 'Bearer $refreshToken',
        };
      try {
        tokenDio.post('token/refresh').then((res) {
          if (res.statusCode == 200) {
            AppCache.removeAuthToken();
            AppCache.setString(
                AppCache.ACCESS_TOKEN_PREF, res.data['accessToken']);
            AppCache.setString(
                AppCache.REFRESH_TOKEN_PREF, res.data['refreshToken']);
          } else {
            isError = true;
            showAlertDialog("Error", "An error occurred");
          }
        }).catchError((error) {
          print("Refresh Token Catch Error : ${error.message}");
          isError = true;
          if (error is DioError) {
            if (error.response != null) {
              if (error.response.data != null) {
                showAlertDialog(error.response.data['code'],
                    error.response.data['message']);
              } else {
                showAlertDialog("Error", "An error occurred");
              }
            } else {
              showAlertDialog("Error", "An error occurred");
            }
          } else {
            showAlertDialog("Error", "An error occurred");
          }
        }).whenComplete(() {
          this.mDio.unlock();
          this.mDio.interceptors.responseLock.unlock();
          this.mDio.interceptors.errorLock.unlock();
        }).then((e) {
          //repeat
          if (!isError) {
            this.retryCount++;
            this.mDio.fetch(requestOptions).then(
              (r) => handler.resolve(r),
              onError: (e) {
                handler.reject(e);
              },
            );
          }
        });
        // return;
      } on DioError catch (e) {
        print("Refresh Token Error : ${e.message}");
        showAlertDialog("Error", "An error occurred");
      }
    });
  }

  // Future<Response> _retry(RequestOptions requestOptions) async {
  //   this.retryCount++;
  //   final options = new Options(
  //     method: requestOptions.method,
  //     headers: requestOptions.headers,
  //   );
  //   return this.mDio.request<dynamic>(requestOptions.path,
  //       data: requestOptions.data,
  //       queryParameters: requestOptions.queryParameters,
  //       options: options);
  // }

  void showAlertDialog(String title, String message) {
    showDialog(
      context: dioContext,
      barrierDismissible: false,
      builder: (_) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Close'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  this.dioContext,
                  MaterialPageRoute(builder: (context) => Landing()),
                  (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
