import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'storage_service.dart';
import 'wallpaper.dart';
import 'image_detail_screen.dart';

class WallpaperGrid extends StatefulWidget {
  final String folder;
  final Key key;
  final String title;

  WallpaperGrid({required this.folder, required this.key, required this.title}) : super(key: key);

  @override
  _WallpaperGridState createState() => _WallpaperGridState();
}

class _WallpaperGridState extends State<WallpaperGrid> {
  late Future<List<Wallpaper>> _wallpapers;

  @override
  void initState() {
    super.initState();
    _wallpapers = StorageService().fetchWallpapers(widget.folder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                if (widget.folder == 'wallpapers/free')
                  Text(
                    "Humongous collection of 2500+ Wallpapers!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Wallpaper>>(
              future: _wallpapers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading wallpapers'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No wallpapers found'));
                } else {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,  // Number of columns
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 3 / 4,  // Aspect ratio for rectangles with longer height
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDetailScreen(
                                imageUrl: snapshot.data![index].url,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data![index].url,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
