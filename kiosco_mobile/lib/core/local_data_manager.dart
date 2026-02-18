import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalDataManager {
  static const String _uuidKey = 'user_uuid';
  static const String _votedKey = 'voted_projects';
  static const String _draftKey = 'evaluation_draft_';

  static Future<String> getOrCreateUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_uuidKey);
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString(_uuidKey, uuid);
    }
    return uuid;
  }

  static Future<bool> hasVoted(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> voted = prefs.getStringList(_votedKey) ?? [];
    return voted.contains(projectId);
  }

  static Future<void> markAsVoted(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> voted = prefs.getStringList(_votedKey) ?? [];
    if (!voted.contains(projectId)) {
      voted.add(projectId);
      await prefs.setStringList(_votedKey, voted);
    }
  }

  static Future<void> saveDraft(String projectId, Map<String, int> answers) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert Map to JSON string
    final data = answers.map((key, value) => MapEntry(key, value.toString()));
    await prefs.setString(_draftKey + projectId, data.toString());
  }

  static Future<void> clearDraft(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey + projectId);
  }
}
