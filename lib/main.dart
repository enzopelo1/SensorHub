import 'package:flutter/cupertino.dart';

import 'repositories/fake_sensor_repository.dart';
import 'router.dart';
import 'view_models/dashboard_view_model.dart';

Future<void> main() async {
  final repository = FakeSensorRepository();
  final viewModel = DashboardViewModel(repository: repository);

  await viewModel.load();

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
