import 'package:flutter/material.dart';

import '../../core/ui_state.dart';
import '../../data/models/post.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/user_detail_view_model.dart';
import '../widgets/favorite_button.dart';
import '../widgets/state_views.dart';

/// Pantalla 2: datos del usuario y sus publicaciones.
///
/// Los datos del usuario llegan por parametro (ya estan en memoria o en
/// favoritos), por eso se ven aunque no haya Internet. Solo las
/// publicaciones se piden a la API.
class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({
    super.key,
    required this.user,
    required this.userRepository,
    required this.favoritesViewModel,
  });

  final User user;
  final UserRepository userRepository;
  final FavoritesViewModel favoritesViewModel;

  /// Ruta para navegar al detalle con `Navigator.push`.
  static Route<void> route({
    required User user,
    required UserRepository userRepository,
    required FavoritesViewModel favoritesViewModel,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => UserDetailScreen(
        user: user,
        userRepository: userRepository,
        favoritesViewModel: favoritesViewModel,
      ),
    );
  }

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late final UserDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Al abrir la pantalla se piden las publicaciones de este usuario.
    _viewModel = UserDetailViewModel(widget.userRepository, widget.user.id);
    _viewModel.loadPosts();
  }

  @override
  void dispose() {
    // Al volver atras se destruye el ViewModel; si la respuesta llega
    // despues, se ignora.
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          FavoriteButton(
            user: user,
            favoritesViewModel: widget.favoritesViewModel,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _viewModel.loadPosts(showLoading: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _UserInfoCard(user: user),
            const SizedBox(height: 24),
            Text(
              'Publicaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => _buildPosts(_viewModel.postsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosts(UiState<List<Post>> state) {
    return switch (state) {
      LoadingState() => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: LoadingView(message: 'Cargando publicaciones...'),
        ),
      ErrorState(:final error) => ErrorView(
          error: error,
          onRetry: _viewModel.loadPosts,
          scrollable: false,
        ),
      SuccessState(:final data) => data.isEmpty
          ? const EmptyView(
              icon: Icons.article_outlined,
              title: 'Sin publicaciones',
              message: 'Este usuario todavía no ha publicado nada.',
            )
          : Column(
              children: [
                for (final post in data) _PostCard(post: post),
              ],
            ),
    };
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initials = user.initials.isEmpty ? '?' : user.initials;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 28, child: Text(initials)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: textTheme.titleMedium),
                      Text('@${user.username}', style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(icon: Icons.email_outlined, text: user.email),
            _InfoRow(icon: Icons.phone_outlined, text: user.phone),
            _InfoRow(icon: Icons.language_rounded, text: user.website),
            _InfoRow(icon: Icons.business_rounded, text: user.companyName),
            if (user.companyCatchPhrase.isNotEmpty)
              _InfoRow(
                icon: Icons.format_quote_rounded,
                text: user.companyCatchPhrase,
              ),
            _InfoRow(icon: Icons.location_on_outlined, text: user.fullAddress),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(post.body),
          ],
        ),
      ),
    );
  }
}
