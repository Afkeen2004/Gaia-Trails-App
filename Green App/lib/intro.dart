// lib/intro.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'plant1.dart';
import 'user_profile.dart'; // back arrow ➜ UserProfilePage

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  Future<void> _launchFlagURL() async {
    final url = Uri.parse('https://www.google.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ⬇️ Back arrow now jumps straight to the profile page
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0C1C17)),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const UserProfilePage()),
                      );
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Gaia Trails',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0C1C17),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _launchFlagURL,
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.flag, color: Color(0xFF0C1C17), size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // ── Headline & description ───────────────────────────
              Column(
                children: [
                  Text(
                    '10,000+ trees planted in Worldwide',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0C1C17),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Join us in our mission to plant more trees and create a greener future for the World.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: const Color(0xFF0C1C17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF019863),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(160, 48),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TreeSelectionPage()),
                      );
                    },
                    child: Text(
                      'Donate Now',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8FCFA),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Our Impact',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0C1C17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: ImpactCard(title: 'CO₂ Saved', value: '500+ tons')),
                      SizedBox(width: 16),
                      Expanded(child: ImpactCard(title: 'Water Conserved', value: '200,000+ liters')),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImpactCard extends StatelessWidget {
  final String title;
  final String value;

  const ImpactCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 140,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCDE9DF)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0C1C17),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0C1C17),
            ),
          ),
        ],
      ),
    );
  }
}
