import '../local/favorites_local_data_source.dart';
import '../models/user.dart';

/// Repositorio de favoritos: lee y escribe la lista en el almacenamiento local.
class FavoritesRepository {
  FavoritesRepository(this._local);

  final FavoritesLocalDataSource _local;

  Future<List<User>> getFavorites() => _local.readFavorites();

  Future<void> saveFavorites(List<User> favorites) =>
      _local.saveFavorites(favorites);
}
