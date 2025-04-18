import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet/components/house_card.dart';

class Featured_page extends StatefulWidget {
  const Featured_page({super.key});

  @override
  State<Featured_page> createState() => _Featured_pageState();
}

class _Featured_pageState extends State<Featured_page> {
  List _items = [];
  @override
  void initState() {
    super.initState();
    readFile(); // Call the function when the widget is initialized
  }

  Future<void> readFile() async {
    final String response = await rootBundle.loadString('assets/file.json');
    final List<dynamic> data = json.decode(response); // Explicitly cast to List

    setState(() {
      _items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _items.isEmpty
        ? ElevatedButton(
          onPressed: () {
            readFile();
          },
          child: Center(child: Text("load ")),
        )
        : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: HouseCard(
                      id: _items[index]['id'],
                      surface: _items[index]['surface'],
                      adminid: _items[index]['adminid'],
                      region: _items[index]['region'],
                      ville: _items[index]['ville'],
                      type: _items[index]['type'],
                      location: _items[index]['location'],
                      price: _items[index]['price'],
                      images:
                          (_items[index]['images'] as List)
                              .map(
                                (img) => CustomImage(
                                  isMainImage: img['main'] ?? false,
                                  url: img['url'] ?? '',
                                ),
                              )
                              .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }
}
