// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Sensor _$SensorFromJson(Map<String, dynamic> json) => _Sensor(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  value: (json['value'] as num).toDouble(),
  unit: json['unit'] as String,
  isOnline: json['isOnline'] as bool,
);

Map<String, dynamic> _$SensorToJson(_Sensor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'value': instance.value,
  'unit': instance.unit,
  'isOnline': instance.isOnline,
};
