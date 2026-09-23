import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../screens/product_detail_screen.dart';
import 'add_to_cart_button.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(product.id);
    final outOfStock = product.stock == 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.imageEmoji, style: const TextStyle(fontSize: 40)),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : null,
                    ),
                    onPressed: () => ref.read(favoritesProvider.notifier).toggle(product.id),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(product.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${product.price.toStringAsFixed(2)} €',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AddToCartButton(
                    filled: true,
                    onPressed: outOfStock
                        ? null
                        : () {
                            ref.read(cartProvider.notifier).addProduct(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} ajouté au panier'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                    child: const Icon(Icons.add_shopping_cart, size: 18),
                  ),
                ],
              ),
              if (outOfStock)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Rupture de stock',
                      style: TextStyle(color: Colors.redAccent[700], fontSize: 11)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
