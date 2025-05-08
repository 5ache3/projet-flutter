import 'package:flutter/material.dart';
import 'package:projet/components/imagesSlider.dart';
import 'package:projet/modals/CustomImage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projet/constants.dart';

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

  @override
  void initState() {
    super.initState();
    _fav = widget.isfav;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("aqarmap"),
    centerTitle: true,
    backgroundColor: Colors.greenAccent,
    ),
      body: SafeArea(child: 
      Center(
        child: Padding(padding: const EdgeInsets.all(16),
        child: Column(
            children: [
              _Title("Images"),
              ImageSlider(images: widget.images),
              SizedBox(height: 10,),
              _Title("")
            ],
        ),
        ),
      )
      ),
    );
  }
}

Widget _Title(String label) {
  
  return Padding(padding: EdgeInsets.all(5),
    child:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(label,
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold) ,
            ),
          ]
      ),
    );

}