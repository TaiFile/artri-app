import 'package:flutter/material.dart';
import 'package:artriapp/models/api_responses/remedy.dart';
import 'package:artriapp/services/remedy_service.dart';

class RemedyViewModel extends ChangeNotifier {
  final RemedyService _service;

  RemedyViewModel(this._service);

  List<Remedy> _allRemedies = [];
  List<Remedy> get remedies => _allRemedies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  // Estado local da sessão para o fluxo de confirmação (tocar no remédio
  // pede confirmação; confirmar decrementa a quantidade no backend)
  final Set<int> _pendingConfirmation = {};
  final Set<int> _confirmingIds = {};
  final Set<int> _takenToday = {};

  bool isPendingConfirmation(int id) => _pendingConfirmation.contains(id);
  bool isConfirming(int id) => _confirmingIds.contains(id);
  bool isTakenToday(int id) => _takenToday.contains(id);

  void togglePendingConfirmation(int id) {
    if (_takenToday.contains(id)) return;
    if (_pendingConfirmation.contains(id)) {
      _pendingConfirmation.remove(id);
    } else {
      _pendingConfirmation.add(id);
    }
    notifyListeners();
  }

  Future<bool> confirmTaken(int id) async {
    final remedyIndex = _allRemedies.indexWhere((r) => r.id == id);
    if (remedyIndex == -1 || _confirmingIds.contains(id)) return true;

    _confirmingIds.add(id);
    _error = null;
    notifyListeners();

    try {
      final current = _allRemedies[remedyIndex];
      final newQuantity = current.quantity > 0 ? current.quantity - 1 : 0;
      final updated = await _service.updateQuantity(id: id, quantity: newQuantity);

      if (updated.quantity <= 0) {
        // Some do checklist assim que a quantidade zera, igual ao GET do backend
        _allRemedies = _allRemedies.where((r) => r.id != id).toList();
      } else {
        _allRemedies = [
          for (final r in _allRemedies) r.id == id ? updated : r,
        ];
      }
      _takenToday.add(id);
      _pendingConfirmation.remove(id);
      return true;
    } catch (e) {
      debugPrint('Erro ao confirmar medicamento: $e');
      _error = 'Não foi possível confirmar o medicamento.';
      return false;
    } finally {
      _confirmingIds.remove(id);
      notifyListeners();
    }
  }

  /// Confirma (salva) todos os medicamentos selecionados no checklist
  Future<bool> confirmPending() async {
    final ids = _pendingConfirmation.toList();
    if (ids.isEmpty) return false;

    var success = true;
    for (final id in ids) {
      final ok = await confirmTaken(id);
      success = success && ok;
    }
    return success;
  }

  Future<void> fetchRemedies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRemedies = await _service.getRemedies();
    } catch (e) {
      debugPrint('Erro ao buscar medicamentos: $e');
      _error = 'Não foi possível carregar seus medicamentos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRemedy({
    required String name,
    required String description,
    required int quantity,
    required String hour,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final remedy = await _service.createRemedy(
        name: name,
        description: description,
        quantity: quantity,
        hour: hour,
      );
      _allRemedies = [..._allRemedies, remedy];
      return true;
    } catch (e) {
      debugPrint('Erro ao criar medicamento: $e');
      _error = 'Não foi possível salvar o medicamento.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
