#  Boutique Riverpod — App e-commerce Flutter

Application e-commerce mobile construite avec Flutter et Riverpod comme
unique solution de state management, dans un but de démonstration technique
(architecture en couches, providers multiples, gestion async avec `AsyncValue`).

##  Fonctionnalités

- **Catalogue de produits** : liste (grille, `lib/screens/product_list_screen.dart`) + écran de détail
  (`lib/screens/product_detail_screen.dart`, ouvert au tap sur une carte produit)
- **Panier d'achat** : ajout, suppression (swipe), modification de quantité, total en temps réel
  (`lib/screens/cart_screen.dart`)
- **Favoris persistés localement** (`shared_preferences`) : survivent au redémarrage de l'app
  (`lib/screens/favorites_screen.dart`)
- **Filtrage et tri** : barre de recherche + chips de catégories + menu de tri, tous visibles dans
  l'AppBar du catalogue (`lib/widgets/filter_sort_bar.dart`), branchés sur `filteredProductsProvider`
- **Profil utilisateur** (mocké) : infos, nombre de favoris, menu de compte
  (`lib/screens/profile_screen.dart`), 4ᵉ onglet de la navigation
- Gestion cohérente des états **chargement / erreur / données** partout où une donnée est asynchrone
- **Bonus — animation à l'ajout au panier** : micro-pulsation du bouton "ajouter" et rebond animé
  de l'icône panier dans la barre de navigation (`lib/widgets/add_to_cart_button.dart` et
  `lib/widgets/animated_cart_icon.dart`)

Les 4 écrans sont les 4 onglets de la `NavigationBar` définie dans
`lib/screens/main_navigation.dart` : Catalogue, Favoris, Panier, Profil — le détail produit
s'ouvre en navigation poussée (`Navigator.push`) depuis n'importe quelle carte produit.

##  Architecture en couches

```
lib/
├── models/          # Entités immuables (Product, CartItem, AppUser)
├── data/            # Fixture Dart (mockProducts) réutilisée par les tests
├── services/        # Interfaces + implémentations : accès aux données et persistance locale
├── providers/       # Logique métier + état (Riverpod) — AUCUN widget ici
├── screens/         # Écrans (consomment les providers via ConsumerWidget)
├── widgets/         # Composants UI réutilisables
└── utils/           # Petits helpers partagés (ex. extension firstOrNull)
assets/
└── products.json    # Catalogue produit mocké, chargé et parsé via Product.fromJson
test/
├── fakes/           # Fausses implémentations des interfaces de service, pour les tests
├── widgets/         # Tests de widgets
└── *_test.dart      # Tests unitaires des notifiers et des providers dérivés
```

Le principe directeur : **les widgets ne contiennent aucune logique métier**.
Ils lisent des providers (`ref.watch`) et déclenchent des actions
(`ref.read(...).notifier.methode()`). Toute la logique (calculs de total,
filtrage, tri, persistance) vit dans `providers/` et `services/`.

- **`services/`** encapsule la source de données derrière une **interface**
  explicite (`ProductRepository`, `FavoritesStorage`, `UserRepository`), avec
  une implémentation concrète par interface (`ProductService`,
  `FavoritesStorageService`, `UserService`). Les providers déclarent leur
  type sur l'interface, jamais sur la classe concrète — ce qui permet
  d'overrider n'importe quel service par un faux en test
  (`ProviderContainer(overrides: [...])`), sans toucher à l'UI ni à la
  logique métier. `ProductService` charge réellement `assets/products.json`
  et le parse via `Product.fromJson` (plutôt que de garder une liste Dart
  statique), pour illustrer un vrai flux "JSON local → modèle".
- **`providers/`** contient les `StateNotifier` (logique + état mutable
  complexe : panier, favoris) et les `FutureProvider`/`Provider` (données
  async ou dérivées).
- **`screens/` et `widgets/`** sont des `ConsumerWidget`/`ConsumerStatefulWidget`
  purement déclaratifs.

## Providers utilisés

