import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/remedy_view_model.dart';
import 'package:artriapp/views/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RemedyPage extends StatefulWidget {
  const RemedyPage({super.key});

  @override
  State<RemedyPage> createState() => _RemedyPageState();
}

class _RemedyPageState extends State<RemedyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemedyViewModel>().fetchRemedies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<RemedyViewModel>(
        builder: (context, model, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MEDICAMENTOS',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.darkGreen,
                        size: 30,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => ChangeNotifierProvider.value(
                            value: model,
                            child: const _AddRemedySheet(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Checklist diário de tratamento'),
              ),
              const SizedBox(height: 20),
              if (model.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (model.error != null && model.remedies.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        model.error!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else if (model.remedies.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('Nenhum medicamento cadastrado.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: model.remedies.length,
                    itemBuilder: (context, index) {
                      final remedy = model.remedies[index];
                      final isPending = model.isPendingConfirmation(remedy.id);
                      final isConfirming = model.isConfirming(remedy.id);
                      final isTakenToday = model.isTakenToday(remedy.id);
                      final isHighlighted = isPending || isTakenToday;

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          onTap: isTakenToday
                              ? null
                              : () => model.togglePendingConfirmation(remedy.id),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isHighlighted
                                  ? AppColors.darkGreen
                                  : AppColors.darkGreenSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medication_liquid_sharp,
                              color: isHighlighted
                                  ? Colors.white
                                  : AppColors.darkGreen,
                            ),
                          ),
                          title: Text(
                            remedy.name,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              decoration: isTakenToday
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${remedy.quantity} un. às ${remedy.hour}',
                          ),
                          trailing: isConfirming
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  isTakenToday
                                      ? Icons.check_circle
                                      : isPending
                                          ? Icons.check_circle_outline
                                          : Icons.radio_button_unchecked,
                                  color: isHighlighted
                                      ? AppColors.darkGreen
                                      : Colors.grey,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              if (!model.isLoading && model.remedies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: CustomSolidButton(
                    text: 'Salvar',
                    fontSize: 20,
                    gradientColors: AppGradients.greenGradient,
                    onPressed: () => _handleSave(context, model),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, RemedyViewModel model) async {
    final hasPending = model.remedies.any((r) => model.isPendingConfirmation(r.id));

    if (!hasPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um medicamento para confirmar.')),
      );
      return;
    }

    final sucesso = await model.confirmPending();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? 'Guardado com sucesso!' : 'Erro ao comunicar com o servidor.',
        ),
      ),
    );
  }
}

class _AddRemedySheet extends StatefulWidget {
  const _AddRemedySheet();

  @override
  State<_AddRemedySheet> createState() => _AddRemedySheetState();
}

class _AddRemedySheetState extends State<_AddRemedySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String get _hourText =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final model = context.read<RemedyViewModel>();
    final success = await model.createRemedy(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      hour: _hourText,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = model.error ?? 'Não foi possível salvar o medicamento.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<RemedyViewModel>().isSaving;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Novo Medicamento',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do remédio',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Instruções de uso',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Informe as instruções'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                return (parsed == null || parsed <= 0)
                    ? 'Informe uma quantidade válida'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _pickTime,
              child: Text('Horário: $_hourText'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Salvar',
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
