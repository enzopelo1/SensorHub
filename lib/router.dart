import 'package:go_router/go_router.dart';

import 'repositories/sensor_repository.dart';
import 'screens/sensor_detail_screen.dart';
import 'screens/sensor_list_screen.dart';
import 'view_models/dashboard_view_model.dart';

// Une fonction plutôt qu'une variable globale figée : main.dart crée le
// ViewModel et le repository, puis les envoie à createRouter().
GoRouter createRouter(
  DashboardViewModel dashboardViewModel,
  SensorRepository repository,
) {
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

          return SensorDetailScreen(id: id, repository: repository);
        },
      ),
    ],
  );
}
