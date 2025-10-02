import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'intro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StitchDesignApp());
}

class StitchDesignApp extends StatelessWidget {
  const StitchDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stitch Design',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.splineSansTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FBFA),
      ),
      home: const StitchHomePage(),
    );
  }
}

class StitchHomePage extends StatelessWidget {
  const StitchHomePage({super.key});

  void _goToIntroPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IntroPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 650,
            width: double.infinity,
            child: Image.network(
              "https://lh3.googleusercontent.com/aida-public/AB6AXuApwxXvcSdWpjdLbWwNCWn0wzwRnzRu9wD6mzj4_va1v0kVyNj5o8jKGjh08R8rxms-p0PxAzm74cxOHHeUF5I17xasbzx3YD43wFRU_2CTf6MCiLcgWJRWsdfmjc5fIqNn-rkDxN_tc6YRMhORyh5WQBoYHk9fobG14Btak36KQQa1ZiAH3EZYCxSqIJ6-iH7b2Xgroiqg3cm4FJndJ4tBQMm0KrZwepwQkigE7FBVu6UcfVr8yfv7Bex-vyIYnocKUMshGv6J6WyP",
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFFF9FBFA),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Text(
                  'Change the planet with a single tap.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF121714),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _goToIntroPage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF019863),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(84, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Plant a Tree',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.015,
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
