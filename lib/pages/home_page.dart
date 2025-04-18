import 'package:flutter/material.dart';
import 'package:projet/pages/featured.dart';
import 'package:projet/pages/favorite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _pages = [Featured_page(), FavoritePage()];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("aqarmap"),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),

          BottomNavigationBarItem(
            icon: Icon(Icons.heart_broken),
            label: "Favorite",
          ),
        ],
      ),
    );
  }
}
