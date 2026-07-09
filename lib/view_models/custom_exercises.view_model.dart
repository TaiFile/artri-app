import 'dart:developer';

import 'package:artriapp/models/index.dart';
import 'package:artriapp/routes/index.dart';
import 'package:artriapp/services/index.dart';
import 'package:artriapp/utils/consts/custom_exercise_quotas.dart';
import 'package:artriapp/utils/enums/index.dart';
import 'package:artriapp/view_models/physical_exercises.view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Gerencia o fluxo de montagem da rotina de exercícios personalizados:
/// escolha do nível, busca do catálogo no backend, seleção por categoria
/// respeitando as quotas e montagem da rotina final. A execução passo a passo
/// é delegada ao [PhysicalExercisesViewModel].
class CustomExercisesViewModel extends ChangeNotifier {
  final PhysicalExercisesService _service;

  CustomExercisesViewModel(this._service);

  ExerciseDifficulty? _difficulty;
  ExerciseDifficulty? get difficulty => _difficulty;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  final Map<ExerciseCategory, List<Exercise>> _catalog = {};
  final Map<ExerciseCategory, Set<int>> _selected = {};

  List<ExerciseCategory> get categories =>
      _difficulty == null ? const [] : quotaOrderFor(_difficulty!);

  List<Exercise> optionsFor(ExerciseCategory category) =>
      _catalog[category] ?? const [];

  int quotaFor(ExerciseCategory category) =>
      customExerciseQuotas[_difficulty]?[category] ?? 0;

  bool isSelected(ExerciseCategory category, int exerciseId) =>
      _selected[category]?.contains(exerciseId) ?? false;

  int selectedCount(ExerciseCategory category) =>
      _selected[category]?.length ?? 0;

  bool isQuotaMet(ExerciseCategory category) =>
      selectedCount(category) == quotaFor(category);

  bool get allQuotasMet =>
      categories.isNotEmpty && categories.every(isQuotaMet);

  /// Seleciona o nível e navega para a tela de introdução daquele nível,
  /// reiniciando qualquer seleção anterior.
  void selectLevel(ExerciseDifficulty difficulty, BuildContext context) {
    _difficulty = difficulty;
    _catalog.clear();
    _selected.clear();
    _error = null;
    context.go('${PhysicalExerciseRoutes.customExercises}/$difficulty');
  }

  /// Busca o catálogo do backend e agrupa por categoria.
  Future<void> loadCatalog() async {
    if (_difficulty == null || _catalog.isNotEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final exercises = await _service.getPersonalizedExercises(_difficulty!);
      for (final category in categories) {
        _catalog[category] =
            exercises.where((e) => e.category == category).toList();
        _selected.putIfAbsent(category, () => <int>{});
      }
    } catch (e) {
      log('Erro ao carregar exercícios personalizados: $e');
      _error = 'Não foi possível carregar os exercícios. Tente novamente.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Marca/desmarca um exercício respeitando a quota da categoria.
  void toggle(ExerciseCategory category, int exerciseId) {
    final selection = _selected.putIfAbsent(category, () => <int>{});

    if (selection.contains(exerciseId)) {
      selection.remove(exerciseId);
    } else if (selection.length < quotaFor(category)) {
      selection.add(exerciseId);
    }
    notifyListeners();
  }

  /// Monta a rotina final (ordenada por categoria) e inicia o player,
  /// delegando a execução ao [PhysicalExercisesViewModel].
  void startRoutine(
    PhysicalExercisesViewModel physicalViewModel,
    BuildContext context,
  ) {
    final routine = <Exercise>[];
    for (final category in categories) {
      final ids = _selected[category] ?? const {};
      routine.addAll(optionsFor(category).where((e) => ids.contains(e.id)));
    }

    if (routine.isEmpty) {
      log('Rotina personalizada vazia; nada a iniciar.');
      return;
    }

    physicalViewModel.loadPrebuiltRoutine(routine);
    context.go(
      '${PhysicalExerciseRoutes.customExercises}/$_difficulty/${routine.first.id}',
    );
  }
}
