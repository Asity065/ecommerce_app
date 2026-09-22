#  Boutique Riverpod — App e-commerce Flutter

Application e-commerce mobile construite avec **Flutter** et **Riverpod** comme
unique solution de state management, dans un but de démonstration technique
(architecture en couches, providers multiples, gestion async avec `AsyncValue`).

##  Fonctionnalités

- **Catalogue de produits** : liste (grille) + écran de détail
- **Panier d'achat** : ajout, suppression (swipe), modification de quantité, total en temps réel
- **Favoris persistés localement** (`shared_preferences`) : survivent au redémarrage de l'app
- **Filtrage et tri** : recherche texte, filtre par catégorie, tri par prix/note
- **Profil utilisateur** (mocké) : infos, nombre de favoris, menu de compte
- Gestion cohérente des états **chargement / erreur / données** partout où une donnée est asynchrone

##  Architecture en couches

```
lib/
├── models/          # Entités immuables (Product, CartItem, AppUser)
├── data/            # Données mockées (catalogue produit)
├── services/        # Accès aux données : appels "réseau" simulés + persistance locale
├── providers/        # Logique métier + état (Riverpod) — AUCUN widget ici
├── screens/         # Écrans (consomment les providers via ConsumerWidget)
└── widgets/         # Composants UI réutilisables
```

Le principe directeur : **les widgets ne contiennent aucune logique métier**.
Ils lisent des providers (`ref.watch`) et déclenchent des actions
(`ref.read(...).notifier.methode()`). Toute la logique (calculs de total,
filtrage, tri, persistance) vit dans `providers/` et `services/`.

- **`services/`** encapsule la source de données (mock aujourd'hui, API REST
  demain) derrière une interface stable. Les providers ne connaissent que le
  service, jamais l'implémentation concrète — ce qui facilite les tests
  (override du provider de service avec un mock).
- **`providers/`** contient les `StateNotifier` (logique + état mutable
  complexe : panier, favoris) et les `FutureProvider`/`Provider` (données
  async ou dérivées).
- **`screens/` et `widgets/`** sont des `ConsumerWidget`/`ConsumerStatefulWidget`
  purement déclaratifs.

##  Providers utilisés

| Provider | Type | Rôle |
|---|---|---|
| `productServiceProvider` | `Provider` | Fournit l'instance du service produits (injection/mock) |
| `productsProvider` | `FutureProvider<List<Product>>` | Charge le catalogue de façon async, expose un `AsyncValue` |
| `categoriesProvider` | `Provider<AsyncValue<List<String>>>` | Catégories dérivées du catalogue |
| `searchQueryProvider` | `StateProvider<String>` | Texte de recherche courant |
| `selectedCategoryProvider` | `StateProvider<String>` | Catégorie sélectionnée pour le filtre |
| `sortOptionProvider` | `StateProvider<SortOption>` | Option de tri active |
| `filteredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Combine catalogue + recherche + filtre + tri (recalculé automatiquement) |
| `productByIdProvider` | `Provider.family<Product?, String>` | Récupère un produit précis depuis le cache déjà chargé |
| `cartProvider` | `StateNotifierProvider<CartNotifier, List<CartItem>>` | Logique complète du panier (ajout/suppression/quantités) |
| `cartItemCountProvider` / `cartTotalProvider` | `Provider` | Valeurs dérivées du panier (badge, total) |
| `favoritesStorageServiceProvider` | `Provider` | Service de persistance locale des favoris |
| `favoritesProvider` | `StateNotifierProvider<FavoritesNotifier, Set<String>>` | Favoris, chargés et sauvegardés via `SharedPreferences` |
| `userServiceProvider` | `Provider` | Service utilisateur mocké |
| `currentUserProvider` | `FutureProvider<AppUser>` | Profil utilisateur async |

Ce projet compte donc **13 providers distincts** répartis sur les principaux
types de Riverpod (`Provider`, `Provider.family`, `StateProvider`,
`StateNotifierProvider`, `FutureProvider`), largement au-delà des 5 minimum
requis.

##  Gestion async avec `AsyncValue`

Toutes les données chargées de façon asynchrone (catalogue produits, profil
utilisateur, catégories, liste filtrée) sont exposées sous forme
d'`AsyncValue<T>`. Un widget générique, `AsyncValueWidget<T>`
(`lib/widgets/async_value_widget.dart`), centralise le pattern
`when(data:, loading:, error:)` pour garantir un affichage cohérent du
spinner de chargement et des messages d'erreur (avec bouton "Réessayer") dans
tout l'écran — évitant la duplication de ce code dans chaque écran.

Le service `ProductService.fetchProducts` simule volontairement un risque
d'échec réseau (3 % de chance), ce qui permet de démontrer concrètement l'état
d'erreur en conditions réelles d'utilisation.

##  Persistance locale

Les favoris sont stockés via `shared_preferences` (`FavoritesStorageService`).
Le `FavoritesNotifier` charge l'état sauvegardé à l'initialisation et
persiste chaque modification (`toggle`) immédiatement, de façon asynchrone et
non bloquante pour l'UI.

## Lancer le projet

```bash
flutter pub get
flutter run
```

Testé pour cibler Android, iOS et Web (Material 3).

##  Pistes de tests (non incluses dans cette version)

- Tests unitaires des `StateNotifier` (`CartNotifier`, `FavoritesNotifier`)
  en overridant `favoritesStorageServiceProvider` / `productServiceProvider`
  avec des mocks via `ProviderScope(overrides: [...])`.
- Tests de widgets sur `ProductListScreen` avec un `productsProvider` mocké
  pour couvrir les 3 états (loading/data/error).

##  Choix techniques notables

- **Aucune autre solution de state management** que Riverpod n'est utilisée
  (pas de `setState` pour l'état métier — uniquement pour de l'état
  d'UI local et éphémère, comme l'onglet actif de la navigation ou la
  quantité en cours de sélection sur l'écran détail).
- Les images produits sont mockées avec des emojis pour éviter toute
  dépendance réseau et garder le projet 100 % local / reproductible.
- Architecture pensée pour qu'un vrai backend REST puisse remplacer
  `ProductService`/`UserService` sans toucher à l'UI ni aux providers.
