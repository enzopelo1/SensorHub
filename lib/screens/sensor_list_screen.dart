import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../models/sensor.dart';
import '../view_models/async_state.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/sensor_card.dart';

// StatefulWidget uniquement pour le Timer : l'ancienneté des données dépend
// du temps qui passe, pas d'un changement d'état du ViewModel.
class SensorListScreen extends StatefulWidget {
  const SensorListScreen({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  State<SensorListScreen> createState() => _SensorListScreenState();
}

class _SensorListScreenState extends State<SensorListScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Redessine chaque seconde pour que l'indicateur "données anciennes"
    // apparaisse même sans nouvel état publié.
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    // ListenableBuilder : se reconstruit à chaque notifyListeners().
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('SensorHub'),
            // Bouton désactivé (onPressed null) pendant un chargement :
            // empêche les actualisations qui se superposent côté interface.
            // Le ViewModel les ignore aussi de toute façon.
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: viewModel.isLoading ? null : viewModel.load,
              child: viewModel.isLoading
                  ? const CupertinoActivityIndicator()
                  : const Icon(CupertinoIcons.refresh),
            ),
          ),
          // Switch exhaustif sur la hiérarchie sealed : les 3 cas doivent
          // être couverts, sinon le compilateur refuse de compiler.
          child: SafeArea(
            child: Column(
              children: [
                _LastRefreshBanner(viewModel: viewModel),
                Expanded(child: _body(context, viewModel)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, DashboardViewModel viewModel) {
    return switch (viewModel.state) {
      Loading<Sensor>() => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 8),
              Text('Actualisation en cours…'),
            ],
          ),
        ),
      Content<Sensor>(:final values) => Column(
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
                    // On passe uniquement l'id du capteur dans l'URL,
                    // pas l'objet entier.
                    onTap: () => context.push('/sensor/${sensor.id}'),
                  );
                },
              ),
            ),
          ],
        ),
      Failure<Sensor>(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Erreur : $message',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                CupertinoButton.filled(
                  onPressed: viewModel.load,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
    };
  }
}

// Heure de la dernière réussite, visible dans tous les états (donc aussi
// après une erreur). Passe en orange quand les données sont anciennes.
class _LastRefreshBanner extends StatelessWidget {
  const _LastRefreshBanner({required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final stale = viewModel.isStale;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        stale
            ? '${viewModel.lastRefreshLabel} — données anciennes'
            : viewModel.lastRefreshLabel,
        style: TextStyle(
          fontSize: 13,
          color: stale
              ? CupertinoColors.systemOrange
              : CupertinoColors.secondaryLabel,
        ),
      ),
    );
  }
}
