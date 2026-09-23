import 'package:ecommerce_riverpod/providers/filter_sort_provider.dart';
import 'package:ecommerce_riverpod/providers/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_services.dart';

void main() {
  group('filteredProductsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // On remplace le vrai service (qui charge un asset JSON) par
          // un faux repository synchrone, indépendant de la plateforme.
          productServiceProvider.overrideWithValue(FakeProductRepository()),
        ],
      );
      addTearDown(container.dispose);
    });

    Future<void> waitForProducts() => container.read(productsProvider.future);

    test('returns every product with no filter applied', () async {
      await waitForProducts();
      final result = container.read(filteredProductsProvider);

      expect(result.hasValue, isTrue);
      expect(result.value!.length, 10);
    });

    test('search query filters by (case-insensitive) product name', () async {
      await waitForProducts();
      container.read(searchQueryProvider.notifier).state = 'casque';

      final result = container.read(filteredProductsProvider).value!;

      expect(result.length, 1);
      expect(result.first.name, contains('Casque'));
    });

    test('category filter narrows down the results', () async {
      await waitForProducts();
      container.read(selectedCategoryProvider.notifier).state = 'Audio';

      final result = container.read(filteredProductsProvider).value!;

      expect(result, isNotEmpty);
      expect(result.every((p) => p.category == 'Audio'), isTrue);
    });

    test('sortOption priceAsc orders products from cheapest to most expensive', () async {
      await waitForProducts();
      container.read(sortOptionProvider.notifier).state = SortOption.priceAsc;

      final result = container.read(filteredProductsProvider).value!;
      final prices = result.map((p) => p.price).toList();
      final sortedPrices = [...prices]..sort();

      expect(prices, sortedPrices);
    });

    test('sortOption ratingDesc orders products from best to worst rated', () async {
      await waitForProducts();
      container.read(sortOptionProvider.notifier).state = SortOption.ratingDesc;

      final result = container.read(filteredProductsProvider).value!;
      final ratings = result.map((p) => p.rating).toList();
      final sortedDesc = [...ratings]..sort((a, b) => b.compareTo(a));

      expect(ratings, sortedDesc);
    });

    test('search and category filters combine together', () async {
      await waitForProducts();
      container.read(selectedCategoryProvider.notifier).state = 'Électronique';
      container.read(searchQueryProvider.notifier).state = 'montre';

      final result = container.read(filteredProductsProvider).value!;

      expect(result.length, 1);
      expect(result.first.category, 'Électronique');
    });

    test('propagates an error from the repository as an AsyncError', () async {
      final errorContainer = ProviderContainer(
        overrides: [
          productServiceProvider.overrideWithValue(FakeProductRepository(throwOnFetch: true)),
        ],
      );
      addTearDown(errorContainer.dispose);

      // On laisse le FutureProvider s'exécuter et échouer.
      try {
        await errorContainer.read(productsProvider.future);
      } catch (_) {
        // Attendu : le repository de test lève volontairement une erreur.
      }

      final result = errorContainer.read(filteredProductsProvider);
      expect(result.hasError, isTrue);
    });
  });
}
