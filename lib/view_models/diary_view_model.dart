import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:artriapp/utils/env_variables.dart' as env;
import 'package:artriapp/services/index.dart';
import 'package:artriapp/utils/index.dart';

class DiaryViewModel extends ChangeNotifier {
  final SecurityTokenService _securityTokenService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DiaryViewModel(this._securityTokenService);

  Future<bool> _enviarMetrica(String endpoint, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final baseUrl = env.Environment.apiUrl;
      final uri = Uri.parse(
        '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}$endpoint',
      );

      final accessToken =
          await _securityTokenService.getToken(SecurityToken.accessToken);

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (accessToken != null && accessToken.isNotEmpty)
                'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erro ao comunicar com a API em $endpoint: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enviarRelatorioSono({required int nivel}) async {
    return await _enviarMetrica('daily-sleep-report/', {
      'level': nivel,
      'date': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  Future<bool> enviarRelatorioFadiga({required int nivel}) async {
    return await _enviarMetrica('daily-fatigue-report/', {
      'level': nivel,
      'date': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  Future<bool> enviarRelatorioDor(Map<String, int> niveisPorLocal) async {
    if (niveisPorLocal.isEmpty) return false;

    final date = DateTime.now().toIso8601String().split('T')[0];

    for (final entry in niveisPorLocal.entries) {
      final sucesso = await _enviarMetrica('daily-pain-reports/', {
        'pain_level': entry.value,
        'pain_location': entry.key,
        'date': date,
      });
      if (!sucesso) return false;
    }

    return true;
  }

  Future<bool> enviarRelatorioInchaco({required int nivel}) async {
    return await _enviarMetrica('daily-swelling-report/', {
      'level': nivel,
      'date': DateTime.now().toIso8601String().split('T')[0],
    });
  }
}