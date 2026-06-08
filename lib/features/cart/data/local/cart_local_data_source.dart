import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart_item.dart';

class CartLocalDataSource {
  static const _key = 'gmg_cart_v1';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<List<CartItem>> load() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => CartItem.fromLocalJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<CartItem> items) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_key, jsonEncode(items.map((e) => e.toLocalJson()).toList()));
    } catch (_) {}
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}
