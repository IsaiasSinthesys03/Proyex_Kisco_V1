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
      
      String result = url;
      // Para dispositivo físico, reemplazar localhost por la IP de la PC
      if (url.startsWith('http')) {
        result = url.replaceAll('localhost', '10.3.1.35')
                    .replaceAll('127.0.0.1', '10.3.1.35');
      } else {
        final path = url.startsWith('/') ? url : '/$url';
        result = '${AppConstants.baseUrl}$path';
      }

      print('🖼️ IMAGE DEBUG: Original: $url -> Result: $result');
      return result;
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
