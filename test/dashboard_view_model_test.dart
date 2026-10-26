import 'package:flutter_test/flutter_test.dart';
import 'package:sensorhub/repositories/fake_sensor_repository.dart';
import 'package:sensorhub/view_models/async_state.dart';
import 'package:sensorhub/view_models/dashboard_view_model.dart';

const _fast = Duration(milliseconds: 10);

void main() {
  test('un listener observe Loading puis Content', () async {
    final viewModel = DashboardViewModel(
      repository: FakeSensorRepository(delay: _fast),
    );
    final seen = <Type>[];
    viewModel.addListener(() => seen.add(viewModel.state.runtimeType));

    await viewModel.load();

    expect(seen.first.toString(), startsWith('Loading'));
    expect(seen.last.toString(), startsWith('Content'));
  });

  test(
    'premier chargement en erreur puis retry avec le même ViewModel',
    () async {
      final repository = FakeSensorRepository(delay: _fast, failingCalls: {1});
      final viewModel = DashboardViewModel(repository: repository);

      await viewModel.load();
      expect(viewModel.state, isA<Failure>());

      await viewModel.load(); // même instance
      expect(viewModel.state, isA<Content>());
      expect(repository.loadCount, 2);
    },
  );

  test('des actualisations rapides ne lancent qu un seul chargement', () async {
    final repository = FakeSensorRepository(
      delay: const Duration(milliseconds: 100),
    );
    final viewModel = DashboardViewModel(repository: repository);

    final futures = [viewModel.load(), viewModel.load(), viewModel.load()];
    expect(viewModel.isLoading, isTrue);
    await Future.wait(futures);

    expect(repository.loadCount, 1);
    expect(viewModel.isLoading, isFalse);
  });

  test('une nouvelle actualisation est possible après la fin', () async {
    final repository = FakeSensorRepository(delay: _fast);
    final viewModel = DashboardViewModel(repository: repository);

    await viewModel.load();
    await viewModel.load();

    expect(repository.loadCount, 2);
  });

  test(
    'dernière actualisation : absente, mise à jour, conservée en erreur',
    () async {
      var clock = DateTime(2026, 1, 1, 10, 0, 0);
      final viewModel = DashboardViewModel(
        repository: FakeSensorRepository(delay: _fast, failingCalls: {1, 3}),
        now: () => clock,
      );

      expect(viewModel.lastSuccessAt, isNull);

      await viewModel.load(); // appel 1 : erreur
      expect(viewModel.lastSuccessAt, isNull);

      clock = DateTime(2026, 1, 1, 10, 0, 5);
      await viewModel.load(); // appel 2 : succès
      expect(viewModel.lastSuccessAt, DateTime(2026, 1, 1, 10, 0, 5));

      clock = DateTime(2026, 1, 1, 10, 0, 20);
      await viewModel.load(); // appel 3 : erreur, l'heure du succès est gardée
      expect(viewModel.state, isA<Failure>());
      expect(viewModel.lastSuccessAt, DateTime(2026, 1, 1, 10, 0, 5));

      clock = DateTime(2026, 1, 1, 10, 0, 30);
      await viewModel.load(); // appel 4 : nouveau succès
      expect(viewModel.lastSuccessAt, DateTime(2026, 1, 1, 10, 0, 30));
    },
  );

  test(
    'bonus : données anciennes après le seuil, fraîches après un succès',
    () async {
      var clock = DateTime(2026, 1, 1, 10, 0, 0);
      final viewModel = DashboardViewModel(
        repository: FakeSensorRepository(delay: _fast),
        now: () => clock,
        staleAfter: const Duration(seconds: 10),
      );

      expect(viewModel.isStale, isFalse); // aucun succès encore

      await viewModel.load();
      clock = DateTime(2026, 1, 1, 10, 0, 5);
      expect(viewModel.isStale, isFalse);

      clock = DateTime(2026, 1, 1, 10, 0, 11);
      expect(viewModel.isStale, isTrue);

      await viewModel.load();
      expect(viewModel.isStale, isFalse);
    },
  );
}
