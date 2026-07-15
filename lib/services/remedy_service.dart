import 'dart:convert';

import 'package:artriapp/models/api_responses/remedy.dart';
import 'package:artriapp/utils/env_variables.dart';
import 'package:http/http.dart' as http;

/// Leitura e criação dos medicamentos diários do usuário logado
class RemedyService {
  /// Client autenticado (Bearer token + refresh automático em 401)
  final http.Client _client;

  RemedyService(this._client);

  Uri _remedyUri([String suffix = '']) {
    final baseUrl = Environment.apiUrl;
    return Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}remedies/$suffix',
    );
  }

  Future<List<Remedy>> getRemedies() async {
    final response =
        await _client.get(_remedyUri()).timeout(const Duration(seconds: 15));

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
    final response = await _client
        .post(
          _remedyUri(),
          headers: {'Content-Type': 'application/json'},
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
    final response = await _client
        .patch(
          _remedyUri('$id/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'quantity': quantity}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar medicamento (HTTP ${response.statusCode})');
    }

    return Remedy.fromMap(jsonDecode(response.body));
  }
}
