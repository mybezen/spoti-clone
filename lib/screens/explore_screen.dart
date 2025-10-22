import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/confession_provider.dart';
import '../services/audio_player_service.dart';
import '../widgets/confession_card.dart';

class ExploreScreen extends StatefulWidget {
  final AudioPlayerService audioPlayerService;

  const ExploreScreen({super.key, required this.audioPlayerService});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfessionProvider>(
      builder: (context, provider, _) {
        final trendingTags = provider.getTrendingTags();
        final confessions = _selectedTag == null
            ? provider.confessions
            : provider.getConfessionsByTag(_selectedTag!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending Tags Section
            if (trendingTags.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.whatshot,
                          color: Color(0xFF1DB954),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Trending Tags',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // All Tags Chip
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTag = null;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedTag == null
                                    ? const Color(0xFF1DB954)
                                    : const Color(0xFF282828),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Semua',
                                style: TextStyle(
                                  color: _selectedTag == null
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Trending Tags
                          ...trendingTags.map((tag) {
                            final isSelected = _selectedTag == tag;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTag = tag;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1DB954)
                                      : const Color(0xFF282828),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1DB954)
                                        : const Color(0xFF404040),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '#$tag',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.trending_up,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.black
                                          : const Color(0xFF1DB954),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(duration: 300.ms).slideX(
                                  begin: 0.2,
                                  end: 0,
                                );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF282828)),
            ],

            // Confessions List
            Expanded(
              child: confessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF282828),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedTag == null
                                  ? Icons.music_note
                                  : Icons.tag,
                              size: 60,
                              color: const Color(0xFF1DB954),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _selectedTag == null
                                ? 'Belum ada confess'
                                : 'Tidak ada confess dengan tag ini',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTag == null
                                ? 'Mulai share perasaanmu dengan lagu!'
                                : 'Coba tag lain',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: confessions.length,
                      itemBuilder: (context, index) {
                        return ConfessionCard(
                          confession: confessions[index],
                          audioPlayerService: widget.audioPlayerService,
                          onUpdate: () => setState(() {}),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
