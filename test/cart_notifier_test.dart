import 'package:ecommerce_riverpod/data/mock_products.dart';
import 'package:ecommerce_riverpod/providers/cart_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartNotifier', () {
    final product = mockProducts.first; // stock: 12
    final outOfStockProduct = mockProducts.firstWhere((p) => p.stock == 0);

    late CartNotifier notifier;

    setUp(() {
      notifier = CartNotifier();
    });

    test('starts empty', () {
      expect(notifier.state, isEmpty);
    });

    test('addProduct adds a new line with quantity 1 by default', () {
      notifier.addProduct(product);

      expect(notifier.state.length, 1);
      expect(notifier.state.first.product.id, product.id);
      expect(notifier.state.first.quantity, 1);
    });

    test('addProduct twice on the same product increments quantity instead of duplicating', () {
      notifier.addProduct(product);
      notifier.addProduct(product);

      expect(notifier.state.length, 1);
      expect(notifier.state.first.quantity, 2);
    });

    test('addProduct respects available stock as an upper bound', () {
      notifier.addProduct(product, quantity: product.stock + 10);

      expect(notifier.state.first.quantity, product.stock);
    });

    test('updateQuantity changes the quantity of an existing line', () {
      notifier.addProduct(product);
      notifier.updateQuantity(product.id, 5);

      expect(notifier.state.first.quantity, 5);
    });

    test('updateQuantity with 0 or less removes the line', () {
      notifier.addProduct(product);
      notifier.updateQuantity(product.id, 0);

      expect(notifier.state, isEmpty);
    });

    test('incrementQuantity increases quantity by one', () {
      notifier.addProduct(product);
      notifier.incrementQuantity(product.id);

      expect(notifier.state.first.quantity, 2);
    });

    test('decrementQuantity to zero removes the product from the cart', () {
      notifier.addProduct(product, quantity: 1);
      notifier.decrementQuantity(product.id);

      expect(notifier.state, isEmpty);
    });

    test('removeProduct removes only the targeted line', () {
      notifier.addProduct(product);
      notifier.addProduct(mockProducts[1]);
      notifier.removeProduct(product.id);

      expect(notifier.state.length, 1);
      expect(notifier.state.first.product.id, mockProducts[1].id);
    });

    test('clear empties the cart', () {
      notifier.addProduct(product);
      notifier.addProduct(mockProducts[1]);
      notifier.clear();

      expect(notifier.state, isEmpty);
    });

    test('adding an out-of-stock product still creates a line (UI prevents the tap, '
        'but the notifier itself stays permissive and testable)', () {
      notifier.addProduct(outOfStockProduct, quantity: 1);

      expect(notifier.state.length, 1);
    });
  });
}
