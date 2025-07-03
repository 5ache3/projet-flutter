import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:projet/components/house_card_caller.dart';
import 'package:http/http.dart' as http;
import 'package:projet/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class FavoritePageController extends GetxController {
  List _items = [];
  List _favorites = [];
  String? user_id;
  String? user_role;
  final storage = const FlutterSecureStorage();
  final String passedUserId;
  FavoritePageController(this.passedUserId);
  @override
  void onInit() {
    super.onInit();
    initPage();
  }
  Future<void> initPage() async {
    await getTokenData();
    await fetchFavorites();
    await fetchData();
  }
  void onChange(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    update();
  }
  Future<void> getTokenData() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token)['sub'];
      final userId = decodedToken['user_id'];
      final role = decodedToken['role'];
      user_id = userId;
      user_role = role;
    } else {
      user_id = passedUserId;
    }
    update();
  }
  Future<void> fetchFavorites() async {
    if (user_id == null) return;
    final url = Uri.parse('$apiUrl/favorites/$user_id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _favorites = data.map((item) => item['id']).toList();
      }
    } catch (_) {}
    update();
  }
  Future<void> fetchData() async {
    if (user_id == null) return;
    final String fallbackData = await rootBundle.loadString('assets/file.json');
    final url = Uri.parse('$apiUrl/favorites/$user_id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _items = data;
        update();
        return;
      }
    } catch (_) {}
    final List<dynamic> data = jsonDecode(fallbackData);
    _items = data;
    update();
  }
}

class Favorite_page extends StatelessWidget {
  final String user_id;
  const Favorite_page({super.key, required this.user_id});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoritePageController>(
      init: FavoritePageController(user_id),
      builder: (controller) {
        return (controller._items.isEmpty && controller.user_id != null)
            ? const Center(child: Text('no elements'))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller._items.length,
                itemBuilder: (context, index) {
                  return controller._favorites.contains(controller._items[index]['id'])
                      ? HouseCardCaller(
                    file: controller._items[index],
                    isfav: controller._favorites.contains(controller._items[index]['id']),
                    onChange: controller.onChange,
                  )
                      : const SizedBox();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
