import 'package:flutter/material.dart';

import '../../core/ui_state.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/users_view_model.dart';
import '../widgets/state_views.dart';
import '../widgets/user_tile.dart';
import 'user_detail_screen.dart';

/// Pantalla 1: lista de usuarios.
class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
    required this.userRepository,
    required this.favoritesViewModel,
    required this.onShowFavorites,
  });

  final UserRepository userRepository;
  final FavoritesViewModel favoritesViewModel;

  /// Cambia a la pestana Favoritos (se ofrece cuando no hay Internet).
  final VoidCallback onShowFavorites;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with WidgetsBindingObserver {
  late final UsersViewModel _viewModel;

  // CICLO DE VIDA ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // 1) Se crea el ViewModel y se hace la primera carga (una sola vez).
    _viewModel = UsersViewModel(widget.userRepository);
    _viewModel.loadUsers();
    // 2) Se observa el ciclo de vida de la app (resumed, paused...).
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al volver a la app (onResume en Android), si la ultima carga fallo
    // (por ejemplo, no habia Internet) se reintenta automaticamente.
    if (state == AppLifecycleState.resumed && _viewModel.state is ErrorState) {
      _viewModel.loadUsers();
    }
  }

  @override
  void dispose() {
    // 3) Se libera todo al destruir la pantalla.
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  // NAVEGACION -------------------------------------------------------------

  void _openDetail(User user) {
    Navigator.of(context).push(
      UserDetailScreen.route(
        user: user,
        userRepository: widget.userRepository,
        favoritesViewModel: widget.favoritesViewModel,
      ),
    );
  }

  // INTERFAZ ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directorio')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final state = _viewModel.state;
          return switch (state) {
            LoadingState() =>
              const LoadingView(message: 'Cargando usuarios...'),
            ErrorState(:final error) => ErrorView(
                error: error,
                onRetry: _viewModel.loadUsers,
                secondaryLabel: 'Ver mis favoritos',
                onSecondary: widget.onShowFavorites,
              ),
            SuccessState(:final data) => data.isEmpty
                ? const EmptyView(
                    icon: Icons.people_outline_rounded,
                    title: 'No hay usuarios',
                    message: 'La API no devolvió usuarios.',
                  )
                : RefreshIndicator(
                    onRefresh: () => _viewModel.loadUsers(showLoading: false),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = data[index];
                        return UserTile(
                          user: user,
                          favoritesViewModel: widget.favoritesViewModel,
                          onTap: () => _openDetail(user),
                        );
                      },
                    ),
                  ),
          };
        },
      ),
    );
  }
}
