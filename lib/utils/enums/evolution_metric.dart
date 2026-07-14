import 'package:artriapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Métricas do diário exibidas na tela de Evolução. Cada uma sabe o endpoint
/// de leitura, o campo de nível no JSON, o rótulo e a cor da linha do gráfico
enum EvolutionMetric {
  pain,
  fatigue,
  sleep,
  swelling;

  String get apiPath {
    switch (this) {
      case EvolutionMetric.pain:
        return 'daily-pain-reports/';
      case EvolutionMetric.fatigue:
        return 'daily-fatigue-reports/';
      case EvolutionMetric.sleep:
        return 'daily-sleep-reports/';
      case EvolutionMetric.swelling:
        return 'daily-swelling-reports/';
    }
  }

  String get levelField {
    switch (this) {
      case EvolutionMetric.pain:
        return 'pain_level';
      case EvolutionMetric.fatigue:
        return 'fatigue_level';
      case EvolutionMetric.sleep:
        return 'sleep_level';
      case EvolutionMetric.swelling:
        return 'swelling_level';
    }
  }

  String get label {
    switch (this) {
      case EvolutionMetric.pain:
        return 'Dor';
      case EvolutionMetric.fatigue:
        return 'Fadiga';
      case EvolutionMetric.sleep:
        return 'Sono';
      case EvolutionMetric.swelling:
        return 'Inchaço';
    }
  }

  Color get color {
    switch (this) {
      case EvolutionMetric.pain:
        return const Color(0xFFAE263D);
      case EvolutionMetric.fatigue:
        return AppColors.darkGreen;
      case EvolutionMetric.sleep:
        return AppColors.darkBlue;
      case EvolutionMetric.swelling:
        return const Color(0xFFE08D3C);
    }
  }
}
