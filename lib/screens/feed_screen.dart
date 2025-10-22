import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/confession_provider.dart';
import '../services/spotify_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/confession_card.dart';

class FeedScreen extends StatefulWidget {
  final SpotifyService spotifyService;
  final AudioPlayerService audioPlayerService;

  const FeedScreen({
    super.key,
    required this.spotifyService,
    required this.audioPlayerService,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Cari confess, lagu, atau artis...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1DB954)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF282828),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Feed List
        Expanded(
          child: Consumer<ConfessionProvider>(
            builder: (context, provider, _) {
              final confessions = _searchController.text.isEmpty
                  ? provider.confessions
                  : provider.searchConfessions(_searchController.text);

              if (confessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282828),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 60,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Belum ada confess'
                            : 'Tidak ada hasil',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Mulai share perasaanmu dengan lagu!'
                            : 'Coba kata kunci lain',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: confessions.length,
                itemBuilder: (context, index) {
                  return ConfessionCard(
                    confession: confessions[index],
                    audioPlayerService: widget.audioPlayerService,
                    onUpdate: () => setState(() {}),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}