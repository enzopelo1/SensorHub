import 'package:go_router/go_router.dart';

import 'models/sensor.dart';
import 'screens/sensor_detail_screen.dart';
import 'screens/sensor_list_screen.dart';
import 'view_models/dashboard_view_model.dart';

// Le ViewModel de l'écran liste, créé une seule fois ici.
final _dashboardViewModel = DashboardViewModel();

// La carte des écrans de l'app : à chaque adresse (path) correspond un écran.
final router = GoRouter(
  routes: [
    // Adresse de départ : la liste des capteurs.
    GoRoute(
      path: '/',
      builder: (context, state) =>
          SensorListScreen(viewModel: _dashboardViewModel),
    ),
    // Adresse du détail. Le capteur cliqué est envoyé via `extra`
    // (voir sensor_list_screen.dart) pour ne pas avoir à le rechercher.
    GoRoute(
      path: '/sensor',
      builder: (context, state) {
        final sensor = state.extra as Sensor;
        return SensorDetailScreen(sensor: sensor);
      },
    ),
  ],
);
