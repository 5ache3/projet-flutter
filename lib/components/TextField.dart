import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumeric;
  final bool passwd;
  final IconData? icon2;
  final VoidCallback? onClicked;
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isNumeric = false,
    this.passwd=false,
    this.icon2,
    this.onClicked
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: passwd,
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),

          suffixIcon: icon2!=null?
          GestureDetector(
            onTap: onClicked,
              child: Icon(icon2)):null
          ,filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
