import '../../core/app_exception.dart';
import '../../core/ui_state.dart';
import '../../data/models/user.dart';
import '../../data/repositories/favorites_repository.dart';
import 'base_view_model.dart';

/// ViewModel de favoritos. Hay una sola instancia para toda la app, asi la
/// estrella se actualiza a la vez en la lista, el detalle y la pestana
/// Favoritos.
class FavoritesViewModel extends BaseViewModel {
  FavoritesViewModel(this._repository);

  final FavoritesRepository _repository;

  UiState<List<User>> _state = const LoadingState();
  UiState<List<User>> get state => _state;

  List<User> _favorites = [];

  /// Favoritos ordenados por nombre.
  List<User> get favorites => List.unmodifiable(_favorites);

  int get count => _favorites.length;

  bool isFavorite(int userId) => _favorites.any((user) => user.id == userId);

  /// Lee los favoritos guardados en el telefono (no necesita Internet).
  Future<void> loadFavorites() async {
    try {
      _favorites = await _repository.getFavorites();
      _sort();
      _state = SuccessState(favorites);
    } on AppException catch (error) {
      _state = ErrorState(error);
    } catch (_) {
      _state = const ErrorState(StorageException());
    }
    notifySafely();
  }

  /// Agrega o quita un favorito y lo guarda de inmediato.
  ///
  /// Devuelve `true` si el usuario quedo como favorito y `false` si se quito.
  /// Si no se puede guardar, se revierte el cambio y se lanza
  /// [StorageException] para que la interfaz avise al usuario.
  Future<bool> toggleFavorite(User user) async {
    // Si aun se estan leyendo los favoritos, se espera para no sobrescribirlos.
    if (_state is LoadingState) await loadFavorites();

    final previous = List<User>.of(_favorites);
    final willBeFavorite = !isFavorite(user.id);

    if (willBeFavorite) {
      _favorites.add(user);
      _sort();
    } else {
      _favorites.removeWhere((fav) => fav.id == user.id);
    }
    _state = SuccessState(favorites);
    notifySafely(); // la estrella cambia al instante

    try {
      await _repository.saveFavorites(_favorites);
      return willBeFavorite;
    } catch (_) {
      _favorites = previous;
      _state = SuccessState(favorites);
      notifySafely();
      throw const StorageException();
    }
  }

  void _sort() {
    _favorites.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }
}
