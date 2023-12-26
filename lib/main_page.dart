import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  bool _isGranted = false; /// 1
  static Position? _position;

  @override
  void initState() {
   _requestPermission();
    super.initState();
  }

  void _requestPermission() async {
    final response = await Permission.location.request();
    _isGranted = response.isGranted; /// 2
    if(response.isGranted) {
      print('Permission Granted, you can get location');
      _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } else {
      print('Permission denieb');
     if(await Permission.location.shouldShowRequestRationale) {
       openAppSettings();
     }
    }
  }

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  final _marker = Marker(markerId:MarkerId("one_id"),position: LatLng(_position?.longitude ?? 0, _position?.latitude ?? 0), icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueCyan
  ));

  @override
  Widget build(BuildContext context) {
    print(_position?.latitude);
    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(_position?.longitude ?? 0, _position?.latitude ?? 0),
   //   zoom: 30.4746,
    );
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        markers: {_marker},
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gotoAnjan,
        label: const Text('To the Anjan!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _gotoAnjan() async {
    final anjanPosition = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(_position?.latitude ?? 0, _position?.longitude ?? 0),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(anjanPosition));
  }
}
