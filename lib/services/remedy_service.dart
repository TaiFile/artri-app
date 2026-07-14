import 'dart:convert';

import 'package:artriapp/models/api_responses/remedy.dart';
import 'package:artriapp/services/security_token_service.dart';
import 'package:artriapp/utils/enums/security_tokens.dart';
import 'package:artriapp/utils/env_variables.dart';
import 'package:http/http.dart' as http;

/// Leitura e criação dos medicamentos diários do usuário logado
class RemedyService {
  final SecurityTokenService _securityTokenService;

  RemedyService(this._securityTokenService);

  Uri _remedyUri([String suffix = '']) {
    final baseUrl = Environment.apiUrl;
    return Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}remedies/$suffix',
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token =
        await _securityTokenService.getToken(SecurityToken.accessToken);
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Remedy>> getRemedies() async {
    final response = await http
        .get(_remedyUri(), headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar medicamentos (HTTP ${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Remedy.fromMap(e)).toList();
  }

  Future<Remedy> createRemedy({
    required String name,
    required String description,
    required int quantity,
    required String hour,
  }) async {
    final headers = await _authHeaders()
      ..['Content-Type'] = 'application/json';

    final response = await http
        .post(
          _remedyUri(),
          headers: headers,
          body: jsonEncode({
            'name': name,
            'description': description,
            'quantity': quantity,
            'hour': hour,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw Exception('Falha ao criar medicamento (HTTP ${response.statusCode})');
    }

    return Remedy.fromMap(jsonDecode(response.body));
  }

  /// Atualiza a quantidade restante do medicamento (ex.: ao confirmar que
  /// o usuário tomou a dose). Remédios com quantidade <= 0 somem do GET.
  Future<Remedy> updateQuantity({required int id, required int quantity}) async {
    final headers = await _authHeaders()
      ..['Content-Type'] = 'application/json';

    final response = await http
        .patch(
          _remedyUri('$id/'),
          headers: headers,
          body: jsonEncode({'quantity': quantity}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar medicamento (HTTP ${response.statusCode})');
    }

    return Remedy.fromMap(jsonDecode(response.body));
  }
}
