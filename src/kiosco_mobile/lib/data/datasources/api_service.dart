import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';
import '../models/evaluation_template_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/Projects')); // Usando admin temporalmente
      
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
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Templates/active'));
      
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Evaluations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) return true;
      
      // Intentar extraer mensaje de error estructurado del backend
      final errorData = json.decode(response.body);
      print('Error del Servidor [${errorData['errorCode']}]: ${errorData['message']}');
      return false;
    } catch (e) {
      print('Error de Red: $e');
      return false;
    }
  }
}
