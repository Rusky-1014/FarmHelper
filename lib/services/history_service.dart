import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_record.dart';

class HistoryService {
  static const _key = 'scan_history';

  static Future<void> saveRecord(ScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getHistory();
    existing.insert(0, record); // newest first
    final encoded = jsonEncode(existing.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<ScanRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ScanRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}