import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/confession.dart';

class ConfessionProvider with ChangeNotifier {
  List<Confession> _confessions = [];
  Set<String> _likedConfessions = {};
  final Uuid _uuid = const Uuid();

  List<Confession> get confessions => _confessions;
  Set<String> get likedConfessions => _likedConfessions;

  ConfessionProvider() {
    _loadConfessions();
  }

  Future<void> _loadConfessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final confessionsJson = prefs.getStringList('confessions') ?? [];
      final likedJson = prefs.getStringList('liked') ?? [];
      
      _confessions = confessionsJson
          .map((json) => Confession.fromJson(jsonDecode(json)))
          .toList();
      _confessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _likedConfessions = likedJson.toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading confessions: $e');
    }
  }

  Future<void> _saveConfessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final confessionsJson = _confessions
          .map((confession) => jsonEncode(confession.toJson()))
          .toList();
      final likedJson = _likedConfessions.toList();
      
      await prefs.setStringList('confessions', confessionsJson);
      await prefs.setStringList('liked', likedJson);
    } catch (e) {
      debugPrint('Error saving confessions: $e');
    }
  }

  Future<void> addConfession(String text, Map<String, dynamic> track, List<String> tags) async {
    final confession = Confession(
      id: _uuid.v4(),
      text: text,
      track: track,
      timestamp: DateTime.now(),
      tags: tags,
    );
    
    _confessions.insert(0, confession);
    await _saveConfessions();
    notifyListeners();
  }

  Future<void> toggleLike(String confessionId) async {
    final index = _confessions.indexWhere((c) => c.id == confessionId);
    if (index != -1) {
      final confession = _confessions[index];
      
      if (_likedConfessions.contains(confessionId)) {
        _likedConfessions.remove(confessionId);
        _confessions[index] = confession.copyWith(likes: confession.likes - 1);
      } else {
        _likedConfessions.add(confessionId);
        _confessions[index] = confession.copyWith(likes: confession.likes + 1);
      }
      
      await _saveConfessions();
      notifyListeners();
    }
  }

  List<Confession> searchConfessions(String query) {
    if (query.isEmpty) return _confessions;
    
    final lowerQuery = query.toLowerCase();
    return _confessions.where((confession) {
      return confession.text.toLowerCase().contains(lowerQuery) ||
             confession.track['name'].toLowerCase().contains(lowerQuery) ||
             confession.track['artist'].toLowerCase().contains(lowerQuery) ||
             confession.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<Confession> getConfessionsByTag(String tag) {
    return _confessions.where((c) => c.tags.contains(tag)).toList();
  }

  List<String> getTrendingTags() {
    final tagCounts = <String, int>{};
    for (var confession in _confessions) {
      for (var tag in confession.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTags.take(10).map((e) => e.key).toList();
  }
}