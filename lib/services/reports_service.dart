import 'dart:convert';

import 'package:artriapp/models/api_responses/daily_metric_report.dart';
import 'package:artriapp/utils/enums/index.dart';
import 'package:artriapp/utils/env_variables.dart';
import 'package:http/http.dart' as http;

/// Leitura dos relatórios diários do usuário logado
class ReportsService {
  final http.Client _client;

  ReportsService(this._client);

  Future<List<DailyMetricReport>> getReports(EvolutionMetric metric) async {
    final baseUrl = Environment.apiUrl;
    final uri = Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}${metric.apiPath}',
    );

    final response =
        await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao buscar ${metric.label} (HTTP ${response.statusCode})',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => DailyMetricReport.fromJson(e, metric.levelField))
        .toList();
  }
}
