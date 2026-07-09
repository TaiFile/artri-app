import 'package:artriapp/utils/enums/exercise_category.dart';
import 'package:artriapp/utils/enums/exercise_difficulty.dart';

const Map<ExerciseDifficulty, Map<ExerciseCategory, int>> customExerciseQuotas = {
  ExerciseDifficulty.easy: {
    ExerciseCategory.mobilityLegs: 2,
    ExerciseCategory.mobilityArms: 2,
    ExerciseCategory.mobilityTrunk: 1,
    ExerciseCategory.warmup: 2,
    ExerciseCategory.legs: 2,
    ExerciseCategory.arms: 2,
    ExerciseCategory.trunk: 1,
    ExerciseCategory.stretching: 3,
  },
  ExerciseDifficulty.medium: {
    ExerciseCategory.mobilityLegs: 2,
    ExerciseCategory.mobilityArms: 2,
    ExerciseCategory.mobilityTrunk: 1,
    ExerciseCategory.warmup: 3,
    ExerciseCategory.legs: 3,
    ExerciseCategory.arms: 3,
    ExerciseCategory.trunk: 1,
    ExerciseCategory.stretching: 3,
  },
  ExerciseDifficulty.hard: {
    ExerciseCategory.mobilityLegs: 1,
    ExerciseCategory.mobilityArms: 1,
    ExerciseCategory.mobilityTrunk: 1,
    ExerciseCategory.warmup: 3,
    ExerciseCategory.legs: 3,
    ExerciseCategory.arms: 3,
    ExerciseCategory.trunk: 2,
    ExerciseCategory.stretching: 3,
  },
};

List<ExerciseCategory> quotaOrderFor(ExerciseDifficulty difficulty) =>
    customExerciseQuotas[difficulty]!.keys.toList();
