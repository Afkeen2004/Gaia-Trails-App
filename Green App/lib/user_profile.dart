// lib/user_profile.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'intro.dart';
import 'map.dart';
import 'setting.dart';

// ---------------------------------------------------------------------------
//  Colors
// ---------------------------------------------------------------------------
const kPageBg = Color(0xFFF8FCF8);
const kBlack = Color(0xFF0D1B0D);
const kGreen = Color(0xFF019863);
const kDivider = Color(0xFFE7F3E7);
const kBorder = Color(0xFFD1E6D9);

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionTitleStyle = GoogleFonts.splineSans(
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: kGreen,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.15,
      ),
    );
    final labelStyle = GoogleFonts.notoSans(
      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: kBlack,
        fontWeight: FontWeight.w700,
      ),
    );
    final infoStyle = GoogleFonts.notoSans(
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: kBlack),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
      FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userSnap.hasData || userSnap.data == null) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final data = userSnap.data!.data();

        final name = data?['name'] as String? ?? '—';
        final username = data?['username'] as String? ?? '—';
        final phone = data?['phone'] as String? ?? '—';
        final email = data?['email'] as String? ?? user.email ?? '—';
        final avatarUrl = data?['avatarUrl'] as String?;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('treesPlanted')
              .snapshots(),
          builder: (context, treeSnap) {
            if (treeSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: kPageBg,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!treeSnap.hasData || treeSnap.data == null) {
              return const Scaffold(
                backgroundColor: kPageBg,
                body: Center(child: Text('No trees data')),
              );
            }

            final treeDocs = treeSnap.data!.docs;
            final treesPlantedCount = treeDocs.length;

            // CO2 offset calculation: 630 kg per tree multiplied by number of trees
            final totalCo2Kg = treesPlantedCount * 630;

            return Scaffold(
              backgroundColor: kPageBg,
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Center(
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: sectionTitleStyle?.copyWith(color: kGreen),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                _Avatar(avatarUrl: avatarUrl, name: name),
                                const SizedBox(height: 12),
                                Text(
                                  name,
                                  style:
                                  sectionTitleStyle?.copyWith(fontSize: 22, color: kBlack),
                                ),
                                Text('@$username', style: infoStyle),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('My Impact', style: sectionTitleStyle),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 158,
                                  height: 120,
                                  child: _ImpactCard(
                                    label: 'Trees Planted',
                                    value: '$treesPlantedCount',
                                  ),
                                ),
                                SizedBox(
                                  width: 158,
                                  height: 120,
                                  child: _ImpactCard(
                                    label: 'CO₂ Offset',
                                    value: '${totalCo2Kg.toString()} kg',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _SectionTitle('Personal Details', sectionTitleStyle),
                            _InfoRow('Name', name, labelStyle, infoStyle),
                            _InfoRow('Phone Number', phone, labelStyle, infoStyle),
                            _InfoRow('Email', email, labelStyle, infoStyle),
                            const SizedBox(height: 16),
                            _SectionTitle('Trees Planted', sectionTitleStyle),
                            if (treesPlantedCount == 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('No trees planted yet.', style: infoStyle),
                              )
                            else
                              Column(
                                children: treeDocs
                                    .map((doc) {
                                  final treeData = doc.data();
                                  final displayName = treeData['dedicationName'] as String? ??
                                      treeData['name'] as String? ??
                                      'Unnamed Tree';
                                  return _SimpleItem(displayName, infoStyle);
                                })
                                    .toList(),
                              ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    const _BottomNav(currentIndex: 0),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, required this.name});
  final String? avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Container(
        height: 128,
        width: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(avatarUrl!),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 64,
      backgroundColor: kGreen.withOpacity(0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.splineSans(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: kGreen,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.style);
  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: style),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, this.labelStyle, this.valueStyle);
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  static const double _labelWidth = 120;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: kDivider)),
    ),
    child: Row(
      children: [
        SizedBox(width: _labelWidth, child: Text(label, style: labelStyle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class _SimpleItem extends StatelessWidget {
  const _SimpleItem(this.text, this.textStyle);
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: kDivider)),
    ),
    child: Row(
      children: [Expanded(child: Text(text, style: textStyle))],
    ),
  );
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 158,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: kBlack,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kBlack,
            letterSpacing: -0.015,
          ),
        ),
      ],
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex});
  final int currentIndex;

  static const _icons = [
    Icons.person,
    Icons.nature,
    Icons.map,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) => Material(
    color: kGreen,
    child: SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Row(
          children: List.generate(_icons.length, (i) {
            final isActive = i == currentIndex;
            return Expanded(
              child: IconButton(
                icon: Icon(
                  _icons[i],
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  if (i == currentIndex) return;
                  Widget page;
                  switch (i) {
                    case 0:
                      page = const UserProfilePage();
                      break;
                    case 1:
                      page = const IntroPage();
                      break;
                    case 2:
                      page = const MapPage();
                      break;
                    case 3:
                      page = const SettingsPage();
                      break;
                    default:
                      return;
                  }
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => page),
                  );
                },
              ),
            );
          }),
        ),
      ),
    ),
  );
}
