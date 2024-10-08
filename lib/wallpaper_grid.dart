import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:blur/blur.dart';
import 'package:url_launcher/url_launcher.dart';
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
    this.showSubtitle = true,
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

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              if (widget.showSubtitle) // Show SliverAppBar only if showSubtitle is true
                SliverAppBar(
                  expandedHeight: 90.0,
                  pinned: true,
                  backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final top = constraints.biggest.height;
                      final showSubtitle = top > 80;
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
                            SizedBox(height: 4), // Added line spacing
                            AnimatedOpacity(
                              opacity: showSubtitle ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: Visibility(
                                visible: showSubtitle,
                                child: Text(
                                  "Discover a diverse collection of wallpapers",
                                  style: GoogleFonts.montserrat(
                                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
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
                                crossAxisCount: 2, // Number of columns
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                                childAspectRatio: 9 / 16, // Aspect ratio for rectangles with longer height
                              ),
                              itemCount: 8, // Number of shimmer placeholders
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
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 9 / 16, // Aspect ratio for rectangles with longer height
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
          if (!widget.showSubtitle) // Show overlay only on premium page
            Positioned.fill(
              child: Stack(
                children: [
                  Blur(
                    blur: 0.0,
                    colorOpacity: 0.0,
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Go',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.amber,
                            highlightColor: Colors.white,
                            child: Text(
                              'Premium',
                              style: GoogleFonts.montserrat(
                                color: Colors.amber,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Get access to our extensive gallery of 400+ Premium Wallpapers',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _launchURL('https://play.google.com/store/apps/details?id=com.ub.sum1.sum1'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            ),
                            child: Text(
                              'Buy now for \$1',
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
