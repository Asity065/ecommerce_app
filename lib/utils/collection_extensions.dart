/// Petite extension utilitaire partagée, pour éviter de dupliquer
/// `firstOrNull` dans plusieurs fichiers (services, providers).
/// (Dart core ne fournit cette méthode que via `package:collection`,
/// qu'on évite ici pour limiter les dépendances.)
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
