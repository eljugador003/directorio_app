import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'data/local/favorites_local_data_source.dart';
import 'data/remote/api_service.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/user_repository.dart';
import 'ui/screens/home_screen.dart';
import 'ui/viewmodels/favorites_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Red de seguridad: cualquier error no controlado se registra en la consola
  // en lugar de cerrar la aplicacion.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Error no controlado: $error');
    return true; // marcado como manejado: la app sigue funcionando
  };

  // Creacion de dependencias (capa de datos -> repositorios -> ViewModels).
  final apiService = ApiService();
  final userRepository = UserRepository(apiService);
  final favoritesRepository = FavoritesRepository(FavoritesLocalDataSource());
  final favoritesViewModel = FavoritesViewModel(favoritesRepository)
    ..loadFavorites(); // los favoritos se leen del telefono al iniciar

  runApp(
    DirectorioApp(
      userRepository: userRepository,
      favoritesViewModel: favoritesViewModel,
    ),
  );
}

class DirectorioApp extends StatelessWidget {
  const DirectorioApp({
    super.key,
    required this.userRepository,
    required this.favoritesViewModel,
  });

  final UserRepository userRepository;
  final FavoritesViewModel favoritesViewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directorio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        userRepository: userRepository,
        favoritesViewModel: favoritesViewModel,
      ),
    );
  }
}
