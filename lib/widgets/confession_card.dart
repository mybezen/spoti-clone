import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/confession.dart';
import '../providers/confession_provider.dart';
import '../services/audio_player_service.dart';

class ConfessionCard extends StatelessWidget {
  final Confession confession;
  final AudioPlayerService audioPlayerService;
  final VoidCallback onUpdate;

  const ConfessionCard({
    super.key,
    required this.confession,
    required this.audioPlayerService,
    required this.onUpdate,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('dd MMM').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfessionProvider>(
      builder: (context, provider, _) {
        final isLiked = provider.likedConfessions.contains(confession.id);
        final track = confession.track;
        final isPlaying = audioPlayerService.currentPlayingId == track['id'] && 
                         audioPlayerService.isPlaying;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: const Color(0xFF181818),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Anonymous',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _formatTimestamp(confession.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Confession Text
                Text(
                  confession.text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
                
                // Tags
                if (confession.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: confession.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1DB954).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1DB954),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Song Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Album Art
                      if (track['imageUrl'] != '')
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Image.network(
                            track['imageUrl'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFF404040),
                              child: const Icon(Icons.music_note),
                            ),
                          ),
                        ),
                      
                      // Track Info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                track['artist'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Play Button
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (track['previewUrl'] == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.white),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Preview tidak tersedia. Buka di Spotify untuk dengar full.',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF282828),
                                    action: SnackBarAction(
                                      label: 'BUKA',
                                      textColor: Color(0xFF1DB954),
                                      onPressed: () async {
                                        final url = Uri.parse(track['spotifyUrl']);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                    ),
                                  ),
                                );
                                return;
                              }
                              audioPlayerService.playPauseTrack(
                                track['previewUrl'],
                                track['id'],
                                onUpdate,
                              );
                            },
                            icon: Icon(
                              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: track['previewUrl'] == null 
                                  ? Colors.grey 
                                  : const Color(0xFF1DB954),
                              size: 40,
                            ),
                          ),
                          if (track['previewUrl'] == null)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Spotify Link
                      IconButton(
                        onPressed: () async {
                          final url = Uri.parse(track['spotifyUrl']);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(
                          Icons.open_in_new,
                          color: Color(0xFF1DB954),
                          size: 20,
                        ),
                      ),
                      
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  children: [
                    // Like Button
                    IconButton(
                      onPressed: () {
                        provider.toggleLike(confession.id);
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[400],
                      ),
                    ),
                    Text(
                      '${confession.likes}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Comment Button
                    IconButton(
                      onPressed: () {
                        // TODO: Implement comments
                      },
                      icon: Icon(
                        Icons.comment_outlined,
                        color: Colors.grey[400],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Share Button
                    IconButton(
                      onPressed: () {
                        // TODO: Implement share
                      },
                      icon: Icon(
                        Icons.share,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}