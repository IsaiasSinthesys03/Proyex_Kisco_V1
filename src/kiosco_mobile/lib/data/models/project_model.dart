import 'package:kiosco_mobile/core/constants.dart';
import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  ProjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.coverImageUrl,
    super.iconUrl,
    super.videoUrl,
    super.galleryUrls,
    super.documents,
    required super.status,
    required super.voteCount,
    super.companyName,
    super.teamMembers,
    super.objectives,
    super.techStack,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    String? makeAbsolute(String? url) {
      if (url == null || url.isEmpty) return null;
      
      // If it's already absolute, ensure it uses 127.0.0.1 instead of localhost
      // for proper ADB tunnel resolution on mobile.
      if (url.startsWith('http')) {
        return url.replaceFirst('localhost', '127.0.0.1');
      }
      
      // Ensure relative paths start with /
      final path = url.startsWith('/') ? url : '/$url';
      return '${AppConstants.baseUrl}$path';
    }

    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      coverImageUrl: makeAbsolute(json['coverImageUrl']),
      iconUrl: makeAbsolute(json['iconUrl']),
      videoUrl: makeAbsolute(json['videoUrl']),
      galleryUrls: (json['galleryUrls'] as List<dynamic>?)
              ?.map((e) => makeAbsolute(e.toString())!)
              .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => ProjectDocument(
                    title: e['title'] ?? '',
                    url: makeAbsolute(e['url']) ?? '',
                    type: e['type'] ?? 'pdf',
                  ))
              .toList() ??
          [],
      status: json['status'] ?? 'Active',
      // The backend has stats.voteCount based on the C# entity
      voteCount: json['stats']?['voteCount'] ?? json['voteCount'] ?? 0,
      companyName: json['companyName'],
      teamMembers: (json['teamMembers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      objectives: (json['objectives'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      techStack: (json['techStack'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
