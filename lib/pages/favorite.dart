import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet/components/house_card_caller.dart';
import 'package:http/http.dart' as http;
import 'package:projet/constants.dart';

class Favorite_page extends StatefulWidget {
  const Favorite_page({super.key});

  @override
  State<Favorite_page> createState() => _Favorite_pageState();
}

class _Favorite_pageState extends State<Favorite_page> {
  List _items = [];
  List _favorites = [];
  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
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

  Future<void> fetchFavorites() async {
    final int userId = 1;
    final url = Uri.parse('$apiUrl/favorites/$userId');

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
    final url = Uri.parse('$apiUrl/favorites/1');

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
    return _items.isEmpty
        ?
        // if no items found
        Text('no elements')
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
