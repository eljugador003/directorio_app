import '../../core/app_exception.dart';
import '../../core/ui_state.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// ViewModel de la lista de usuarios.
class UsersViewModel extends BaseViewModel {
  UsersViewModel(this._repository);

  final UserRepository _repository;

  UiState<List<User>> _state = const LoadingState();
  UiState<List<User>> get state => _state;

  bool _isLoading = false;

  /// Carga los usuarios de la API.
  ///
  /// Con [showLoading] en `false` (deslizar para actualizar) se mantiene la
  /// lista actual en pantalla mientras llega la respuesta.
  Future<void> loadUsers({bool showLoading = true}) async {
    if (_isLoading) return; // evita peticiones duplicadas
    _isLoading = true;
    if (showLoading) {
      _state = const LoadingState();
      notifySafely();
    }
    try {
      final users = await _repository.getUsers();
      _state = SuccessState(users);
    } on AppException catch (error) {
      _state = ErrorState(error);
    } catch (_) {
      _state = const ErrorState(UnknownException());
    } finally {
      _isLoading = false;
    }
    notifySafely();
  }
}
