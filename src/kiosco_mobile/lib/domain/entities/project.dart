class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? coverImageUrl;
  final String? iconUrl;
  final String? videoUrl;
  final List<String> galleryUrls;
  final List<ProjectDocument> documents;
  final String status;
  final int voteCount;

  final String? companyName;
  final List<String> teamMembers;
  final List<String> objectives;
  final List<String> techStack;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.coverImageUrl,
    this.iconUrl,
    this.videoUrl,
    this.galleryUrls = const [],
    this.documents = const [],
    required this.status,
    required this.voteCount,
    this.companyName,
    this.teamMembers = const [],
    this.objectives = const [],
    this.techStack = const [],
  });
}

class ProjectDocument {
  final String title;
  final String url;
  final String type;

  ProjectDocument({
    required this.title,
    required this.url,
    required this.type,
  });
}
