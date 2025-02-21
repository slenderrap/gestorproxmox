import 'package:flutter/material.dart';

class TextFieldWithTitle extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const TextFieldWithTitle({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixText: title+": ",
        prefixStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      ),
    );
  }
}
