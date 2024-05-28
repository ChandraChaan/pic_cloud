import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LocationData? _locationData;
  String address = 'Loading';
  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    var location = Location();
    try {
      _locationData = await location.getLocation();

     address = await getAddress(_locationData!.latitude!, _locationData!.longitude!);
      setState(() {});
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<String> getAddress(double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      final address = decodedData['display_name'];
      return address;
    }

    return 'Address not found';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Example'),
      ),
      body: Center(
        child: _locationData == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(address),
                ],
              ),
      ),
    );
  }
}
