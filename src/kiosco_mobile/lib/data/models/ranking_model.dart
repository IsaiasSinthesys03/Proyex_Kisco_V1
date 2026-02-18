class RankingItem {
  final String id;
  final String title;
  final String category;
  final double averageScore;
  final int voteCount;

  RankingItem({
    required this.id,
    required this.title,
    required this.category,
    required this.averageScore,
    required this.voteCount,
  });

  factory RankingItem.fromJson(Map<String, dynamic> json) {
    return RankingItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      averageScore: (json['averageScore'] as num).toDouble(),
      voteCount: json['voteCount'] ?? 0,
    );
  }
}

class RankingResponse {
  final bool isPublic;
  final List<RankingItem> items;
  final String? message;

  RankingResponse({
    required this.isPublic,
    this.items = const [],
    this.message,
  });
}
