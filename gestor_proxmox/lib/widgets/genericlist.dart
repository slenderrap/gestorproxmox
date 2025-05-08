import 'package:flutter/material.dart';

class GenericList extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const GenericList({
    Key? key,
    required this.title,
    required this.items,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: itemBuilder,
            ),
          ),
        ],
      ),
    );
  }
}