import 'dart:math';

import '../data/mock_products.dart';
import '../models/product.dart';

class ProductService {
  const ProductService();

  Future<List<Product>> fetchProducts({bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (simulateError || Random().nextDouble() < 0.03) {
      throw Exception('Impossible de charger le catalogue. Vérifiez votre connexion.');
    }

    return mockProducts;
  }

  Future<Product> fetchProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final product = mockProducts.where((p) => p.id == id).firstOrNull;
    if (product == null) {
      throw Exception('Produit introuvable ($id).');
    }
    return product;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
