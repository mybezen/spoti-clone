import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingId;
  bool _isPlaying = false;

  AudioPlayer get player => _audioPlayer;
  String? get currentPlayingId => _currentPlayingId;
  bool get isPlaying => _isPlaying;

  AudioPlayerService() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _currentPlayingId = null;
        _isPlaying = false;
      }
    });
  }

  Future<void> playPauseTrack(
      String? previewUrl, String trackId, Function() onStateChange) async {
    if (previewUrl == null) {
      return;
    }

    try {
      if (_currentPlayingId == trackId && _isPlaying) {
        await _audioPlayer.pause();
      } else if (_currentPlayingId == trackId && !_isPlaying) {
        await _audioPlayer.play();
      } else {
        await _audioPlayer.setUrl(previewUrl);
        await _audioPlayer.play();
        _currentPlayingId = trackId;
      }
      onStateChange();
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPlayingId = null;
    _isPlaying = false;
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
