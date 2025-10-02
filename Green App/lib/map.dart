// lib/map.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'firebase_options.dart';
import 'user_profile.dart';           // Back arrow ➜ profile
import 'plant1.dart';                 // Button ➜ TreeSelectionPage

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(25.354826, 51.183884),
    zoom: 7.5,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.background,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('trees').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final markers = <Marker>{};
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data();

                    GeoPoint? geo;
                    if (data['location'] is GeoPoint) {
                      geo = data['location'] as GeoPoint;
                    } else if (data['location'] is String) {
                      geo = _parseStringLatLng(data['location'] as String);
                    }
                    if (geo == null) continue;

                    final name = data['name'] as String? ?? 'Tree';
                    final dedication = data['dedication'] as String? ?? '';

                    markers.add(
                      Marker(
                        markerId: MarkerId(doc.id),
                        position: LatLng(geo.latitude, geo.longitude),
                        infoWindow: InfoWindow(
                          title: name,
                          snippet: dedication.isEmpty ? null : 'Dedicated to\u00a0$dedication',
                        ),
                      ),
                    );
                  }

                  return GoogleMap(
                    initialCameraPosition: _initialCameraPosition,
                    markers: markers,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (c) => _controller.complete(c),
                  );
                },
              ),
            ),
            const _PlantButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static GeoPoint? _parseStringLatLng(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^0-9.,-]'), '');
    final parts = cleaned.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lon = double.tryParse(parts[1]);
    if (lat == null || lon == null) return null;
    return GeoPoint(lat, lon);
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const UserProfilePage()),
              );
            },
            child: const Icon(Icons.arrow_back, size: 24, color: _Palette.textPrimary),
          ),
          const Spacer(),
          Text(
            'Gaia Trails',
            style: GoogleFonts.splineSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _Palette.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _PlantButton extends StatelessWidget {
  const _PlantButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TreeSelectionPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _Palette.buttonGreen,
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.park, color: _Palette.background),
          label: Text(
            'Plant a tree',
            style: GoogleFonts.splineSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _Palette.background,
            ),
          ),
        ),
      ),
    );
  }
}

class _Palette {
  static const background = Color(0xFFF8FCFA);
  static const textPrimary = Color(0xFF0C1C17);
  static const accentGreen = Color(0xFF46A080);
  static const iconBg = Color(0xFFE6F4EF);
  static const buttonGreen = Color(0xFF019863);
}
