import '../models/sensor.dart';

// Une simple classe Dart : elle prépare les données dont l'écran a besoin.
class DashboardViewModel {
  // Liste privée : seule cette classe peut la modifier.
  final List<Sensor> _sensors = const [
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

  // Version lecture seule de la liste, pour que la View puisse la lire
  // sans pouvoir y ajouter ou enlever des capteurs.
  List<Sensor> get sensors => List.unmodifiable(_sensors);

  // Nombre total de capteurs.
  int get sensorCount => _sensors.length;

  // Nombre de capteurs en ligne.
  int get onlineCount => _sensors.where((sensor) => sensor.isOnline).length;

  // Vrai si au moins un capteur est hors ligne.
  bool get hasOfflineSensors => _sensors.any((sensor) => !sensor.isOnline);
}
