import 'package:artriapp/models/index.dart';
import 'package:artriapp/utils/enums/index.dart';
import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/index.dart';
import 'package:artriapp/views/physical_exercise/widgets/index.dart';
import 'package:artriapp/views/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomExercisesSelection extends StatefulWidget {
  const CustomExercisesSelection({super.key});

  @override
  State<CustomExercisesSelection> createState() =>
      _CustomExercisesSelectionState();
}

class _CustomExercisesSelectionState extends State<CustomExercisesSelection> {
  final PageController _pageController = PageController();
  int _index = 0;
  bool _orientationsShown = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _handleBegin(CustomExercisesViewModel viewModel) {
    if (!_orientationsShown) {
      setState(() => _orientationsShown = true);
      showDialog(
        context: context,
        builder: (context) => const OrientationsDialog(),
      );
      return;
    }

    final physicalViewModel = context.read<PhysicalExercisesViewModel>();
    viewModel.startRoutine(physicalViewModel, context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomExercisesViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Text(
                  viewModel.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    color: AppColors.darkGreen,
                  ),
                ),
                CustomSolidButton(
                  text: 'Tentar novamente',
                  onPressed: viewModel.loadCatalog,
                  color: AppColors.darkGreen,
                ),
              ],
            ),
          );
        }

        final categories = viewModel.categories;
        if (categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _CategoryPage(
                  category: categories[i],
                  viewModel: viewModel,
                ),
              ),
            ),
            _buildActionButton(viewModel, categories),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    CustomExercisesViewModel viewModel,
    List<ExerciseCategory> categories,
  ) {
    final category = categories[_index];
    final isLast = _index == categories.length - 1;
    final enabled = viewModel.isQuotaMet(category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CustomSolidButton(
        text: isLast ? 'COMEÇAR' : 'PRÓXIMO',
        onPressed: enabled
            ? () => isLast ? _handleBegin(viewModel) : _goToNext()
            : () {},
        gradientColors: enabled ? AppGradients.greenGradient : null,
        color: enabled ? null : AppColors.lightBrown,
        textStyle: GoogleFonts.montserrat(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CategoryPage extends StatelessWidget {
  final ExerciseCategory category;
  final CustomExercisesViewModel viewModel;

  const _CategoryPage({required this.category, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final quota = viewModel.quotaFor(category);
    final options = viewModel.optionsFor(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          category.selectionPrompt(quota),
          style: GoogleFonts.montserrat(
            fontSize: 22,
            color: AppColors.darkGreen,
          ),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final exercise = options[i];
                final selected = viewModel.isSelected(category, exercise.id);
                final atLimit = viewModel.selectedCount(category) >= quota;

                return _ExerciseOptionTile(
                  exercise: exercise,
                  selected: selected,
                  enabled: selected || !atLimit,
                  onToggle: () => viewModel.toggle(category, exercise.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseOptionTile extends StatelessWidget {
  final Exercise exercise;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  const _ExerciseOptionTile({
    required this.exercise,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return InkWell(
      onTap: enabled ? onToggle : null,
      child: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: width * 0.13,
            width: width * 0.13,
            decoration: BoxDecoration(
              color: AppColors.lightBrown,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.play_arrow, color: Colors.white, size: width * 0.08),
          ),
          Expanded(
            child: Text(
              exercise.name.split('-').first.trim(),
              style: GoogleFonts.montserrat(
                fontSize: 24,
                color: enabled ? AppColors.darkGreen : Colors.grey,
              ),
            ),
          ),
          Checkbox(
            value: selected,
            onChanged: enabled ? (_) => onToggle() : null,
            activeColor: AppColors.darkGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
