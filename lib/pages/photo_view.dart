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
        title: const Text('Photo Viewer'),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: MemoryImage(imageUrl),
          minScale: PhotoViewComputedScale.contained * 0.8, // Minimum scale
          maxScale: PhotoViewComputedScale.covered * 3.0, // Maximum scale
        ),
      ),
    );
  }
}
