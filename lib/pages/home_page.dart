import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pic_cloud/pages/photo_view.dart';
import 'package:pic_cloud/pages/video_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<AssetEntity> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _requestPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      await _loadPhotos();
    } else {
      await _handlePermissionDenied(status);
    }
  }

  Future<void> _handlePermissionDenied(PermissionStatus status) async {
    if (status.isPermanentlyDenied) {
      await _showErrorDialog("Please allow permissions from settings")
          .whenComplete(() => openAppSettings());
    } else {
      await _showErrorDialog("Permissions are required to proceed.");
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    if (albums.isNotEmpty) {
      List<AssetEntity> photos = await albums[0].getAssetListPaged(page: 0, size: 100);
      setState(() {
        _photos = photos;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pic Cloud'),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _photos.isEmpty
          ? _buildNoPhotosMessage()
          : _buildPhotoGrid(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: const Icon(
              Icons.sync,
              color: Colors.deepPurple,
              size: 25,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Uploading....',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPhotosMessage() {
    return Center(
      child: Text(
        'No photos found',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final asset = _photos[index];
        return FutureBuilder<Uint8List?>(
          future: asset.thumbnailData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return InkWell(
                onTap: () {
                  if (asset.type == AssetType.video) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoViewer(
                          asset: asset,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewer(
                          imageUrl: snapshot.data!,
                        ),
                      ),
                    );
                  }
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (asset.type == AssetType.video)
                      const Positioned(
                        bottom: 4,
                        right: 4,
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}
