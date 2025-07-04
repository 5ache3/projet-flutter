import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:projet/constants.dart';
import 'package:projet/services/database_service.dart';
import '../components/house_card_caller.dart';

class FeaturedController extends GetxController {
  final items = <dynamic>[].obs;
  final favorites = <String>[].obs;
  final isLoading = false.obs;

  final _storage = const FlutterSecureStorage();
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _initPage();
  }

  Future<void> refreshData() => _initPage();

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    _toggleFavoriteApi(id);
  }

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
    final fallbackData = await DatabaseService.instance.getHouses();
    final url = Uri.parse('$apiUrl/get');
    List<dynamic> fetchedData;
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        fetchedData = jsonDecode(res.body);
        items.value=fetchedData;
      } else {
        items.value = fallbackData;
        return;
      }
      await DatabaseService.instance.deleteAll();

      for (var i = 0; i < (fetchedData.length > 10 ? 10 : fetchedData.length); i++) {
        final house = fetchedData[i];
        final houseMap = {
          'id': house['id'],
          'admin_id': house['admin_id'],
          'description': house['description'],
          'price': house['price'],
          'rooms': house['rooms'],
          'surface': house['surface'],
          'type': house['type'],
          'location': house['location'],
          'ville': house['ville'],
          'region': house['region'],
        };

        final images = house['images'] != null ? List<String>.from(
            house['images']) : <String>[];

        await DatabaseService.instance.addHouse(houseMap, imageUrls: images);
      }
    } catch (e) {
      items.value = fallbackData;
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
      }
    } catch (e) {
      debugPrint('Fetch favorites failed: $e');
    }
  }

  Future<void> _toggleFavoriteApi(String houseId) async {
    if (_userId == null) return;
    final url = Uri.parse('$apiUrl/favorites/$_userId');

    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': _userId, 'house_id': houseId}),
      );
    } catch (e) {
      debugPrint('Toggle favorite API error: $e');
    }
  }
}














class Featured_page extends StatelessWidget {
  const Featured_page({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeaturedController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
          },
          child: ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, i) {
              final item = controller.items[i];
              final isFav = controller.favorites.contains(item['id']);

              return HouseCardCaller(
                file: item,
                isfav: isFav,
                onChange: controller.toggleFavorite,
              );
            },
          ),
        ),
      );
    });
  }
}
