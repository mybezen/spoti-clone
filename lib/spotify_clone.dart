// File: spotify_clone.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

// Models
class SpotifyTrack {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String? imageUrl;
  final int durationMs;
  final String? previewUrl;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    this.imageUrl,
    required this.durationMs,
    this.previewUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artist: json['artists'] != null && json['artists'].isNotEmpty
          ? json['artists'][0]['name']
          : 'Unknown Artist',
      album: json['album']?['name'] ?? 'Unknown Album',
      imageUrl: json['album']?['images'] != null &&
              json['album']['images'].isNotEmpty
          ? json['album']['images'][0]['url']
          : null,
      durationMs: json['duration_ms'] ?? 0,
      previewUrl: json['preview_url'],
    );
  }

  String get duration {
    int seconds = (durationMs / 1000).round();
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class SpotifyPlaylist {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int totalTracks;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.totalTracks,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      description: json['description'],
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['url']
          : null,
      totalTracks: json['tracks']?['total'] ?? 0,
    );
  }
}

// Spotify API Service
class SpotifyService {
  static const String clientId = 'e005495a773b483f96dff85f98da24ab';
  static const String clientSecret = 'dc3d83e492484ebe86af3ed19e32c4b2';
  static String? _accessToken;
  static DateTime? _tokenExpiry;

  static Future<String?> getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in']));
        return _accessToken;
      }
    } catch (e) {
      print('Error getting access token: $e');
    }
    return null;
  }

  // Search Indonesian music
  static Future<List<SpotifyTrack>> searchIndonesianMusic(String genre) async {
    final token = await getAccessToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=$genre%20indonesia&type=track&market=ID&limit=20'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tracks = data['tracks']['items'] as List;
        return tracks.map((track) => SpotifyTrack.fromJson(track)).toList();
      }
    } catch (e) {
      print('Error searching tracks: $e');
    }
    return [];
  }

  // Get Indonesian playlists
  static Future<List<SpotifyPlaylist>> getIndonesianPlaylists() async {
    final token = await getAccessToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=indonesia&type=playlist&market=ID&limit=20'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final playlists = data['playlists']['items'] as List;
        return playlists
            .map((playlist) => SpotifyPlaylist.fromJson(playlist))
            .toList();
      }
    } catch (e) {
      print('Error getting playlists: $e');
    }
    return [];
  }

  // Search tracks
  static Future<List<SpotifyTrack>> searchTracks(String query) async {
    final token = await getAccessToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=$query&type=track&market=ID&limit=20'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tracks = data['tracks']['items'] as List;
        return tracks.map((track) => SpotifyTrack.fromJson(track)).toList();
      }
    } catch (e) {
      print('Error searching tracks: $e');
    }
    return [];
  }

  // Get Indonesian pop music
  static Future<List<SpotifyTrack>> getIndonesianPop() async {
    return await searchIndonesianMusic('pop');
  }

  // Get Indonesian rock music
  static Future<List<SpotifyTrack>> getIndonesianRock() async {
    return await searchIndonesianMusic('rock');
  }

  // Get Indonesian dangdut music
  static Future<List<SpotifyTrack>> getIndonesianDangdut() async {
    return await searchIndonesianMusic('dangdut');
  }
}

class SpotifyClone extends StatefulWidget {
  const SpotifyClone({super.key});

  @override
  State<SpotifyClone> createState() => _SpotifyCloneState();
}

