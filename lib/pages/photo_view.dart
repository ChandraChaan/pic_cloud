import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

class PhotoViewer extends StatelessWidget {
  final Uint8List imageUrl;
  final DateTime captureDate;
  final String location;
  final String cameraModel;

  PhotoViewer({
    required this.imageUrl,
    required this.captureDate,
    required this.location,
    required this.cameraModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Photo view
          PhotoView(
            imageProvider: MemoryImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4.0,
            enableRotation: true,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            loadingBuilder: (context, progress) => Center(
              child: CircularProgressIndicator(
                value: progress == null
                    ? null
                    : progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1),
              ),
            ),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text('Error loading image', style: TextStyle(color: Colors.red)),
            ),
          ),

          // Back button with date and time display
          Positioned(
            top: 40,
            left: 20,
            child: Row(
              children: [
                // Custom back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Display Date & Time
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(captureDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Image details at the bottom on scroll up
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < 0) {
                  // Display details on scroll up
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return _buildImageDetails();
                    },
                    backgroundColor: Colors.black.withOpacity(0.8),
                    isScrollControlled: true,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.camera_alt, 'Camera', cameraModel),
          _buildDetailRow(Icons.location_on, 'Location', location),
          _buildDetailRow(Icons.calendar_today, 'Date', DateFormat('MMM dd, yyyy').format(captureDate)),
          _buildDetailRow(Icons.access_time, 'Time', DateFormat('hh:mm a').format(captureDate)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}