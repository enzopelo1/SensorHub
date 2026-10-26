import 'package:flutter/foundation.dart';

import '../models/sensor.dart';
import '../repositories/sensor_repository.dart';
import 'async_state.dart';

// ViewModel d'un seul capteur : la View lui donne un id, il demande ce
// capteur au repository et publie l'état du chargement.
class SensorDetailViewModel extends ChangeNotifier {
  SensorDetailViewModel({
    required SensorRepository repository,
    required this.id,
  }) : _repository = repository;

  final SensorRepository _repository;
  final String id;

  AsyncState<Sensor> _state = const Loading<Sensor>();
  AsyncState<Sensor> get state => _state;

  bool _isLoading = false;

  void _setState(AsyncState<Sensor> value) {
    _state = value;
    notifyListeners();
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _setState(const Loading<Sensor>());

    try {
      final sensor = await _repository.fetchById(id);
      _isLoading = false;
      _setState(Content<Sensor>(sensor));
    } catch (error) {
      _isLoading = false;
      _setState(Failure<Sensor>(error.toString()));
    }
  }
}
