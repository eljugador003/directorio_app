import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../data/models/user.dart';
import '../viewmodels/favorites_view_model.dart';

/// Estrella para marcar o quitar un favorito. Se redibuja sola cuando cambia
/// la lista de favoritos y avisa con un SnackBar.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.user,
    required this.favoritesViewModel,
  });

  final User user;
  final FavoritesViewModel favoritesViewModel;

  Future<void> _toggle(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    String text;
    try {
      final added = await favoritesViewModel.toggleFavorite(user);
      text = added
          ? '${user.name} se agregó a favoritos'
          : '${user.name} se quitó de favoritos';
    } on AppException catch (error) {
      text = error.message;
    } catch (_) {
      text = const StorageException().message;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favoritesViewModel,
      builder: (context, _) {
        final isFavorite = favoritesViewModel.isFavorite(user.id);
        return IconButton(
          tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
          icon: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFavorite ? Colors.amber.shade700 : null,
          ),
          onPressed: () => _toggle(context),
        );
      },
    );
  }
}
