import 'package:flutter/foundation.dart';

import '../models/sensor.dart';
import '../repositories/sensor_repository.dart';
import 'async_state.dart';

// "extends ChangeNotifier" : donne la capacité de notifier des observateurs
// quand l'état change, sans dépendre de widgets ni de BuildContext.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required SensorRepository repository,
    // Horloge injectable : permet de tester l'heure et la fraîcheur sans
    // attendre réellement.
    DateTime Function()? now,
    this.staleAfter = const Duration(seconds: 30),
  }) : _repository = repository,
       _now = now ?? DateTime.now;

  final SensorRepository _repository;
  final DateTime Function() _now;

  // Au-delà de cette durée sans succès, les données sont jugées anciennes.
  final Duration staleAfter;

  // Démarre à Loading : un chargement va suivre dès la création.
  AsyncState<List<Sensor>> _state = const Loading<List<Sensor>>();

  // Lecture publique uniquement : personne à l'extérieur ne peut
  // remplacer l'état directement, seule cette classe le peut via _setState.
  AsyncState<List<Sensor>> get state => _state;

  // Garde anti-superposition : placée dans le ViewModel car c'est lui qui
  // orchestre load() ; ainsi la règle tient quelle que soit la View, et
  // elle est testable sans widget.
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Heure du dernier chargement RÉUSSI. Jamais modifiée par une erreur.
  DateTime? _lastSuccessAt;
  DateTime? get lastSuccessAt => _lastSuccessAt;

  // Bonus : true si un succès existe mais date de plus de staleAfter.
  // Dépend de l'horloge : la View doit se redessiner périodiquement.
  bool get isStale {
    final at = _lastSuccessAt;
    if (at == null) return false;
    return _now().difference(at) > staleAfter;
  }

  // Seul endroit qui modifie _state, pour centraliser la notification.
  void _setState(AsyncState<List<Sensor>> value) {
    _state = value;
    // Prévient tous les listeners enregistrés (ex: la View) qu'il faut
    // se rafraîchir.
    notifyListeners();
  }

  // Si un chargement est déjà en cours, l'appel est ignoré.
  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;

    // Repasse en Loading à chaque appel, utile si load() est rappelée
    // pour rafraîchir (l'écran ne doit pas rester sur l'ancien état).
    _setState(const Loading<List<Sensor>>());

    // try/catch : intercepte l'erreur au lieu de laisser planter l'app.
    try {
      final sensors = await _repository.fetchAll();
      _lastSuccessAt = _now();
      _isLoading = false;
      _setState(Content<List<Sensor>>(sensors));
    } catch (error) {
      _isLoading = false;
      _setState(Failure<List<Sensor>>(error.toString()));
    }
  }
}
