import 'package:flutter/material.dart';
import 'package:projet/pages/featured.dart';
import 'package:projet/pages/favorite.dart';
import 'package:projet/pages/publish_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _pages = [
    Featured_page(),
    Favorite_page(user_id: '1'),
    PublishPage(user_id: '1', user_role: 'user'),
  ];
  int _currentIndex = 0;
  String? user_id;
  String? user_role;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    await getTokenData();
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
        if (userId && user_role == 'admin') {
          _pages = [
            Featured_page(),
            Favorite_page(user_id: user_id!),
            PublishPage(user_id: user_id!, user_role: user_role!),
          ];
        } else if (userId) {
          _pages = [Featured_page(), Favorite_page(user_id: user_id!)];
        } else {
          _pages = [Featured_page()];
        }
      });
    }
  }

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
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create"),
        ],
      ),
    );
  }
}
