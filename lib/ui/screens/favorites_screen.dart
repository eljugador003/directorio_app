import 'package:flutter/material.dart';

import '../../core/ui_state.dart';
import '../../data/repositories/user_repository.dart';
import '../viewmodels/favorites_view_model.dart';
import '../widgets/state_views.dart';
import '../widgets/user_tile.dart';
import 'user_detail_screen.dart';

/// Pantalla 3: favoritos guardados en el telefono. Funciona sin Internet.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.userRepository,
    required this.favoritesViewModel,
  });

  final UserRepository userRepository;
  final FavoritesViewModel favoritesViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: ListenableBuilder(
        listenable: favoritesViewModel,
        builder: (context, _) {
          return switch (favoritesViewModel.state) {
            LoadingState() =>
              const LoadingView(message: 'Cargando favoritos...'),
            ErrorState(:final error) => ErrorView(
                error: error,
                onRetry: favoritesViewModel.loadFavorites,
              ),
            SuccessState(:final data) => data.isEmpty
                ? const EmptyView(
                    icon: Icons.star_border_rounded,
                    title: 'Aún no tienes favoritos',
                    message: 'Toca la estrella de un usuario para guardarlo '
                        'aquí. Podrás verlo aunque no tengas Internet.',
                  )
                : Column(
                    children: [
                      const _OfflineBanner(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = data[index];
                            return UserTile(
                              user: user,
                              favoritesViewModel: favoritesViewModel,
                              onTap: () => Navigator.of(context).push(
                                UserDetailScreen.route(
                                  user: user,
                                  userRepository: userRepository,
                                  favoritesViewModel: favoritesViewModel,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          };
        },
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colors.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.offline_pin_rounded, color: colors.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Guardados en el teléfono: disponibles sin conexión.',
              style: TextStyle(color: colors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
