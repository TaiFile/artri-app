import 'dart:async';

import 'package:artriapp/services/index.dart';
import 'package:artriapp/utils/index.dart';
import 'package:http_interceptor/http_interceptor.dart';

class AuthInterceptor implements InterceptorContract {
  final SecurityTokenService _securityTokenService;

  AuthInterceptor(this._securityTokenService);

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final accessToken =
        await _securityTokenService.getToken(SecurityToken.accessToken);

    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return true;
  }
}
