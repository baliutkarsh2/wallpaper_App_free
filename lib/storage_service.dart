import 'package:firebase_storage/firebase_storage.dart';
import 'wallpaper.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Wallpaper>> fetchWallpapers(String folder) async {
    try {
      // List all items in the specified folder
      ListResult result = await _storage.ref(folder).listAll();
      List<Wallpaper> wallpapers = [];

      // Fetch the download URL for each item and create Wallpaper objects
      for (var ref in result.items) {
        String url = await ref.getDownloadURL();
        wallpapers.add(Wallpaper(url: url));
      }

      return wallpapers;
    } catch (e) {
      print("Error fetching wallpapers from $folder: $e");
      return [];
    }
  }
}
