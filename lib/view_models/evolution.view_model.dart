import 'dart:developer';

import 'package:artriapp/models/api_responses/daily_metric_report.dart';
import 'package:artriapp/services/index.dart';
import 'package:artriapp/utils/enums/index.dart';
import 'package:flutter/material.dart';

/// Carrega os relatórios diários e os agrega para o gráfico de Evolução:
/// janela dos últimos 7 dias, com a média dos níveis registrados em cada dia
class EvolutionViewModel extends ChangeNotifier {
  final ReportsService _service;

  EvolutionViewModel(this._service);

  static const int daysWindow = 7;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  final Map<EvolutionMetric, List<double?>> _series = {};

  /// Série de [daysWindow] valores para a métrica, ou null nos
  /// dias sem registro
  List<double?> seriesFor(EvolutionMetric metric) =>
      _series[metric] ?? List<double?>.filled(daysWindow, null);

  /// Datas do eixo X (índice 0 = 6 dias atrás; índice 6 = hoje)
  List<DateTime> _days = [];
  List<DateTime> get days => _days;

  bool get hasAnyData =>
      _series.values.any((serie) => serie.any((value) => value != null));

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    _days = List.generate(
      daysWindow,
      (i) => base.subtract(Duration(days: daysWindow - 1 - i)),
    );

    try {
      final entries = await Future.wait(
        EvolutionMetric.values.map((metric) async {
          final reports = await _service.getReports(metric);
          return MapEntry(metric, _aggregateByDay(reports));
        }),
      );
      _series
        ..clear()
        ..addEntries(entries);
    } catch (e) {
      log('Erro ao carregar evolução: $e');
      _error = 'Não foi possível carregar sua evolução. Tente novamente.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Média dos níveis por dia, encaixando cada registro no índice da janela
  List<double?> _aggregateByDay(List<DailyMetricReport> reports) {
    final sums = List<double>.filled(daysWindow, 0);
    final counts = List<int>.filled(daysWindow, 0);

    for (final report in reports) {
      final day = DateTime(report.date.year, report.date.month, report.date.day);
      final idx = _days.indexWhere((d) => d == day);
      if (idx == -1) continue; // fora da janela de 7 dias
      sums[idx] += report.level;
      counts[idx] += 1;
    }

    return List<double?>.generate(
      daysWindow,
      (i) => counts[i] == 0 ? null : sums[i] / counts[i],
    );
  }
}
