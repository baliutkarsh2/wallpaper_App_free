import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:shimmer/shimmer.dart';
import 'wallpaper_grid.dart';
import 'favorites_provider.dart';
import 'image_detail_screen.dart';
import 'theme_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import for launching URL

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToPremium() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showGoPremiumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.black.withOpacity(0.3),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  'Get access to our extensive gallery of 400+ Premium Wallpapers ad-free!',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _launchURL('https://www.google.com'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 1
              ? 'Premium Wallpapers'
              : _selectedIndex == 2
              ? 'Favorites'
              : '',
          style: GoogleFonts.montserrat(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : Colors.white,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness
              .dark,
        ),
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: GradientIcon(
                  icon: Icons.menu,
                  size: 30.0,
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.blue,
                      Colors.purple,
                      Colors.pink,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          if (_selectedIndex != 1) GestureDetector(
            onTap: _showGoPremiumDialog,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: Shimmer.fromColors(
                baseColor: Colors.amber,
                highlightColor: Colors.white,
                child: Text(
                  'PRO⭐',
                  style: GoogleFonts.montserrat(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                margin: EdgeInsets.only(bottom: 0),
                padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Wallpaper App',
                    style: GoogleFonts.montserrat(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildDrawerItem(
                  Icons.home_rounded, 'Home', 0, Colors.blue, Color(0xFFE0F7FA),
                  isDarkMode),
              _buildDrawerItem(
                  Icons.star_rounded, 'Premium', 1, Colors.amber, Color(0xFFFFF8E1),
                  isDarkMode),
              _buildDrawerItem(Icons.favorite_rounded, 'Favorites', 2, Colors.pink,
                  Color(0xFFFFEBEE), isDarkMode),
              _buildDrawerItem(Icons.settings_rounded, 'Settings', 3, Colors.green,
                  Color(0xFFE8F5E9), isDarkMode),

            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          WallpaperGrid(
            key: UniqueKey(),
            folder: 'wallpapers/free',
            title: 'Wallpaper App',
            isDarkMode: isDarkMode,
            showSubtitle: true,
          ),
          WallpaperGrid(
            key: UniqueKey(),
            folder: 'wallpapers/premium',
            title: '',
            isDarkMode: isDarkMode,
            showSubtitle: false,
          ),
          _buildFavoritesPage(),
          _buildSettingsPage(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
              color: _selectedIndex == 0
                  ? Colors.blue
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star_rounded,
              color: _selectedIndex == 1
                  ? Colors.amber
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
            label: 'Premium',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_rounded,
              color: _selectedIndex == 2
                  ? Colors.pink
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_rounded,
              color: _selectedIndex == 3
                  ? Colors.green
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
            label: 'Settings',
          ),
        ],
        selectedItemColor: _selectedIndex == 0
            ? Colors.blue
            : _selectedIndex == 1
            ? Colors.amber
            : _selectedIndex == 2
            ? Colors.pink
            : Colors.green,
        selectedLabelStyle: GoogleFonts.montserrat(),
        unselectedLabelStyle: GoogleFonts.montserrat(),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index,
      Color selectedColor, Color bubbleColor, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon,
          color: _selectedIndex == index ? selectedColor : (isDarkMode ? Colors
              .white : Colors.black)),
      title: Container(
        decoration: BoxDecoration(
          color: _selectedIndex == index ? bubbleColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            color: _selectedIndex == index ? selectedColor : (isDarkMode
                ? Colors.white
                : Colors.black),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildFavoritesPage() {
    return Scaffold(
      body: _buildFavoritesGrid(),
    );
  }

  Widget _buildFavoritesGrid() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        if (favoritesProvider.favorites.isEmpty) {
          return Center(child: Text('No favorites yet',
              style: GoogleFonts.montserrat(color: Colors.black)));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 9 / 16,
            ),
            itemCount: favoritesProvider.favorites.length,
            itemBuilder: (context, index) {
              final imageUrl = favoritesProvider.favorites[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageDetailScreen(imageUrl: imageUrl),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildSettingsPage(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Settings',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(
              'Dark Theme',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value);
            },
          ),
          ListTile(
            title: Text(
              'Rate the app',
              style: GoogleFonts.montserrat(
                color: isDarkMode ? Colors.white : Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => _launchURL('https://www.google.com'),
          ),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.montserrat(
                color: isDarkMode ? Colors.white : Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => _launchURL('https://www.google.com'),
          ),
          ListTile(
            title: Text(
              'Terms of Use',
              style: GoogleFonts.montserrat(
                color: isDarkMode ? Colors.white : Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => _launchURL('https://www.google.com'),
          ),
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  'Get access to our extensive gallery of 400+ Premium Wallpapers ad-free!',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _launchURL('https://www.google.com'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
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
        ],
      ),
    );
  }
}