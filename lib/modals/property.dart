import 'dart:io';

class Property {
  final String title;
  final String price;
  final String location;
  final File image;
  final List<File>? interiorImages;
  final String? landSize;
  final String? bedrooms;
  final String? kitchens;
  final String? bathrooms;
  final DateTime? constructionDate;
  final bool? hasWifi;
  final bool? hasParking;
  final bool? isFurnished;
  final bool isSponsored;
  final bool isPending;

  Property({
    required this.title,
    required this.price,
    required this.location,
    required this.image,
    this.interiorImages,
    this.landSize,
    this.bedrooms,
    this.kitchens,
    this.bathrooms,
    this.constructionDate,
    this.hasWifi,
    this.hasParking,
    this.isFurnished,
    this.isSponsored = false,
    this.isPending = true,
  });
}
