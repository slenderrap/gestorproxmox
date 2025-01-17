import 'package:flutter/material.dart';

class TextFieldWithTitle extends StatelessWidget {
  final String title;        // Títol que es mostrarà dins del camp de text.
  final TextEditingController controller;  // Controlador per gestionar el text.

  const TextFieldWithTitle({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,  // Connectem el controlador al TextField.
      decoration: InputDecoration(
        prefixText: title+": ",  // El títol es mostra dins del camp de text.
        prefixStyle: TextStyle(
          color: Colors.black,  // Estil per al títol dins del camp.
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
