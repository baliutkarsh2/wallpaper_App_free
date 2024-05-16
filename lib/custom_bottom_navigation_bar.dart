import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Color(0xFFB0C4DE), // Very light shade of dark blue
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black, // Customize as per your theme
          unselectedItemColor: Colors.black, // Customize as per your theme
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/home.png',
                height: 24,
                width: 24,
                color: currentIndex == 0 ? Colors.black : Colors.black,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/favorites.png',
                height: 24,
                width: 24,
                color: currentIndex == 1 ? Colors.red : Colors.black,
              ),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/premium.png',
                height: 24,
                width: 24,
                color: currentIndex == 2 ? Colors.black : Colors.black,
              ),
              label: 'Premium',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/settings.png',
                height: 24,
                width: 24,
                color: currentIndex == 3 ? Colors.black : Colors.black,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
