import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: AsyncValueWidget<List<Product>>(
        value: productsAsync,
        onRetry: () => ref.invalidate(productsProvider),
        data: (products) {
          final favorites = products.where((p) => favoriteIds.contains(p.id)).toList();
          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Aucun favori pour le moment'),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) => ProductCard(product: favorites[index]),
          );
        },
      ),
    );
  }
}
