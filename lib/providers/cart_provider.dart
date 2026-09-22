import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product, {int quantity = 1}) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final existing = state[index];
      final maxQuantity = product.stock == 0 ? 1 : product.stock;
      final int newQuantity =
          (existing.quantity + quantity).clamp(1, maxQuantity).toInt();
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) existing.copyWith(quantity: newQuantity) else state[i]
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId) item.copyWith(quantity: quantity) else item
    ];
  }

  void incrementQuantity(String productId) {
    final item = state.where((i) => i.product.id == productId).firstOrNull;
    if (item == null) return;
    final maxStock = item.product.stock;
    if (maxStock != 0 && item.quantity >= maxStock) return;
    updateQuantity(productId, item.quantity + 1);
  }

  void decrementQuantity(String productId) {
    final item = state.where((i) => i.product.id == productId).firstOrNull;
    if (item == null) return;
    updateQuantity(productId, item.quantity - 1);
  }

  void clear() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.subtotal);
});

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
