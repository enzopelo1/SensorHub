import 'package:go_router/go_router.dart';

import 'models/sensor.dart';
import 'screens/sensor_detail_screen.dart';
import 'screens/sensor_list_screen.dart';
import 'view_models/dashboard_view_model.dart';

// Une fonction plutôt qu'une variable globale figée : le ViewModel doit être
// créé et chargé (async) avant d'exister, ce qui ne peut plus se faire ici.
// C'est main.dart qui le crée et l'envoie à createRouter().
GoRouter createRouter(DashboardViewModel dashboardViewModel) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            SensorListScreen(viewModel: dashboardViewModel),
      ),
      GoRoute(
        path: '/sensor',
        builder: (context, state) {
          final sensor = state.extra as Sensor;
          return SensorDetailScreen(sensor: sensor);
        },
      ),
    ],
  );
}
