import 'package:flutter/foundation.dart';

import '../models/sensor.dart';
import '../repositories/sensor_repository.dart';
import 'async_state.dart';

// "extends ChangeNotifier" : donne la capacité de notifier des observateurs
// quand l'état change, sans dépendre de widgets ni de BuildContext.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({required SensorRepository repository})
      : _repository = repository;

  final SensorRepository _repository;

  // Démarre à Loading : un chargement va suivre dès la création.
  AsyncState<Sensor> _state = const Loading<Sensor>();

  // Lecture publique uniquement : personne à l'extérieur ne peut
  // remplacer l'état directement, seule cette classe le peut via _setState.
  AsyncState<Sensor> get state => _state;

  // Seul endroit qui modifie _state, pour centraliser la notification.
  void _setState(AsyncState<Sensor> value) {
    _state = value;
    // Prévient tous les listeners enregistrés (ex: la View) qu'il faut
    // se rafraîchir.
    notifyListeners();
  }

  Future<void> load() async {
    // Repasse en Loading à chaque appel, utile si load() est rappelée
    // pour rafraîchir (l'écran ne doit pas rester sur l'ancien état).
    _setState(const Loading<Sensor>());

    // try/catch : intercepte l'erreur au lieu de laisser planter l'app.
    try {
      final sensors = await _repository.fetchAll();
      _setState(Content<Sensor>(sensors));
    } catch (error) {
      _setState(Failure<Sensor>(error.toString()));
    }
  }
}
