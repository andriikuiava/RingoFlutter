import 'package:geolocator/geolocator.dart';
import 'package:ringoflutter/Classes/CoordinatesClass.dart';

Future<Coordinates> getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are disabled
    Geolocator.openLocationSettings();
    return Coordinates(latitude: 59.436962, longitude: 24.753574);
  }

  // Check and request location permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    // The user permanently denied location permission, take appropriate action
    Geolocator.openAppSettings();
    return Coordinates(latitude: 59.436962, longitude: 24.753574);
  }
  if (permission == LocationPermission.denied) {
    // Request location permission
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      // The user denied location permission, take appropriate action
      Geolocator.openAppSettings();
      return Coordinates(latitude: 59.436962, longitude: 24.753574);
    }
  }

  // Get the user's current location
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // Create a Coordinates object and return it
  return Coordinates(
    latitude: position.latitude,
    longitude: position.longitude,
  );
}
