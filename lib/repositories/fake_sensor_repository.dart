import '../models/sensor.dart';
import 'sensor_repository.dart';

// "implements SensorRepository" : s'engage à respecter le contrat, donc à
// fournir une méthode fetchAll() avec la bonne signature.
class FakeSensorRepository implements SensorRepository {
  // Paramètres configurables pour simuler différents cas depuis l'extérieur
  // (ex: dans un test) sans modifier cette classe :
  // - delay : temps d'attente avant de répondre (simule un appel réseau).
  // - shouldThrow : si true, simule une erreur au lieu de renvoyer des données.
  // - sensors : données à renvoyer (sinon la liste par défaut ci-dessous).
  FakeSensorRepository({
    this.delay = const Duration(seconds: 1),
    this.shouldThrow = false,
    this.failingCalls = const {},
    List<Sensor>? sensors,
  }) : _sensors = sensors ?? _defaultSensors;

  final Duration delay;
  final bool shouldThrow;

  // Numéros d'appels (à partir de 1) qui échouent. Exemple : {1} = seul le
  // premier chargement échoue, {1, 3} = le 1er et le 3e échouent.
  final Set<int> failingCalls;
  final List<Sensor> _sensors;

  int _loadCount = 0;

  // Nombre de chargements réellement exécutés depuis la création du Fake.
  int get loadCount => _loadCount;

  // Les mêmes données qui étaient avant écrites en dur dans le ViewModel.
  static const _defaultSensors = [
    Sensor(
      id: '1',
      name: 'Salon',
      type: 'Température',
      value: 21.5,
      unit: '°C',
      isOnline: true,
    ),
    Sensor(
      id: '2',
      name: 'Chambre',
      type: 'Humidité',
      value: 48.0,
      unit: '%',
      isOnline: true,
    ),
    Sensor(
      id: '3',
      name: 'Garage',
      type: 'Température',
      value: 15.2,
      unit: '°C',
      isOnline: false,
    ),
  ];

  // @override : on redéfinit la méthode promise par le contrat.
  @override
  Future<List<Sensor>> fetchAll() async {
    // Compté dès le début de l'appel : sert à prouver combien de chargements
    // ont réellement été exécutés (observation uniquement).
    _loadCount++;
    final callNumber = _loadCount;

    // Met l'exécution en pause pour simuler la latence d'un vrai appel réseau.
    await Future.delayed(delay);

    if (shouldThrow || failingCalls.contains(callNumber)) {
      throw Exception('Erreur réseau simulée');
    }

    return _sensors;
  }
}
