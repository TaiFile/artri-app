enum ExerciseCategory {
  mobilityLegs,
  mobilityArms,
  mobilityTrunk,
  warmup,
  legs,
  arms,
  trunk,
  stretching;

  String get apiKey {
    switch (this) {
      case ExerciseCategory.mobilityLegs:
        return 'mobility_legs';
      case ExerciseCategory.mobilityArms:
        return 'mobility_arms';
      case ExerciseCategory.mobilityTrunk:
        return 'mobility_trunk';
      case ExerciseCategory.warmup:
        return 'warmup';
      case ExerciseCategory.legs:
        return 'legs';
      case ExerciseCategory.arms:
        return 'arms';
      case ExerciseCategory.trunk:
        return 'trunk';
      case ExerciseCategory.stretching:
        return 'stretching';
    }
  }

  static ExerciseCategory? fromApiKey(String? key) {
    for (final c in ExerciseCategory.values) {
      if (c.apiKey == key) return c;
    }
    return null;
  }

  String selectionPrompt(int count) {
    switch (this) {
      case ExerciseCategory.mobilityLegs:
        return 'Selecione $count exercícios de mobilidade para as pernas das opções abaixo:';
      case ExerciseCategory.mobilityArms:
        return 'Selecione $count exercícios de mobilidade para os braços das opções abaixo:';
      case ExerciseCategory.mobilityTrunk:
        return 'Selecione $count exercício de mobilidade para o tronco das opções abaixo:';
      case ExerciseCategory.warmup:
        return 'Selecione $count exercícios de aquecimento das opções abaixo:';
      case ExerciseCategory.legs:
        return 'Selecione $count exercícios para as pernas das opções abaixo:';
      case ExerciseCategory.arms:
        return 'Selecione $count exercícios para os braços das opções abaixo:';
      case ExerciseCategory.trunk:
        return 'Selecione $count exercício para o tronco das opções abaixo:';
      case ExerciseCategory.stretching:
        return 'Selecione $count exercícios de alongamento das opções abaixo:';
    }
  }
}
