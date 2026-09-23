import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/product.dart';
import '../utils/collection_extensions.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProductById(String id);
}

class ProductService implements ProductRepository {
  const ProductService();

  @override
  Future<List<Product>> fetchProducts({bool simulateError = false}) async {
    // Latence réseau simulée.
    await Future.delayed(const Duration(milliseconds: 800));

    if (simulateError || Random().nextDouble() < 0.03) {
      throw Exception('Impossible de charger le catalogue. Vérifiez votre connexion.');
    }

    final raw = await rootBundle.loadString('assets/products.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product> fetchProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final products = await fetchProducts();
    final product = products.where((p) => p.id == id).firstOrNull;
    if (product == null) {
      throw Exception('Produit introuvable ($id).');
    }
    return product;
  }
}
