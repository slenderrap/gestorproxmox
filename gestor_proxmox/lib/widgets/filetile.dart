import 'dart:ui';

import 'package:flutter/material.dart';

class FileTile extends StatelessWidget {
  final String name;
  final bool isDirectory;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const FileTile({
    Key? key,
    required this.name,
    required this.isDirectory,
    required this.onDownload,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(isDirectory ? Icons.folder : Icons.insert_drive_file),
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: onDownload,
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}