import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'favorites_provider.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;

  ImageDetailScreen({required this.imageUrl});

  Future<void> setWallpaper(BuildContext context, String imageUrl) async {
    try {
      // Download image as bytes
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      // Save image to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/temp_wallpaper.png');
      await tempFile.writeAsBytes(bytes);

      // Set wallpaper using the file path
      final bool result = await WallpaperManager.setWallpaperFromFile(
          tempFile.path, WallpaperManager.HOME_SCREEN);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wallpaper set successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set wallpaper')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set wallpaper: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallpaper Detail'),
        actions: [
          IconButton(
            icon: Icon(
              favoritesProvider.isFavorite(imageUrl)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favoritesProvider.isFavorite(imageUrl) ? Colors.red : Colors.black,
            ),
            onPressed: () {
              if (favoritesProvider.isFavorite(imageUrl)) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Remove from favorites'),
                      content: Text('Do you want to remove this image from favorites?'),
                      actions: [
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            favoritesProvider.removeFavorite(imageUrl);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                favoritesProvider.addFavorite(imageUrl);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            ElevatedButton(
              onPressed: () => setWallpaper(context, imageUrl),
              child: Text('Set as Wallpaper'),
            ),
          ],
        ),
      ),
    );
  }
}
