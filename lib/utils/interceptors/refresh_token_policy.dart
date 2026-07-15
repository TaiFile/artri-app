import 'dart:async';

import 'package:artriapp/services/index.dart';
import 'package:artriapp/utils/index.dart';
import 'package:http_interceptor/http_interceptor.dart';

class RefreshTokenPolicy implements RetryPolicy {
  final AuthService _authService;
  final SecurityTokenService _securityTokenService;

  Future<bool>? _refreshInFlight;

  RefreshTokenPolicy(this._authService, this._securityTokenService);

  @override
  Duration delayRetryAttemptOnException({required int retryAttempt}) {
    return Duration.zero;
  }

  @override
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) {
    return Duration.zero;
  }

  @override
  int get maxRetryAttempts => 1;

  @override
  FutureOr<bool> shouldAttemptRetryOnException(
    Exception reason,
    BaseRequest request,
  ) {
    return false;
  }

  @override
  FutureOr<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode != 401) return false;

    _refreshInFlight ??= _refreshTokens();
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _refreshTokens() async {
    final refreshToken =
        await _securityTokenService.getToken(SecurityToken.refreshToken);

    if (refreshToken == null) return false;

    try {
      final response = await _authService.refreshAuthToken(refreshToken);

      await _securityTokenService.saveToken(
        response.accessToken,
        SecurityToken.accessToken,
      );

      final newRefreshToken = response.refreshToken;
      if (newRefreshToken != null) {
        await _securityTokenService.saveToken(
          newRefreshToken,
          SecurityToken.refreshToken,
        );
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
