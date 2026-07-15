import 'package:artriapp/utils/enums/index.dart';
import 'package:artriapp/view_models/diary_view_model.dart';
import 'package:artriapp/views/user_diary/widgets/user_level_selection.dart';
import 'package:artriapp/views/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Tela de registro do nível de fadiga do diário. Reaproveita o
/// [UserLevelSelection] e adiciona a persistência via
/// [DiaryViewModel.enviarRelatorioFadiga].
class FatigueSelectionPage extends StatefulWidget {
  const FatigueSelectionPage({super.key});

  @override
  State<FatigueSelectionPage> createState() => _FatigueSelectionPageState();
}

class _FatigueSelectionPageState extends State<FatigueSelectionPage> {
  int? _nivel;
  bool _isSaving = false;

  Future<void> _salvar() async {
    if (_isSaving) return;

    if (_nivel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o seu nível de fadiga.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final sucesso = await context
        .read<DiaryViewModel>()
        .enviarRelatorioFadiga(nivel: _nivel!);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado com sucesso!')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao comunicar com o servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UserLevelSelection(
          title: 'Fadiga',
          tooltipMessage:
              'É um cansaço intenso e constante e falta de energia, que não '
              'melhora mesmo após descanso e pode atrapalhar nas atividades do '
              'dia a dia',
          description: 'De 0 a 10, como está seu nível de fadiga hoje?',
          showButtons: false,
          selectedLevel: _nivel,
          onLevelSelected: (value) => _nivel = value,
        ),
        Column(
          children: [
            const Gap(32),
            ConfirmationButtons(
              onButtonClicked: (action) =>
                  action == ConfirmationAction.canceled ? context.pop() : _salvar(),
            ),
          ],
        ),
      ],
    );
  }
}
