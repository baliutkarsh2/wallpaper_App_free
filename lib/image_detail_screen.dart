import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'favorites_provider.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;

  ImageDetailScreen({required this.imageUrl});

  Future<void> setWallpaper(BuildContext context, String imageUrl, int location) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/temp_wallpaper.png');
      await tempFile.writeAsBytes(bytes);

      final bool result = await WallpaperManager.setWallpaperFromFile(tempFile.path, location);

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

  void _showSetWallpaperDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.black.withOpacity(0.5),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set as Wallpaper',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Choose where to set the wallpaper:',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOptionButton(context, 'Home screen', WallpaperManager.HOME_SCREEN),
                    _buildOptionButton(context, 'Lock screen', WallpaperManager.LOCK_SCREEN),
                    _buildOptionButton(context, 'Both', WallpaperManager.BOTH_SCREEN),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(BuildContext context, String label, int location) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setWallpaper(context, imageUrl, location);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        final bytes = response.bodyBytes;

        final Directory downloadsDir = Directory('/storage/emulated/0/Download');
        final File file = File('${downloadsDir.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download image: $e')),
        );
      }
    } else if (status.isDenied) {
      _showPermissionDialog(context);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text(
            'Storage permission is required to download images. Please grant the permission.',
            style: GoogleFonts.montserrat(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Allow', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.of(context).pop();
                final newStatus = await Permission.manageExternalStorage.request();
                if (newStatus.isGranted) {
                  _downloadImage(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(imageUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallpaper Detail', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(imageUrl),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained * 1.0,
              maxScale: PhotoViewComputedScale.covered * 2.0,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.pink : Colors.white,
                    ),
                    onPressed: () {
                      if (isFavorite) {
                        favoritesProvider.removeFavorite(imageUrl);
                      } else {
                        favoritesProvider.addFavorite(imageUrl);
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => _showSetWallpaperDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    child: Text(
                      'Set as Wallpaper',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    onPressed: () => _downloadImage(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
