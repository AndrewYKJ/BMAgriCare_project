import 'package:dio/dio.dart';

class LoggingInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(
        "--> ${options.method != null ? options.method.toUpperCase() : 'METHOD'} ${"" + (options.baseUrl ?? "") + (options.path ?? "")}");
    print("Headers:");
    options.headers.forEach((k, v) => print('$k: $v'));
    if (options.queryParameters != null) {
      print("queryParameters:");
      options.queryParameters.forEach((k, v) => print('$k: $v'));
    }
    if (options.data != null) {
      print("Body: ${options.data}");
    }
    print(
        "--> END ${options.method != null ? options.method.toUpperCase() : 'METHOD'}");

    return handler.next(options);
  }

  @override
  void onError(DioError dioError, ErrorInterceptorHandler handler) {
    print(
        "<-- ${dioError.message} ${(dioError.response?.requestOptions != null ? (dioError.response.requestOptions.baseUrl + dioError.response.requestOptions.path) : 'URL')}");
    print(
        "${dioError.response != null ? dioError.response.data : 'Unknown Error'}");
    print("<-- End error");
    return handler.next(dioError);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        "<-- ${response.statusCode} ${(response.requestOptions != null ? (response.requestOptions.baseUrl + response.requestOptions.path) : 'URL')}");
    print("Headers:");
    response.headers?.forEach((k, v) => print('$k: $v'));
    print("Response: ${response.data}");
    print("<-- END HTTP");
    return handler.next(response);
  }
}
