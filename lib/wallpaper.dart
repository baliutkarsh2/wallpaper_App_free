class Wallpaper {
  final String url;

  Wallpaper({required this.url});

  factory Wallpaper.fromMap(Map<String, dynamic> data) {
    return Wallpaper(
      url: data['url'] ?? '',
    );
  }
}
