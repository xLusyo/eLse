import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class UserLocation {
  final Distance _distance = const Distance();
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('hospital');

  double calculateDistance(
      double userLong, double userLat, double long, double lat) {
    double meter = _distance(LatLng(userLat, userLong), LatLng(lat, long));
    return meter;
  }

  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Future<List> locationDataAndSMS() async {
    Position currentLocation = await getUserLocation();
    double meter;
    //QuerySnapshot querySnapshot = await _collectionReference.get();
    List<String> data = <String>[];
    List dataFromDB = [];

    await _collectionReference.get().then((querySnaphot) {
      querySnaphot.docs.forEach((element) {
        dataFromDB.add(element.data());
      });
    });

    for (int i = 0; i < dataFromDB.length; i++) {
      meter = _distance(
          LatLng(currentLocation.latitude, currentLocation.longitude),
          LatLng(dataFromDB[i]['latitude'] as double,
              dataFromDB[i]['longitude'] as double));

      if (meter <= 1000) {
        data.add(dataFromDB[i]['number'].toString());
      } else if (meter <= 8000) {
        data.add(dataFromDB[i]['number'].toString());
      }
    }

    return data;
  }

  Future<String> getAddress() async {
    Position position = await getUserLocation();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    String address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    return address;
  }
}