| Provider | Type | Rôle |
|---|---|---|
| `productServiceProvider` | `Provider<ProductRepository>` | Fournit le service produits *via son interface* (injection/mock) |
| `productsProvider` | `FutureProvider<List<Product>>` | Charge le catalogue de façon async, expose un `AsyncValue` |
| `categoriesProvider` | `Provider<AsyncValue<List<String>>>` | Catégories dérivées du catalogue |
| `searchQueryProvider` | `StateProvider<String>` | Texte de recherche courant |
| `selectedCategoryProvider` | `StateProvider<String>` | Catégorie sélectionnée pour le filtre |
| `sortOptionProvider` | `StateProvider<SortOption>` | Option de tri active |
| `filteredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Combine catalogue + recherche + filtre + tri (recalculé automatiquement) |
| `productByIdProvider` | `Provider.family<Product?, String>` | Récupère un produit précis depuis le cache déjà chargé |
| `cartProvider` | `StateNotifierProvider<CartNotifier, List<CartItem>>` | Logique complète du panier (ajout/suppression/quantités) |
| `cartItemCountProvider` / `cartTotalProvider` | `Provider` | Valeurs dérivées du panier (badge, total) |
| `favoritesStorageServiceProvider` | `Provider<FavoritesStorage>` | Service de persistance locale des favoris, via son interface |
| `favoritesProvider` | `StateNotifierProvider<FavoritesNotifier, Set<String>>` | Favoris, chargés et sauvegardés via `SharedPreferences` |
| `userServiceProvider` | `Provider<UserRepository>` | Service utilisateur mocké, via son interface |
| `currentUserProvider` | `FutureProvider<AppUser>` | Profil utilisateur async |

Ce projet compte donc **13 providers distincts** répartis sur les principaux
types de Riverpod (`Provider`, `Provider.family`, `StateProvider`,
`StateNotifierProvider`, `FutureProvider`), largement au-delà des 5 minimum
requis.

## Gestion async avec `AsyncValue`

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

##  Lancer le projet

```bash
flutter pub get
flutter run
```

Cible Android, iOS et Web (Material 3).

##  Tests

```bash
flutter test
```

La suite couvre :

- **`test/cart_notifier_test.dart`** — logique du panier en isolation
  (ajout, incrément/décrément, respect du stock, suppression, vidage),
  en instanciant directement `CartNotifier` (aucun besoin de `ProviderContainer`
  puisqu'il ne dépend d'aucun autre provider).
- **`test/favorites_notifier_test.dart`** — chargement initial depuis le
  stockage, ajout/retrait via `toggle`, et vérification que chaque
  changement déclenche bien une sauvegarde — le tout via
  `FakeFavoritesStorage` (implémentation en mémoire de l'interface
  `FavoritesStorage`, dans `test/fakes/`), sans dépendre du plugin
  SharedPreferences.
- **`test/product_providers_test.dart`** — recherche, filtre par catégorie,
  tri (prix croissant, meilleures notes), combinaison des filtres, et
  propagation d'une erreur du repository jusqu'à `AsyncValue.error`. Utilise
  un `ProviderContainer` avec `productServiceProvider` overridé par un
  `FakeProductRepository`.
- **`test/widgets/async_value_widget_test.dart`** — test de widget vérifiant
  les 3 rendus (spinner, données, erreur + bouton "Réessayer" fonctionnel)
  du composant partagé `AsyncValueWidget`.

Les faux services de `test/fakes/fake_services.dart` implémentent les mêmes
interfaces (`ProductRepository`, `FavoritesStorage`, `UserRepository`) que
les vraies implémentations — c'est ce découplage qui rend les tests rapides
et indépendants de la plateforme (pas de vrai plugin, pas de vrai asset bundle
à charger pour les tests de logique pure).

##  Choix techniques notables

- **Aucune autre solution de state management** que Riverpod n'est utilisée
  (pas de `setState` pour l'état métier — uniquement pour de l'état
  d'UI local et éphémère, comme l'onglet actif de la navigation, la
  quantité en cours de sélection sur l'écran détail, ou les micro-animations
  du bouton "ajouter au panier").
- Les images produits sont mockées avec des emojis pour éviter toute
  dépendance réseau et garder le projet 100 % local / reproductible.
- Architecture pensée pour qu'un vrai backend REST puisse remplacer
  `ProductService`/`UserService` sans toucher à l'UI ni aux providers : il
  suffirait d'écrire une nouvelle classe implémentant `ProductRepository` /
  `UserRepository` et de changer une seule ligne dans le provider
  correspondant.
- Les services sont systématiquement exposés derrière une interface
  (`ProductRepository`, `FavoritesStorage`, `UserRepository`), ce qui a
  permis d'écrire des tests unitaires rapides sans dépendance à une vraie
  plateforme (pas de plugin SharedPreferences ni de chargement d'asset dans
  les tests de logique).

## Prérequis / configuration

- Flutter SDK ≥ 3.3 (Dart ≥ 3.3), voir `environment` dans `pubspec.yaml`.
- Aucune clé d'API ni configuration d'environnement nécessaire : toutes les
  données sont locales (`assets/products.json` + service utilisateur mocké).
- `flutter pub get` avant le premier lancement pour récupérer
  `flutter_riverpod` et `shared_preferences`.
