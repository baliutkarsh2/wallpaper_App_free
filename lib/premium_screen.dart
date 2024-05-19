import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  void _launchURL() async {
    const url = 'https://www.google.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Go Premium',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/animation.gif",
              height: 512.0,
              width: 512.0,
            ),
            ElevatedButton(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                primary: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Buy Premium on Google Play Store',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  }
}
