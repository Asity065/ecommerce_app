import 'package:ecommerce_riverpod/providers/favorites_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_services.dart';

void main() {
  group('FavoritesNotifier', () {
    test('loads previously saved favorites from storage on creation', () async {
      final storage = FakeFavoritesStorage(initial: {'p1', 'p3'});
      final notifier = FavoritesNotifier(storage);

      // Le chargement initial est async (voir _loadFromStorage).
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, {'p1', 'p3'});
    });

    test('toggle adds an id that is not yet a favorite, and persists it', () async {
      final storage = FakeFavoritesStorage();
      final notifier = FavoritesNotifier(storage);
      await Future<void>.delayed(Duration.zero);

      notifier.toggle('p1');
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, {'p1'});
      expect(notifier.isFavorite('p1'), isTrue);
      expect(storage.saveCallCount, 1);
    });

    test('toggle removes an id that is already a favorite, and persists it', () async {
      final storage = FakeFavoritesStorage(initial: {'p1'});
      final notifier = FavoritesNotifier(storage);
      await Future<void>.delayed(Duration.zero);

      notifier.toggle('p1');
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, isEmpty);
      expect(notifier.isFavorite('p1'), isFalse);
    });

    test('toggling two different ids keeps both', () async {
      final storage = FakeFavoritesStorage();
      final notifier = FavoritesNotifier(storage);
      await Future<void>.delayed(Duration.zero);

      notifier.toggle('p1');
      notifier.toggle('p2');

      expect(notifier.state, {'p1', 'p2'});
    });
  });
}
