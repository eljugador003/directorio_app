import 'package:flutter/material.dart';

import '../../data/models/user.dart';
import '../viewmodels/favorites_view_model.dart';
import 'favorite_button.dart';

/// Fila de la lista: nombre, correo y empresa (`company.name`).
class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.user,
    required this.favoritesViewModel,
    required this.onTap,
  });

  final User user;
  final FavoritesViewModel favoritesViewModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = user.initials.isEmpty ? '?' : user.initials;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(initials)),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(
            children: [
              const Icon(Icons.business_rounded, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  user.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      isThreeLine: true,
      trailing: FavoriteButton(
        user: user,
        favoritesViewModel: favoritesViewModel,
      ),
    );
  }
}
