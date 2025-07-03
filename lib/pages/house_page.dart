import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet/components/imagesSlider.dart';
import 'package:projet/modals/CustomImage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projet/constants.dart';
import 'package:projet/pages/auth/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:projet/pages/home_page.dart';

class Room {
  final String type;
  final List<CustomImage> images;
  Room({required this.type, required this.images});
}

class HousePage extends StatefulWidget {
  final String id;
  final String surface;
  final String admin_id;
  final String region;
  final String ville;
  final String type;
  final String location;
  final String price;
  final List<CustomImage> images;
  final bool isfav;
  final onChange;
  // final List<Room> rooms;

  const HousePage({
    Key? key,
    required this.id,
    required this.surface,
    required this.admin_id,
    required this.region,
    required this.ville,
    required this.type,
    required this.location,
    required this.price,
    required this.images,
    required this.isfav,
    this.onChange,
    // required this.rooms,
  }) : super(key: key);

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  late bool _fav;
  String? user_id;
  String? user_role;
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
    } else {
      setState(() {
        user_id = "Not logged in";
        user_role = "guest";
      });
    }
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'token');
  }

  Future<void> deleteHouse() async {
    final url = Uri.parse('$apiUrl/delete_house/${widget.id}');

    try{
      final response=await http.delete(url);
      if (response.statusCode == 200){
        Navigator.pop(context);
      }
    }catch(e){
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    _fav = widget.isfav;
    getTokenData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("aqarmap"),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                user_role == 'admin'
                    ? Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _Title('Admin Options'),
                          Padding(
                            padding: EdgeInsets.only(left: 70, right: 20),
                            child: FloatingActionButton(
                              onPressed: () => {},
                              child: Icon(Icons.edit),
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: deleteHouse,
                            child: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    )
                    : SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      "Hello",
                      "This is a test snackbar",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                    );
                  },
                  child: const Text("Test Snackbar"),
                ),
                _Title("Images"),
                ImageSlider(images: widget.images),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await deleteToken(); // assuming it's async
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false, // removes all previous routes
                    );
                  },
                  child: Icon(Icons.logout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _Title(String label) {
  return Padding(
    padding: EdgeInsets.all(5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
