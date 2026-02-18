class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? coverImageUrl;
  final String status;
  final int voteCount;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.coverImageUrl,
    required this.status,
    required this.voteCount,
  });
}
