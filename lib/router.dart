import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'models/sensor.dart';
import 'screens/sensor_detail_screen.dart';
import 'screens/sensor_list_screen.dart';
import 'view_models/async_state.dart';
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
        // ":id" : segment capturé par go_router, accessible via
        // state.pathParameters['id']. Exemple d'URL réelle : /sensor/2
        path: '/sensor/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;

          // On cherche le capteur dans l'état actuel du ViewModel : ça
          // n'est possible que si l'état est Content.
          final currentState = dashboardViewModel.state;

          final sensor = switch (currentState) {
            Content<Sensor>(:final values) =>
              values.where((s) => s.id == id).firstOrNull,
            _ => null,
          };

          // Id invalide ou état pas encore Content : écran d'erreur
          // simple plutôt que de planter l'application.
          if (sensor == null) {
            return const CupertinoPageScaffold(
              child: Center(child: Text('Capteur introuvable')),
            );
          }

          return SensorDetailScreen(sensor: sensor);
        },
      ),
    ],
  );
}
