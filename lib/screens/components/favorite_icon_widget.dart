import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_review/data/model/restaurant.dart';
import 'package:restaurant_review/providers/detail/favorite_list_provider.dart';
import 'package:restaurant_review/providers/detail/favorite_icon_provider.dart';

class FavoriteIconWidget extends StatefulWidget {
  final Restaurant restaurant;

  const FavoriteIconWidget({
    super.key,
    required this.restaurant,
  });

  @override
  State<FavoriteIconWidget> createState() => _FavoriteIconWidgetState();
}

class _FavoriteIconWidgetState extends State<FavoriteIconWidget> {
  @override
  void initState() {
    final favoriteListProvider = context.read<FavoriteListProvider>();
    final favoriteIconProvider = context.read<FavoriteIconProvider>();

    Future.microtask(() async {
      if (widget.restaurant.id != null) {
        final isFavorited = await favoriteListProvider.isFavorite(widget.restaurant);
        favoriteIconProvider.isFavorite = isFavorited;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (widget.restaurant.id == null) return;
        
        final favoriteListProvider = context.read<FavoriteListProvider>();
        final favoriteIconProvider = context.read<FavoriteIconProvider>();
        final isFavorited = favoriteIconProvider.isFavorite;

        if (isFavorited) {
          favoriteListProvider.removeFavorite(widget.restaurant);
        } else {
          favoriteListProvider.addFavorite(widget.restaurant);
        }
        context.read<FavoriteIconProvider>().isFavorite = !isFavorited;
      },
      icon: Icon(
        context.watch<FavoriteIconProvider>().isFavorite
            ? Icons.favorite
            : Icons.favorite_border,
        color: context.watch<FavoriteIconProvider>().isFavorite
            ? Colors.red
            : null,
      ),
    );
  }
}