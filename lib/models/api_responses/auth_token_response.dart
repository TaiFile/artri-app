class AuthTokenResponse {
  final String accessToken;

  /// Presente no login; o endpoint de refresh devolve só o access token
  final String? refreshToken;

  const AuthTokenResponse({
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String?,
    );
  }
}
