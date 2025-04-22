import 'package:flutter/material.dart';
import 'package:projet/components/imagesSlider.dart';
import 'package:projet/modals/CustomImage.dart';

class Room {
  final String type;
  final List<CustomImage> images;

  Room({required this.type, required this.images});
}

class HouseCard extends StatefulWidget {
  final String id;
  final String surface;
  final String adminid;
  final String region;
  final String ville;
  final String type;
  final String location;
  final String price;
  final List<CustomImage> images;
  // final List<Room> rooms;

  const HouseCard({
    Key? key,
    required this.id,
    required this.surface,
    required this.adminid,
    required this.region,
    required this.ville,
    required this.type,
    required this.location,
    required this.price,
    required this.images,
    // required this.rooms,
  }) : super(key: key);

  @override
  State<HouseCard> createState() => _HouseCardState();
}

class _HouseCardState extends State<HouseCard> {
  @override
  Widget build(BuildContext context) {
    // Find main image or fallback to the first one
    // final mainImage = widget.images.firstWhere(
    //   (img) => img.isMainImage,
    //   orElse: () => widget.images.first,
    // );
    // final mainImageUrl=mainImage.url;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ImageSlider(images: widget.images),
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
    );
  }
}
