import "package:flutter/material.dart";
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:projet/modals/CustomImage.dart';

class ImageSlider extends StatefulWidget {
  final List<CustomImage> images;

  const ImageSlider({super.key, required this.images});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Set an appropriate height for the carousel
      child: AnotherCarousel(
        images:
            widget.images.map((img) {
              return Image.asset(img.url, fit: BoxFit.cover);
            }).toList(),
        dotSize: 3.0,
        borderRadius: true,
        dotSpacing: 20.0,
        autoplay: false,
        animationDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}
