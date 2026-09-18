import 'package:flutter/cupertino.dart';

import '../models/sensor.dart';

// Écran affichant le détail d'un capteur, ouvert depuis la liste.
class SensorDetailScreen extends StatelessWidget {
  final Sensor sensor;

  const SensorDetailScreen({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(sensor.name),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sensor.type,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${sensor.value} ${sensor.unit}',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    sensor.isOnline
                        ? CupertinoIcons.wifi
                        : CupertinoIcons.wifi_exclamationmark,
                    color: sensor.isOnline
                        ? CupertinoColors.activeGreen
                        : CupertinoColors.destructiveRed,
                  ),
                  const SizedBox(width: 8),
                  Text(sensor.isOnline ? 'En ligne' : 'Hors ligne'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
