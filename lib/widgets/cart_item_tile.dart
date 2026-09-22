import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartItemTile extends ConsumerWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => notifier.removeProduct(item.product.id),
      child: ListTile(
        leading: Text(item.product.imageEmoji, style: const TextStyle(fontSize: 32)),
        title: Text(item.product.name),
        subtitle: Text('${item.product.price.toStringAsFixed(2)} € / unité'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => notifier.decrementQuantity(item.product.id),
            ),
            Text('${item.quantity}', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => notifier.incrementQuantity(item.product.id),
            ),
          ],
        ),
      ),
    );
  }
}
