import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
    print('step 1');

    // Request photos permission
    var status = await Permission.photos.request();

    if (status.isGranted) {
      print('step 3');
      setState(() {
        _isLoading = true;
      });
      await _loadPhotos(); // Load photos if permissions are granted
    } else {
      bool isPermanentlyDenied = status.isPermanentlyDenied;

      if (isPermanentlyDenied) {
        print('step 4');
        await errorDialog(context, "Please allow permissions from settings")
            .whenComplete(() => openAppSettings());
      } else {
        print('step 4');
        await errorDialog(context, "Permissions are required to proceed.");
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> errorDialog(BuildContext context, String message) async {
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

  void openAppSettings() {
    openAppSettings();
  }

  Future<void> _loadPhotos() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    if (albums.isNotEmpty) {
      List<AssetEntity> photos = await albums[0]
          .getAssetListPaged(page: 0, size: 100); // Load first 100 photos
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pic Cloud'),
      ),
      body: _isLoading
          ? Center(
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
            )
          : _photos.isEmpty
              ? Center(
                  child: Text('No photos found',
                      style: Theme.of(context).textTheme.titleLarge))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<Uint8List?>(
                      future: _photos[index].thumbnailData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(snapshot.data!,
                              fit: BoxFit.cover);
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    );
                  },
                ),
    );
  }
}