class _SpotifyCloneState extends State<SpotifyClone> {
  int _selectedIndex = 0;
  SpotifyTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _showFullPlayer = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  List<SpotifyTrack> _popTracks = [];
  List<SpotifyTrack> _rockTracks = [];
  List<SpotifyTrack> _dangdutTracks = [];
  List<SpotifyPlaylist> _playlists = [];
  List<SpotifyTrack> _searchResults = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        SpotifyService.getIndonesianPop(),
        SpotifyService.getIndonesianRock(),
        SpotifyService.getIndonesianDangdut(),
        SpotifyService.getIndonesianPlaylists(),
      ]);

      setState(() {
        _popTracks = results[0] as List<SpotifyTrack>;
        _rockTracks = results[1] as List<SpotifyTrack>;
        _dangdutTracks = results[2] as List<SpotifyTrack>;
        _playlists = results[3] as List<SpotifyPlaylist>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    final results = await SpotifyService.searchTracks(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _playTrack(SpotifyTrack track) async {
    if (track.previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview tidak tersedia untuk lagu ini 😢'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(track.previewUrl!));
      setState(() {
        _currentTrack = track;
        _isPlaying = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memutar lagu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _showPlayer() {
    setState(() {
      _showFullPlayer = true;
    });
  }

  void _hidePlayer() {
    setState(() {
      _showFullPlayer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBody(),
          if (_currentTrack != null && !_showFullPlayer) _buildMiniPlayer(),
          if (_showFullPlayer) _buildFullPlayer(),
        ],
      ),
      bottomNavigationBar: _showFullPlayer ? null : _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildSearchPage();
      case 2:
        return _buildLibraryPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.black,
          floating: true,
          title: const Text(
            'Musik Indonesia 🇮🇩',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indonesian Playlists
                      if (_playlists.isNotEmpty) ...[
                        const Text(
                          '🎵 Playlist Indonesia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _playlists.length,
                            itemBuilder: (context, index) {
                              return _buildPlaylistCard(_playlists[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Pop Indonesia
                      if (_popTracks.isNotEmpty) ...[
                        const Text(
                          '🎤 Pop Indonesia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _popTracks.length,
                            itemBuilder: (context, index) {
                              return _buildTrackCard(_popTracks[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Rock Indonesia
                      if (_rockTracks.isNotEmpty) ...[
                        const Text(
                          '🎸 Rock Indonesia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _rockTracks.length,
                            itemBuilder: (context, index) {
                              return _buildTrackCard(_rockTracks[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Dangdut
                      if (_dangdutTracks.isNotEmpty) ...[
                        const Text(
                          '💃 Dangdut Hits',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _dangdutTracks.length,
                            itemBuilder: (context, index) {
                              return _buildTrackCard(_dangdutTracks[index]);
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistCard(SpotifyPlaylist playlist) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: playlist.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      playlist.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.library_music,
                          size: 60,
                          color: Colors.white54,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.library_music,
                    size: 60,
                    color: Colors.white54,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(SpotifyTrack track) {
    return GestureDetector(
      onTap: () => _playTrack(track),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  track.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            track.imageUrl!,
                            fit: BoxFit.cover,
                            width: 160,
                            height: 160,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.music_note,
                                size: 60,
                                color: Colors.white54,
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.music_note,
                            size: 60,
                            color: Colors.white54,
                          ),
                        ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              track.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              track.artist,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cari Musik',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Artis, lagu, atau album Indonesia',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            else if (_searchResults.isEmpty && _searchController.text.isEmpty)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildGenreCard('Pop Indonesia', Colors.pink),
                    _buildGenreCard('Rock Indonesia', Colors.red),
                    _buildGenreCard('Dangdut', Colors.orange),
                    _buildGenreCard('Indie Indonesia', Colors.purple),
                    _buildGenreCard('R&B Indonesia', Colors.blue),
                    _buildGenreCard('Rap Indonesia', Colors.green),
                  ],
                ),
              )
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Tidak ada hasil',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildTrackListItem(_searchResults[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreCard(String name, Color color) {
    return GestureDetector(
      onTap: () {
        _searchController.text = name;
        _search(name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryPage() {
    final allTracks = [..._popTracks, ..._rockTracks, ..._dangdutTracks];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Library Kamu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
              ],
            ),
          ),
          if (allTracks.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Library masih kosong',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: allTracks.length,
                itemBuilder: (context, index) {
                  return _buildTrackListItem(allTracks[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackListItem(SpotifyTrack track) {
    final isCurrentTrack = _currentTrack?.id == track.id;
    
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            track.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      track.imageUrl!,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.music_note, color: Colors.white54);
                      },
                    ),
                  )
                : const Icon(Icons.music_note, color: Colors.white54),
            if (isCurrentTrack && _isPlaying)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Icon(
                    Icons.graphic_eq,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
      title: Text(
        track.name,
        style: TextStyle(
          color: isCurrentTrack ? Colors.green : Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${track.artist} • ${track.album}',
        style: TextStyle(
          color: isCurrentTrack ? Colors.green.shade300 : Colors.grey.shade400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.duration,
            style: TextStyle(color: Colors.grey.shade400),
          ),
          IconButton(
            icon: Icon(
              track.previewUrl != null ? Icons.play_circle : Icons.not_interested,
              color: track.previewUrl != null ? Colors.white : Colors.grey,
            ),
            onPressed: () => _playTrack(track),
          ),
        ],
      ),
      onTap: () => _playTrack(track),
    );
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 80,
      child: GestureDetector(
        onTap: _showPlayer,
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.grey.shade800],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _currentTrack!.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          _currentTrack!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.music_note, color: Colors.white);
                          },
                        ),
                      )
                    : const Icon(Icons.music_note, color: Colors.white),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTrack!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _currentTrack!.artist,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullPlayer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade900,
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                    onPressed: _hidePlayer,
                  ),
                  Column(
                    children: [
                      const Text(
                        'PLAYING FROM',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentTrack!.album,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Album Art
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: _currentTrack!.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _currentTrack!.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.music_note,
                              size: 120,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.music_note,
                        size: 120,
                        color: Colors.white54,
                      ),
                    ),
            ),
            
            const SizedBox(height: 40),
            
            // Song Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTrack!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentTrack!.artist,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        iconSize: 28,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Progress Bar
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade700,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _currentPosition.inSeconds.toDouble(),
                          max: _totalDuration.inSeconds > 0
                              ? _totalDuration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) async {
                            await _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.grey),
                        iconSize: 28,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        iconSize: 40,
                        onPressed: () {},
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                          ),
                          iconSize: 40,
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        iconSize: 40,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: Colors.grey),
                        iconSize: 28,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bottom Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.devices, color: Colors.grey),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey.shade900),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }
}