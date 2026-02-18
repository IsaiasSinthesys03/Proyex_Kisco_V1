import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  ProjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.coverImageUrl,
    required super.status,
    required super.voteCount,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      coverImageUrl: json['coverImageUrl'],
      status: json['status'] ?? 'Active',
      voteCount: json['voteCount'] ?? 0,
    );
  }
}
