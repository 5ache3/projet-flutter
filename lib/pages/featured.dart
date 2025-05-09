import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet/components/house_card_caller.dart';
import 'package:http/http.dart' as http;
import 'package:projet/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Featured_page extends StatefulWidget {
  const Featured_page({super.key});

  @override
  State<Featured_page> createState() => _Featured_pageState();
}

class _Featured_pageState extends State<Featured_page> {
  List _items = [];
  List _favorites = [];
  String? user_id;
  String? user_role;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    await getTokenData();
    await fetchFavorites();
    await fetchData();
  }

  final storage = FlutterSecureStorage();

  Future<void> getTokenData() async {
    String? token = await storage.read(key: 'token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token)['sub'];

      final userId = decodedToken['user_id'];
      final role = decodedToken['role'];
      setState(() {
        user_id = userId;
        user_role = role;
      });
    }
  }

  Future<void> fetchData() async {
    final String fallbackData = await rootBundle.loadString('assets/file.json');
    final url = Uri.parse('$apiUrl/get');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _items = data;
        });
      } else {
        final List<dynamic> data = jsonDecode(fallbackData);
        setState(() {
          _items = data;
        });
      }
    } catch (e) {
      print('Error: $e');
      final List<dynamic> data = jsonDecode(fallbackData);
      setState(() {
        _items = data;
      });
    }
  }

  void onChange(String id) {
    if (_favorites.contains(id)) {
      setState(() {
        _favorites.remove(id);
      });
    } else {
      setState(() {
        _favorites.add(id);
      });
    }
  }

  Future<void> fetchFavorites() async {
    final url = Uri.parse('$apiUrl/favorites/${user_id}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _favorites = data.map((item) => item['id']).toList();
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return HouseCardCaller(
                file: _items[index],
                isfav: _favorites.contains(_items[index]['id']),
                onChange: onChange,
              );
            },
          ),
        ),
      ],
    );
  }
}
