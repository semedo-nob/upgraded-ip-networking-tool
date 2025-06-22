import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryStorage {
  static Future<String> getHistoryFilePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/history.json';
      print('History file path: $path');
      return path;
    } catch (e) {
      print('Error getting history file path: $e');
      rethrow;
    }
  }

  static Future<void> saveHistory(Map<String, dynamic> entry) async {
    try {
      final filePath = await getHistoryFilePath();
      final file = File(filePath);
      List<Map<String, dynamic>> history = [];

      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          final decoded = jsonDecode(content);
          if (decoded is List) {
            history = decoded
                .where((item) => item is Map)
                .cast<Map<dynamic, dynamic>>()
                .map((item) => item.cast<String, dynamic>())
                .toList();
          }
        } catch (e) {
          print('Corrupted history file, resetting: $e');
          history = [];
        }
      }

      history.insert(0, entry);
      await file.writeAsString(jsonEncode(history), flush: true);
      print('History saved to $filePath: ${history.length} entries');
    } catch (e) {
      print('Error saving history: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final filePath = await getHistoryFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final decoded = jsonDecode(content);
        if (decoded is List) {
          final history = decoded
              .where((item) => item is Map)
              .cast<Map<dynamic, dynamic>>()
              .map((item) => item.cast<String, dynamic>())
              .toList();
          print('Retrieved ${history.length} history entries');
          return history;
        }
      }
      print('No history file found or invalid data');
      return [];
    } catch (e) {
      print('Error reading history: $e');
      return [];
    }
  }
}