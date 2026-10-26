import 'package:flutter/cupertino.dart';

import '../models/sensor.dart';
import '../repositories/sensor_repository.dart';
import '../view_models/async_state.dart';
import '../view_models/sensor_detail_view_model.dart';

// Écran affichant le détail d'un capteur, ouvert depuis la liste.
// Il ne reçoit que l'id : le ViewModel (créé ici, donc lié à la vie de
// l'écran) charge le capteur et l'écran affiche son état.
class SensorDetailScreen extends StatefulWidget {
  const SensorDetailScreen({
    super.key,
    required this.id,
    required this.repository,
  });

  final String id;
  final SensorRepository repository;

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  late final SensorDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SensorDetailViewModel(
      repository: widget.repository,
      id: widget.id,
    )..load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(switch (_viewModel.state) {
              Content<Sensor>(:final data) => data.name,
              _ => 'Capteur',
            }),
          ),
          child: SafeArea(
            child: switch (_viewModel.state) {
              Loading<Sensor>() => const Center(
                child: CupertinoActivityIndicator(),
              ),
              Content<Sensor>(:final data) => _SensorDetail(sensor: data),
              Failure<Sensor>(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Erreur : $message', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      CupertinoButton.filled(
                        onPressed: _viewModel.load,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            },
          ),
        );
      },
    );
  }
}

class _SensorDetail extends StatelessWidget {
  const _SensorDetail({required this.sensor});

  final Sensor sensor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sensor.type,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}
