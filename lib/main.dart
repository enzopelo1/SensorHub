import 'package:flutter/cupertino.dart';

import 'router.dart';

// Point d'entrée de l'application : la première fonction exécutée.
void main() {
  runApp(const MainApp());
}

// StatelessWidget = widget "figé", sans mémoire interne.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      routerConfig: router,
    );
  }
}
