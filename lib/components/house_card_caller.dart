import 'package:flutter/material.dart';
import 'package:projet/modals/CustomImage.dart';
import './house_card.dart';
import 'package:http/http.dart' as http;
class HouseCardCaller extends StatefulWidget {
  final Map<String, dynamic> file;
  final bool isfav;
  final onChange;
  const HouseCardCaller({super.key, required this.file,required this.isfav,required this.onChange});

  @override
  State<HouseCardCaller> createState() => _houseCardCallerState();
}


class _houseCardCallerState extends State<HouseCardCaller> {
  late Map<String, dynamic> data = widget.file;

  @override
  Widget build(BuildContext context) {
    return HouseCard(
      isfav: widget.isfav,
      onChange: widget.onChange,
      id: data['id'],
      surface: data['surface'],
      admin_id: data['admin_id'],
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
