import 'package:freezed_annotation/freezed_annotation.dart';

// Fichiers générés automatiquement par build_runner (étape 3), ne pas éditer à la main.
part 'sensor.freezed.dart';
part 'sensor.g.dart';

// @freezed : demande à Freezed de générer une classe immutable (constructeur,
// copyWith, ==, toString...) à partir de cette déclaration.
@freezed
abstract class Sensor with _$Sensor {
  const factory Sensor({
    required String id,
    required String name,
    required String type,
    required double value,
    required String unit,
    required bool isOnline,
  }) = _Sensor;

  // Permet de créer un Sensor à partir de JSON (utile plus tard avec une API).
  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);
}
