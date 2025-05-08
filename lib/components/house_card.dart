import 'package:flutter/material.dart';
import 'package:projet/components/imagesSlider.dart';
import 'package:projet/modals/CustomImage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projet/constants.dart';
import 'package:projet/pages/house_page.dart';

class Room {
  final String type;
  final List<CustomImage> images;
  Room({required this.type, required this.images});
}

class HouseCard extends StatefulWidget {
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

  const HouseCard({
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
  State<HouseCard> createState() => _HouseCardState();
}

class _HouseCardState extends State<HouseCard> {
  late bool _fav;

  Future<void> toggleFavorites() async {
    final String userId = '1';
    final url = Uri.parse('$apiUrl/favorites/$userId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'house_id': widget.id}),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fav = widget.isfav;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: ()=>{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              HousePage(id: widget.id,
                  surface: widget.surface,
                  admin_id: widget.admin_id,
                  region: widget.region,
                  ville: widget.ville,
                  type: widget.type,
                  location: widget.location,
                  price: widget.price,
                  images: widget.images,
                  isfav: widget.isfav)),
        )
      },
      child:Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ImageSlider(images: widget.images),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    toggleFavorites();
                    widget.onChange(widget.id);
                    setState(() {
                      _fav = !_fav;
                    });
                  },
                  child: Icon(
                    _fav ? Icons.favorite : Icons.favorite_border,
                    color: _fav ? Colors.red : Colors.white,
                    size: 28,
                  ),
                ),
              ),
              // Price tag
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: Colors.black54,
                  child: Text(
                    '\$${widget.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${widget.type} • ${widget.surface}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'price : ${widget.price}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
