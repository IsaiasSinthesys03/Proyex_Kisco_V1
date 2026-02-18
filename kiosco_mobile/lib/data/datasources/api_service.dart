import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kiosco_mobile/core/constants.dart';
import 'package:kiosco_mobile/core/local_data_manager.dart';
import '../models/project_model.dart';
import '../models/evaluation_template_model.dart';
import '../models/ranking_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, String>> _getHeaders() async {
    final uuid = await LocalDataManager.getOrCreateUuid();
    return {
      'Content-Type': 'application/json',
      'X-Device-UUID': uuid,
    };
  }

  Future<List<ProjectModel>> getProjects() async {
    final url = '$baseUrl${AppConstants.projectsEndpoint}';
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ProjectModel.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar proyectos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  Future<EvaluationTemplateModel> getActiveTemplate() async {
    final url = '$baseUrl${AppConstants.templateEndpoint}';
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return EvaluationTemplateModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar la plantilla: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  Future<bool> submitEvaluation(Map<String, dynamic> data) async {
    final url = '$baseUrl${AppConstants.evaluateEndpoint}';
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<RankingResponse> getRanking() async {
    final url = '$baseUrl${AppConstants.rankingEndpoint}';
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('🌐 API DEBUG: Ranking Status Code: ${response.statusCode}');
      print('🌐 API DEBUG: Ranking Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        if (decoded is Map && decoded['status'] == 'hidden') {
          print('🌐 API DEBUG: Ranking is HIDDEN');
          return RankingResponse(
            isPublic: false, 
            message: decoded['message']
          );
        }
        
        if (decoded is List) {
          print('🌐 API DEBUG: Ranking is PUBLIC (${decoded.length} items)');
          final items = decoded.map((item) => RankingItem.fromJson(item)).toList();
          return RankingResponse(isPublic: true, items: items);
        }
        
        return RankingResponse(isPublic: false);
      } else {
        throw Exception('Error al cargar ranking: ${response.statusCode}');
      }
    } catch (e) {
      print('🌐 API DEBUG: ERROR en getRanking: $e');
      return RankingResponse(isPublic: false, message: e.toString());
    }
  }
}
