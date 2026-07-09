import 'package:artriapp/routes/index.dart';
import 'package:artriapp/utils/enums/index.dart';
import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/index.dart';
import 'package:artriapp/views/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomExercisesIntro extends StatefulWidget {
  const CustomExercisesIntro({super.key});

  @override
  State<CustomExercisesIntro> createState() => _CustomExercisesIntroState();
}

class _CustomExercisesIntroState extends State<CustomExercisesIntro> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomExercisesViewModel>().loadCatalog();
    });
  }

  List<_PreviewItem> _previewItems(CustomExercisesViewModel vm) {
    final mobility = vm.quotaFor(ExerciseCategory.mobilityLegs) +
        vm.quotaFor(ExerciseCategory.mobilityArms) +
        vm.quotaFor(ExerciseCategory.mobilityTrunk);
    return [
      _PreviewItem(mobility, 'de', 'mobilidade'),
      _PreviewItem(vm.quotaFor(ExerciseCategory.warmup), 'de', 'aquecimento'),
      _PreviewItem(vm.quotaFor(ExerciseCategory.legs), 'para', 'as pernas'),
      _PreviewItem(vm.quotaFor(ExerciseCategory.arms), 'para', 'os braços'),
      _PreviewItem(vm.quotaFor(ExerciseCategory.trunk), 'para', 'o tronco'),
      _PreviewItem(
        vm.quotaFor(ExerciseCategory.stretching),
        'de',
        'alongamento',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomExercisesViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 24,
                  children: [
                    Text(
                      'Vamos começar a montar sua rotina de exercícios '
                      'personalizada de hoje! Clique para escolher os '
                      'exercícios indicados abaixo:',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    ..._previewItems(viewModel).map(
                      (item) => Row(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.edit_note,
                            size: 48,
                            color: AppColors.darkGreen,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  color: AppColors.darkGreen,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Escolha ${item.count} '
                                        'exercícios ${item.connector} ',
                                  ),
                                  TextSpan(
                                    text: item.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CustomSolidButton(
                text: 'COMEÇAR',
                onPressed: () => context.go(
                  '${PhysicalExerciseRoutes.customExercises}/'
                  '${viewModel.difficulty}/select',
                ),
                gradientColors: AppGradients.greenGradient,
                textStyle: GoogleFonts.montserrat(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PreviewItem {
  final int count;
  final String connector;
  final String label;
  _PreviewItem(this.count, this.connector, this.label);
}
