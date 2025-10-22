class Confession {
  final String id;
  final String text;
  final Map<String, dynamic> track;
  final DateTime timestamp;
  final int likes;
  final List<String> tags;

  Confession({
    required this.id,
    required this.text,
    required this.track,
    required this.timestamp,
    this.likes = 0,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'track': track,
        'timestamp': timestamp.toIso8601String(),
        'likes': likes,
        'tags': tags,
      };

  factory Confession.fromJson(Map<String, dynamic> json) => Confession(
        id: json['id'],
        text: json['text'],
        track: json['track'],
        timestamp: DateTime.parse(json['timestamp']),
        likes: json['likes'] ?? 0,
        tags: List<String>.from(json['tags'] ?? []),
      );

  Confession copyWith({int? likes}) => Confession(
        id: id,
        text: text,
        track: track,
        timestamp: timestamp,
        likes: likes ?? this.likes,
        tags: tags,
      );
}
