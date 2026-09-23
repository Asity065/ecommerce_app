import 'package:ecommerce_riverpod/data/mock_products.dart';
import 'package:ecommerce_riverpod/models/product.dart';
import 'package:ecommerce_riverpod/models/user.dart';
import 'package:ecommerce_riverpod/services/favorites_storage_service.dart';
import 'package:ecommerce_riverpod/services/product_service.dart';
import 'package:ecommerce_riverpod/services/user_service.dart';

class FakeProductRepository implements ProductRepository {
  final bool throwOnFetch;

  FakeProductRepository({this.throwOnFetch = false});

  @override
  Future<List<Product>> fetchProducts() async {
    if (throwOnFetch) {
      throw Exception('Erreur réseau simulée');
    }
    return mockProducts;
  }

  @override
  Future<Product> fetchProductById(String id) async {
    return mockProducts.firstWhere((p) => p.id == id);
  }
}

/// Faux stockage des favoris, entièrement en mémoire — permet de tester
/// [FavoritesNotifier] sans dépendre du plugin SharedPreferences.
class FakeFavoritesStorage implements FavoritesStorage {
  Set<String> _saved;
  int saveCallCount = 0;

  FakeFavoritesStorage({Set<String>? initial}) : _saved = initial ?? {};

  @override
  Future<Set<String>> loadFavoriteIds() async => _saved;

  @override
  Future<void> saveFavoriteIds(Set<String> ids) async {
    _saved = ids;
    saveCallCount++;
  }
}

/// Faux service utilisateur pour les tests du profil.
class FakeUserRepository implements UserRepository {
  @override
  Future<AppUser> fetchCurrentUser() async {
    return const AppUser(
      id: 'test-user',
      name: 'Test User',
      email: 'test@example.com',
      avatarEmoji: '🧪',
      memberSince: 'Membre depuis 2024',
    );
  }
}
