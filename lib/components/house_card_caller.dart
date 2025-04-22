import 'package:flutter/material.dart';
import 'package:projet/modals/CustomImage.dart';
import './house_card.dart';

class HouseCardCaller extends StatefulWidget {
  final Map<String, dynamic> file;
  const HouseCardCaller({super.key, required this.file});

  @override
  State<HouseCardCaller> createState() => _houseCardCallerState();
}

class _houseCardCallerState extends State<HouseCardCaller> {
  late Map<String, dynamic> data = widget.file;

  @override
  Widget build(BuildContext context) {
    return HouseCard(
      id: data['id'],
      surface: data['surface'],
      adminid: data['adminid'],
      region: data['region'],
      ville: data['ville'],
      type: data['type'],
      location: data['location'],
      price: data['price'],
      images:
          (data['images'] as List)
              .map(
                (img) => CustomImage(
                  isMainImage: img['main'] ?? false,
                  url: img['url'] ?? '',
                ),
              )
              .toList(),
    );
  }
}
