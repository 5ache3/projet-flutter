import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet/components/house_card_caller.dart';
import 'package:http/http.dart' as http;
import 'package:projet/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Favorite_page extends StatefulWidget {
  final String user_id;
  const Favorite_page({super.key,required this.user_id});

  @override
  State<Favorite_page> createState() => _Favorite_pageState();
}

class _Favorite_pageState extends State<Favorite_page> {
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
  final storage = FlutterSecureStorage();

  Future<void> getTokenData() async {
    String? token = await storage.read(key: 'token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token)['sub'];

      final userId = decodedToken['user_id'];
      final role = decodedToken['role'];
      setState(() {
        user_id=userId;
        user_role=role;
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

  Future<void> fetchData() async {
    final String fallbackData = await rootBundle.loadString('assets/file.json');
    final url = Uri.parse('$apiUrl/favorites/${user_id}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return (_items.isEmpty && user_id!=null)
        ?
        // if no items found
      Center(child: Text('no elements'),)

        // else we will show the list
        : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _favorites.contains(_items[index]['id'])
                      ? HouseCardCaller(
                        file: _items[index],
                        isfav: _favorites.contains(_items[index]['id']),
                        onChange: onChange,
                      )
                      : const SizedBox();
                },
              ),
            ),
          ],
        );
  }
}
