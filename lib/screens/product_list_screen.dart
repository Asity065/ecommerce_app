import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/product_providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/filter_sort_bar.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        bottom: const FilterSortBar(),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(productsProvider.future),
        child: AsyncValueWidget<List<Product>>(
          value: filteredProductsAsync,
          onRetry: () => ref.invalidate(productsProvider),
          data: (products) {
            if (products.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Aucun produit ne correspond à votre recherche.')),
                ],
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
              itemCount: products.length,
              itemBuilder: (context, index) => ProductCard(product: products[index]),
            );
          },
        ),
      ),
    );
  }
}
