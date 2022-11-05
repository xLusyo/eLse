import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  late GoogleMapController _controller;
  //var emergencylatitude, emergencylongitude, emergencyid;

  late Marker marker;
  late LatLng userPosition =
      const LatLng(8.456500287014384, 124.64369875778976);
  bool myLocationPressed = false;
  List<Marker> markerList = [];
  Completer<GoogleMapController> controlCompleter = Completer();

  Future getuserLocation() async {
    //To check if location service is enabled
    //if disabled, prompt the user to turn it on
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      //return Future.error('Location service is disabled');
      return await Geolocator.requestPermission();
    }

    //verify or check permissions
    //if permissions are denied re-state checking of permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission denied by user');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Unable to share location, permission is permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Uint8List> userMarker() async {
    ByteData bytedata =
        await rootBundle.load('assets/images/U-map-reference.png');
    ui.Codec codec = await ui.instantiateImageCodec(
        bytedata.buffer.asUint8List(),
        targetHeight: 100,
        targetWidth: 100);
    ui.FrameInfo fInfo = await codec.getNextFrame();
    return (await fInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Uint8List> emergencyMarker() async {
    ByteData bytedata =
        await rootBundle.load('assets/images/Emergency-removebg-preview.png');
    ui.Codec codec = await ui.instantiateImageCodec(
        bytedata.buffer.asUint8List(),
        targetHeight: 200,
        targetWidth: 200);
    ui.FrameInfo fInfo = await codec.getNextFrame();
    return (await fInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  showCurrentUserMarker() async {
    Position coordinates = await Geolocator.getCurrentPosition();
    Uint8List userMark = await userMarker();
    userPosition = LatLng(coordinates.latitude, coordinates.longitude);
    if (_controller.isBlank == false && userPosition.isBlank == false) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: userPosition, tilt: 0, zoom: 17)));
    }
    marker = Marker(
        //consumeTapEvents: false,
        infoWindow: const InfoWindow(title: 'YOU'),
        draggable: false,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        markerId: const MarkerId('Current User'),
        icon: BitmapDescriptor.fromBytes(userMark),
        position: userPosition);
    setState(() {
      markerList.add(marker);
      if (markerList.isNotEmpty) {
        _controller.showMarkerInfoWindow(const MarkerId('Current User'));
        controlCompleter.complete(_controller);
      }
    });
  }

  getEmergency() async {
    Uint8List emergencyMark = await emergencyMarker();
    var emergencyMarkers = await FirebaseFirestore.instance
        .collection('emergency')
        .where('active', isEqualTo: false)
        .get();
    return setState(() {
      for (var snapshots in emergencyMarkers.docs) {
        Map<String, dynamic> data = snapshots.data();
        markerList.add(Marker(
            //consumeTapEvents: false,
            infoWindow: InfoWindow(title: 'ID: ${data["uid"]}'),
            draggable: false,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            markerId: MarkerId('${data["uid"]}'),
            icon: BitmapDescriptor.fromBytes(emergencyMark),
            position: LatLng(data['latitude'], data['longitude'])));
      }
      print('marker list length: ${markerList.length}');
    });
  }

  @override
  void initState() {
    getuserLocation();
    getEmergency();
    myLocationPressed == false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Community',
              style: GoogleFonts.fanwoodText(color: Colors.black, fontSize: 30),
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.black))),
        body: Stack(children: [
          GoogleMap(
            markers: Set.of(markerList),
            initialCameraPosition: const CameraPosition(
                tilt: 0,
                zoom: 15,
                target: LatLng(8.456500287014384, 124.64369875778976)),
            onMapCreated: (GoogleMapController controller) async {
              _controller = controller;
            },
          ),
          Positioned(
              right: 12,
              bottom: 100,
              child: InkWell(
                onTap: () {
                  /*setState(() {
                    myLocationPressed = !myLocationPressed;
                  });*/
                  showCurrentUserMarker();
                  print('shared location');
                },
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                            title: Text('Note'),
                            content: Text(
                                'Press the button to revert back the focus of the map to your location'),
                            icon: Icon(Icons.info, color: Color(0xff3DCA76)));
                      });
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset.zero,
                            blurRadius: 3,
                            spreadRadius: -1)
                      ],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.black,
                      size: 40,
                    )),
              )),
        ]));
  }
}
