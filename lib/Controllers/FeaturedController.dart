// lib/controllers/featured_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../constants.dart';

class FeaturedController extends GetxController {
  // ───────── STATE ─────────
  final items     = <dynamic>[].obs;
  final favorites = <String>[].obs;
  final isLoading = false.obs;

  final _storage = const FlutterSecureStorage();
  String? _userId;

  // ───────── LIFECYCLE ─────────
  @override
  void onInit() {
    super.onInit();
    print('🔄 FeaturedController started');
    _initPage();
  }

  // ───────── PUBLIC API ─────────
  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    _toggleFavoriteApi(id);
  }

  // ───────── INTERNAL ─────────
  Future<void> _initPage() async {
    try {
      isLoading.value = true;
      await _loadTokenData();
      await Future.wait([_fetchItems(), _fetchFavorites()]);
    } catch (e, st) {
      debugPrint('FeaturedController init failed: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTokenData() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return;
      final sub = JwtDecoder.decode(token)['sub'] as Map<String, dynamic>;
      _userId = sub['user_id']?.toString();
    } catch (e) {
      debugPrint('Token decode failed: $e');
    }
  }

  Future<void> _fetchItems() async {
    final fallbackJson = await rootBundle.loadString('assets/file.json');
    final url = Uri.parse('$apiUrl/get');

    try {
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        items.value = jsonDecode(res.body);
      } else {
        debugPrint('GET /get → ${res.statusCode}');
        items.value = jsonDecode(fallbackJson);
      }
    } catch (e) {
      debugPrint('Fetch items failed: $e');
      items.value = jsonDecode(fallbackJson);
    }
  }

  Future<void> _fetchFavorites() async {
    if (_userId == null) return;

    final url = Uri.parse('$apiUrl/favorites/$_userId');
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        favorites.value = data.map((e) => e['id'].toString()).toList();
      } else {
        debugPrint('GET /favorites → ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Fetch favorites failed: $e');
    }
  }

  Future<void> _toggleFavoriteApi(String houseId) async {
    if (_userId == null) return;
    final url = Uri.parse('$apiUrl/favorites/$_userId');
    try {
      await http
          .post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': _userId, 'house_id': houseId}))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Toggle favorite API error: $e');
    }
  }
}
