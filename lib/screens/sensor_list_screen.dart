import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../models/sensor.dart';
import '../view_models/async_state.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/sensor_card.dart';

class SensorListScreen extends StatelessWidget {
  const SensorListScreen({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SensorHub'),
      ),
      // Switch exhaustif sur la hiérarchie sealed : les 3 cas doivent
      // être couverts, sinon le compilateur refuse de compiler.
      child: switch (viewModel.state) {
        Loading<Sensor>() => const Center(
            child: CupertinoActivityIndicator(),
          ),

        Content<Sensor>(:final values) => SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '${values.length} capteurs, '
                    '${values.where((s) => s.isOnline).length} en ligne',
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: values.length,
                    itemBuilder: (context, index) {
                      final sensor = values[index];
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

        Failure<Sensor>(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erreur : $message',
                textAlign: TextAlign.center,
              ),
            ),
          ),
      },
    );
  }
}
