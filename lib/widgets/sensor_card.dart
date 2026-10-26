import 'package:flutter/cupertino.dart';

import '../models/sensor.dart';

// Widget dédié à l'affichage d'UN SEUL capteur.
// Reçoit la donnée en paramètre (le capteur à afficher) et ne fait qu'un affichage.
class SensorCard extends StatelessWidget {
  // Le capteur à afficher. "final" = assigné une fois, ne change plus.
  final Sensor sensor;

  // Fonction appelée au tap sur la carte (ouvre le détail du capteur).
  final VoidCallback onTap;

  const SensorCard({super.key, required this.sensor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Container avec un fond et une bordure arrondie, façon carte iOS.
    // Quand le capteur est hors ligne, on grise légèrement le fond pour
    // que ça se voit tout de suite dans la liste.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sensor.isOnline
              ? CupertinoColors.secondarySystemBackground
              : CupertinoColors.systemGrey4,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icône changeant de forme et de couleur selon le statut du capteur.
            Icon(
              sensor.isOnline
                  ? CupertinoIcons.wifi
                  : CupertinoIcons.wifi_exclamationmark,
              color: sensor.isOnline
                  ? CupertinoColors.activeGreen
                  : CupertinoColors.destructiveRed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${sensor.name} (${sensor.type})'),
                  Text(
                    '${sensor.value} ${sensor.unit}',
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
