import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/spotify_service.dart';
import '../services/audio_player_service.dart';
import 'feed_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'create_confession_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SpotifyService _spotifyService;
  late AudioPlayerService _audioPlayerService;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // GANTI DENGAN CLIENT ID DAN SECRET ANDA
    _spotifyService = SpotifyService(
      clientId: 'e005495a773b483f96dff85f98da24ab',
      clientSecret: 'dc3d83e492484ebe86af3ed19e32c4b2',
    );

    _audioPlayerService = AudioPlayerService();
  }

  @override
  void dispose() {
    _audioPlayerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.music_note, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Songfess',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          FeedScreen(
            spotifyService: _spotifyService,
            audioPlayerService: _audioPlayerService,
          ),
          ExploreScreen(audioPlayerService: _audioPlayerService),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateConfessionScreen(
                      spotifyService: _spotifyService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: Text(
                'Confess',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFF1DB954),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF181818),
        indicatorColor: const Color(0xFF1DB954).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1DB954)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: Color(0xFF1DB954)),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF1DB954)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
