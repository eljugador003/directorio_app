import 'package:flutter/material.dart';

import '../../data/repositories/user_repository.dart';
import '../viewmodels/favorites_view_model.dart';
import 'favorites_screen.dart';
import 'users_screen.dart';

/// Contenedor con barra inferior: Usuarios y Favoritos.
///
/// `IndexedStack` mantiene vivas las dos pestanas, asi la lista no se vuelve
/// a descargar cada vez que el usuario cambia de pestana.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userRepository,
    required this.favoritesViewModel,
  });

  final UserRepository userRepository;
  final FavoritesViewModel favoritesViewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          UsersScreen(
            userRepository: widget.userRepository,
            favoritesViewModel: widget.favoritesViewModel,
            onShowFavorites: () => _select(1),
          ),
          FavoritesScreen(
            userRepository: widget.userRepository,
            favoritesViewModel: widget.favoritesViewModel,
          ),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: widget.favoritesViewModel,
        builder: (context, _) {
          final count = widget.favoritesViewModel.count;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: 'Usuarios',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.star_border_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.star_rounded),
                ),
                label: 'Favoritos',
              ),
            ],
          );
        },
      ),
    );
  }
}
