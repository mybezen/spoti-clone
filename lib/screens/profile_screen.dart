import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/confession_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfessionProvider>(
      builder: (context, provider, _) {
        final totalConfessions = provider.confessions.length;
        final totalLikes = provider.confessions.fold(0, (sum, c) => sum + c.likes);
        final myLikes = provider.likedConfessions.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DB954).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.black,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 20),
              
              // Username
              Text(
                'Anonymous User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 8),
              
              Text(
                'Sharing feelings through music 🎵',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 30),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.music_note,
                      label: 'Confessions',
                      value: totalConfessions.toString(),
                      color: const Color(0xFF1DB954),
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.favorite,
                      label: 'Total Likes',
                      value: totalLikes.toString(),
                      color: Colors.red,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.favorite_border,
                      label: 'Liked',
                      value: myLikes.toString(),
                      color: Colors.pink,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2, end: 0),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Menu Options
              _buildMenuSection(context, provider),
              
              const SizedBox(height: 30),
              
              // About Section
              _buildAboutSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, ConfessionProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: 'My Confessions',
            subtitle: '${provider.confessions.length} posts',
            onTap: () {
              // TODO: Navigate to my confessions
            },
          ),
          const Divider(height: 1, color: Color(0xFF282828)),
          _buildMenuItem(
            icon: Icons.favorite,
            title: 'Liked Confessions',
            subtitle: '${provider.likedConfessions.length} likes',
            onTap: () {
              // TODO: Navigate to liked confessions
            },
          ),
          const Divider(height: 1, color: Color(0xFF282828)),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Preferences & privacy',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          const Divider(height: 1, color: Color(0xFF282828)),
          _buildMenuItem(
            icon: Icons.delete_outline,
            title: 'Clear All Data',
            subtitle: 'Delete all confessions',
            iconColor: Colors.red,
            onTap: () {
              _showClearDataDialog(context, provider);
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF1DB954)).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF1DB954),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[400],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                color: const Color(0xFF1DB954),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Songfess',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Share your feelings anonymously with music\nPowered by Spotify API',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0);
  }

  void _showClearDataDialog(BuildContext context, ConfessionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your confessions and liked posts. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement clear all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: Color(0xFF1DB954),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}