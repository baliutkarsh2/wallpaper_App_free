import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'storage_service.dart';
import 'wallpaper.dart';
import 'image_detail_screen.dart';

class WallpaperGrid extends StatefulWidget {
  final String folder;
  final Key key;
  final String title;
  final bool isDarkMode;
  final bool showSubtitle;

  WallpaperGrid({
    required this.folder,
    required this.key,
    required this.title,
    required this.isDarkMode,
    this.showSubtitle = false,
  }) : super(key: key);

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
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          if (widget.showSubtitle)
            SliverAppBar(
              expandedHeight: 90.0,
              pinned: true,
              backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final top = constraints.biggest.height;
                  final showSubtitle = top > 60;
                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientText(
                          widget.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [
                            Colors.blue,
                            Colors.purple,
                            Colors.pink,
                          ],
                        ),
                        SizedBox(height: 4),
                        AnimatedOpacity(
                          opacity: showSubtitle ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 300),
                          child: Visibility(
                            visible: showSubtitle,
                            child: Text(
                              "Humongous collection of 2500+ Wallpapers!",
                              style: GoogleFonts.montserrat(
                                color: widget.isDarkMode ? Colors.white54 : Colors.black54,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    background: Container(
                      color: widget.isDarkMode ? Colors.black : Colors.white,
                    ),
                  );
                },
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: FutureBuilder<List<Wallpaper>>(
              future: _wallpapers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Shimmer.fromColors(
                        baseColor: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                        highlightColor: widget.isDarkMode ? Colors.grey[500]! : Colors.grey[100]!,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                            childAspectRatio: 3 / 4,
                          ),
                          itemCount: 8,
                          itemBuilder: (context, index) => Container(
                            margin: EdgeInsets.all(8.0),
                            color: widget.isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error loading wallpapers')),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('No wallpapers found')),
                  );
                } else {
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 3 / 4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
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
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                  highlightColor: widget.isDarkMode ? Colors.grey[500]! : Colors.grey[100]!,
                                  child: Container(
                                    color: widget.isDarkMode ? Colors.black : Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: snapshot.data!.length,
                    ),
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
