import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/api_service.dart';

class SyncService {
  static const String _queueKey = 'offline_evaluation_queue';

  static Future<void> addToQueue(Map<String, dynamic> evaluation) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    queue.add(json.encode(evaluation));
    await prefs.setStringList(_queueKey, queue);
  }

  static Future<void> syncQueue(ApiService apiService) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return;

    List<String> remaining = [];
    for (String item in queue) {
      final data = json.decode(item);
      bool success = await apiService.submitEvaluation(data);
      if (!success) {
        remaining.add(item);
      }
    }

    await prefs.setStringList(_queueKey, remaining);
  }
}
