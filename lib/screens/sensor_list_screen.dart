import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../view_models/dashboard_view_model.dart';
import '../widgets/sensor_card.dart';

// Écran listant tous les capteurs. Un tap sur une carte ouvre son détail.
class SensorListScreen extends StatelessWidget {
  const SensorListScreen({super.key, required this.viewModel});

  // Le ViewModel qui fournit les données à afficher.
  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final sensors = viewModel.sensors;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SensorHub'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Résumé calculé par le ViewModel : nombre de capteurs et
            // combien sont en ligne.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${viewModel.sensorCount} capteurs, ${viewModel.onlineCount} en ligne',
              ),
            ),
            // ListView.builder : liste défilante, ne construit que ce qui est visible.
            Expanded(
              
              child: ListView.builder(
                itemCount: sensors.length,
                itemBuilder: (context, index) {
                  final sensor = sensors[index];
                  return SensorCard(
                    sensor: sensor,
                    onTap: () => context.push('/sensor', extra: sensor),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
