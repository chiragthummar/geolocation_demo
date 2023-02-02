import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Position? _position;
  String? _currentAddress;

  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
    });
    _getCurrentAddress();
  }

  void _getCurrentAddress() async {
    List<Placemark> placemarks = await _getAddressFromLatLng(_position);
    Placemark place = placemarks[0];
    setState(() {
      _currentAddress =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
// When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<Placemark>> _getAddressFromLatLng(Position? position) async {
    return await placemarkFromCoordinates(
        _position!.latitude, _position!.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geolocation Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Geolocation Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _position != null
                  ? Text('Current Position ${_position?.latitude}')
                  : Text('No location found'),
              ElevatedButton(
                onPressed: () {
                  _getCurrentLocation();
                },
                child: Text('Get current location'),
              ),
              Text('Current address ${_currentAddress}'),
            ],
          ),
        ),
      ),
    );
  }
}
