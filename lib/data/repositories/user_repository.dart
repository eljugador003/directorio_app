import '../models/post.dart';
import '../models/user.dart';
import '../remote/api_service.dart';

/// Repositorio de usuarios: punto unico de acceso a los datos remotos para
/// los ViewModels. Si mas adelante se agrega una cache, solo cambia esta clase.
class UserRepository {
  UserRepository(this._api);

  final ApiService _api;

  Future<List<User>> getUsers() => _api.fetchUsers();

  Future<List<Post>> getPostsByUser(int userId) =>
      _api.fetchPostsByUser(userId);
}
