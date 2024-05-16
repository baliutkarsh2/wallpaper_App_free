import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA2jxniXLnZdL6iPMsAZ-cjDtKqGM633_w",
      appId: "1:787615125402:android:ea66483f3f43892fb17423",
      messagingSenderId: "787615125402",
      projectId: "sum1-b6b1d",
      storageBucket: "sum1-b6b1d.appspot.com",
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper App',
      theme: ThemeData(
        primaryColor: Colors.black,
        hintColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black87,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
