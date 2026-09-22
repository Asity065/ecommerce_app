import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));
    final isFavorite = ref.watch(favoritesProvider).contains(widget.productId);

    if (product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final outOfStock = product.stock == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : null,
            ),
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(product.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(product.imageEmoji, style: const TextStyle(fontSize: 96))),
            const SizedBox(height: 20),
            Text(product.category,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('${product.rating} · ${product.stock} en stock'),
              ],
            ),
            const SizedBox(height: 16),
            Text(product.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text(
              '${product.price.toStringAsFixed(2)} €',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!outOfStock)
              Row(
                children: [
                  const Text('Quantité :'),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text('$_quantity', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _quantity < product.stock
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              )
            else
              const Text('Rupture de stock', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Ajouter au panier'),
              onPressed: outOfStock
                  ? null
                  : () {
                      ref
                          .read(cartProvider.notifier)
                          .addProduct(product, quantity: _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$_quantity × ${product.name} ajouté(s) au panier')),
                      );
                    },
            ),
          ),
        ),
      ),
    );
  }
}
