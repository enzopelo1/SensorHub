import '../models/sensor.dart';

// Un contrat, pas une classe qu'on utilise directement : il dit juste
// "toute implémentation doit fournir fetchAll()", sans dire comment.
// Le ViewModel qui dépendra de ce contrat ne saura jamais si les données
// viennent d'une liste en mémoire, d'une API ou de MQTT.
abstract interface class SensorRepository {
  // Asynchrone (Future) car ça pourrait prendre du temps (appel réseau).
  Future<List<Sensor>> fetchAll();
}
