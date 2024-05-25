import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatelessWidget {
  final Uint8List imageUrl;

  PhotoViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Viewer'),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: MemoryImage(imageUrl),
        ),
      ),
    );
  }
}
