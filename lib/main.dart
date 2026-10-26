import 'package:flutter/cupertino.dart';

import 'repositories/fake_sensor_repository.dart';
import 'router.dart';
import 'view_models/dashboard_view_model.dart';

// Scénario de démonstration, choisi au lancement :
//   flutter run --dart-define=SCENARIO=demo
// - normal (défaut) : tout réussit après 1 s.
// - retry : le 1er chargement échoue, le 2e réussit.
// - demo  : réponses lentes (4 s), les appels 1 et 3 échouent
//           (erreur au début, puis erreur après un succès).
// - stale : tout réussit, seuil "données anciennes" ramené à 10 s.
const _scenario = String.fromEnvironment('SCENARIO', defaultValue: 'normal');

FakeSensorRepository _buildRepository() => switch (_scenario) {
      'retry' => FakeSensorRepository(failingCalls: {1}),
      'demo' => FakeSensorRepository(
          delay: const Duration(seconds: 4),
          failingCalls: {1, 3},
        ),
      _ => FakeSensorRepository(),
    };

void main() {
  final viewModel = DashboardViewModel(
    repository: _buildRepository(),
    staleAfter: _scenario == 'stale'
        ? const Duration(seconds: 10)
        : const Duration(seconds: 30),
  );

  // Plus de "await" avant runApp : l'écran écoute le ViewModel, il affiche
  // donc lui-même le chargement (utile pour voir une réponse lente).
  viewModel.load();

  runApp(MainApp(viewModel: viewModel));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      routerConfig: createRouter(viewModel),
    );
  }
}
