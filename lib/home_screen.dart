import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'wallpaper_grid.dart';
import 'favorites_provider.dart';
import 'image_detail_screen.dart';
import 'theme_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 2 ? 'Premium Wallpapers' : _selectedIndex == 1 ? 'Favorites' : 'Free Walls',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: Builder(
          builder: (context) => IconButton(
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
              _buildDrawerItem(Icons.home, 'Home', 0, Colors.blue, Color(0xFFE0F7FA), isDarkMode),
              _buildDrawerItem(Icons.favorite, 'Favorites', 1, Colors.pink, Color(0xFFFFEBEE), isDarkMode),
              _buildDrawerItem(Icons.star, 'Premium', 2, Colors.amber, Color(0xFFFFF8E1), isDarkMode),
              _buildDrawerItem(Icons.settings, 'Settings', 3, Colors.green, Color(0xFFE8F5E9), isDarkMode),
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
          ),
          _buildFavoritesPage(),
          WallpaperGrid(
            key: UniqueKey(),
            folder: 'wallpapers/premium',
            title: 'Premium Wallpapers',
            isDarkMode: isDarkMode,
          ),
          _buildSettingsPage(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.pink),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star, color: Colors.amber),
            label: 'Premium',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.green),
            label: 'Settings',
          ),
        ],
        selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, Color selectedColor, Color bubbleColor, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? selectedColor : (isDarkMode ? Colors.white : Colors.black)),
      title: Container(
        decoration: BoxDecoration(
          color: _selectedIndex == index ? bubbleColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            color: _selectedIndex == index ? selectedColor : (isDarkMode ? Colors.white : Colors.black),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Favorites',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        Expanded(child: _buildFavoritesGrid()),
      ],
    );
  }

  Widget _buildFavoritesGrid() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        if (favoritesProvider.favorites.isEmpty) {
          return Center(child: Text('No favorites yet', style: GoogleFonts.montserrat()));
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
                      builder: (context) => ImageDetailScreen(imageUrl: imageUrl),
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
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
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

    return Column(
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
      ],
    );
  }
}
