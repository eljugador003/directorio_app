// Pruebas de la persistencia de favoritos (shared_preferences simulado).
//
// Ejecutar con:  flutter test

import 'package:directorio_app/data/local/favorites_local_data_source.dart';
import 'package:directorio_app/data/models/user.dart';
import 'package:directorio_app/data/repositories/favorites_repository.dart';
import 'package:directorio_app/ui/viewmodels/favorites_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

User _user(int id, String name) => User(
      id: id,
      name: name,
      username: 'user$id',
      email: 'user$id@mail.com',
      phone: '',
      website: '',
      companyName: 'Empresa $id',
      companyCatchPhrase: '',
      street: '',
      suite: '',
      city: '',
    );

FavoritesViewModel _newViewModel() =>
    FavoritesViewModel(FavoritesRepository(FavoritesLocalDataSource()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sin datos guardados, la lista de favoritos esta vacia', () async {
    final vm = _newViewModel();
    await vm.loadFavorites();
    expect(vm.favorites, isEmpty);
  });

  test('agregar y quitar favoritos cambia isFavorite', () async {
    final vm = _newViewModel();
    await vm.loadFavorites();

    expect(await vm.toggleFavorite(_user(1, 'Ana')), isTrue);
    expect(vm.isFavorite(1), isTrue);

    expect(await vm.toggleFavorite(_user(1, 'Ana')), isFalse);
    expect(vm.isFavorite(1), isFalse);
  });

  test('los favoritos se conservan al "reiniciar" la app', () async {
    final first = _newViewModel();
    await first.loadFavorites();
    await first.toggleFavorite(_user(2, 'Zoe'));
    await first.toggleFavorite(_user(1, 'Ana'));

    // Nueva instancia = como si la app se hubiera cerrado y abierto.
    final second = _newViewModel();
    await second.loadFavorites();
    expect(second.favorites.map((u) => u.name).toList(), ['Ana', 'Zoe']);
    expect(second.favorites.first.companyName, 'Empresa 1');
  });
}
