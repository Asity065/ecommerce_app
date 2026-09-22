import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import 'filter_sort_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return const ProductService();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.fetchProducts();
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final sort = ref.watch(sortOptionProvider);

  return productsAsync.whenData((products) {
    var result = products.where((p) {
      final matchesQuery =
          query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'Tous' || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();

    switch (sort) {
      case SortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.none:
        break;
    }

    return result;
  });
});

final categoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.whenData((products) {
    final categories = products.map((p) => p.category).toSet().toList()..sort();
    return ['Tous', ...categories];
  });
});

final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.maybeWhen(
    data: (products) => products.where((p) => p.id == id).firstOrNull,
    orElse: () => null,
  );
});

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
