import '../../core/app_exception.dart';
import '../../core/ui_state.dart';
import '../../data/models/post.dart';
import '../../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// ViewModel del detalle: carga las publicaciones de un usuario.
class UserDetailViewModel extends BaseViewModel {
  UserDetailViewModel(this._repository, this.userId);

  final UserRepository _repository;
  final int userId;

  UiState<List<Post>> _postsState = const LoadingState();
  UiState<List<Post>> get postsState => _postsState;

  bool _isLoading = false;

  Future<void> loadPosts({bool showLoading = true}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (showLoading) {
      _postsState = const LoadingState();
      notifySafely();
    }
    try {
      final posts = await _repository.getPostsByUser(userId);
      _postsState = SuccessState(posts);
    } on AppException catch (error) {
      _postsState = ErrorState(error);
    } catch (_) {
      _postsState = const ErrorState(UnknownException());
    } finally {
      _isLoading = false;
    }
    notifySafely();
  }
}
