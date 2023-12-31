import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/CoordinatesClass.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Coordinates? userLocation;
  GoogleMapController? _mapController;
  final List<Marker> _markers = [];

  GoogleMapController? mapController;
  String? _mapStyle;
  String? _mapStyleDark;
  String? _mapStyleIos;
  String? _mapStyleIosDark;

  @override
  void initState() {
    rootBundle.loadString('assets/map/light.txt').then((string) {
      _mapStyle = string;
    });

    rootBundle.loadString('assets/map/dark.txt').then((string) {
      _mapStyleDark = string;
    });

    rootBundle.loadString('assets/map/light.json').then((string) {
      _mapStyleIos = string;
    });

    rootBundle.loadString('assets/map/dark.json').then((string) {
      _mapStyleIosDark = string;
    });
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    // Replace this with your code to get the user's location
    // userLocation = await getUserLocation();
    userLocation = Coordinates(latitude: 59.430597, longitude: 24.752130);
    setState(() {});
  }

  void _printVisibleMapCoordinates() async {
    if (_mapController == null) return;

    LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();
    print(
        "Top Left: ${visibleRegion.northeast.latitude}, ${visibleRegion.southwest.longitude}");
    print(
        "Bottom Right: ${visibleRegion.southwest.latitude}, ${visibleRegion.northeast.longitude}");
    print("User Latitude: ${userLocation!.latitude}");
    print("User Longitude: ${userLocation!.longitude}");
  }

  Future<List<MapObject>> _fetchDataFromServer() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    if (_mapController == null) return [];

    LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();
    final double latMin = visibleRegion.southwest.latitude;
    final double latMax = visibleRegion.northeast.latitude;
    final double lonMin = visibleRegion.southwest.longitude;
    final double lonMax = visibleRegion.northeast.longitude;

    final url =
        '${ApiEndpoints.SEARCH}/geo/area?latMin=$latMin&latMax=$latMax&lonMin=$lonMin&lonMax=$lonMax';
    var headers = {
      'Authorization': "Bearer $token",
    };
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => MapObject.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  void _showObjectsOnMap() async {
    try {
      List<MapObject> objects = await _fetchDataFromServer();

      if (objects.isNotEmpty) {
        _markers.clear();

        for (var object in objects) {
          BitmapDescriptor customIcon =
              await _createCustomMarkerBitmap(object.count);

          Marker marker = Marker(
            markerId: MarkerId(object.id.toString()),
            position: LatLng(
                object.coordinates.latitude, object.coordinates.longitude),
            infoWindow: InfoWindow(
              title: 'Count: ${object.count}',
              snippet: 'MainPhotoId: ${object.mainPhotoId}, Id: ${object.id}',
            ),
            icon: customIcon,
            onTap: () {
              // If the tapped marker has a count of 1, print "1" to the console
              if (object.count == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventPage(eventId: object.id!)),
                );
              }
            },
          );

          _markers.add(marker);
        }

        setState(() {});
      }
    } catch (e) {
      print('Error fetching data from server: $e');
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(int count) async {
    final currentTheme = Theme.of(context);
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    const int size = 150;
    final Paint paint = Paint()..color = currentTheme.colorScheme.primary;

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: count.toString(),
          style: TextStyle(
              color: currentTheme.scaffoldBackgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 70)),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            (size - textPainter.width) / 2, (size - textPainter.height) / 2));

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return userLocation != null
        ? GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              (Platform.isAndroid)
                  ? (currentTheme.brightness == Brightness.light)
                      ? _mapController?.setMapStyle(_mapStyle!)
                      : _mapController?.setMapStyle(_mapStyleDark!)
                  : (currentTheme.brightness == Brightness.light)
                      ? _mapController?.setMapStyle(_mapStyleIos!)
                      : _mapController?.setMapStyle(_mapStyleIosDark!);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(userLocation!.latitude, userLocation!.longitude),
              zoom: 12,
            ),
            myLocationEnabled: true,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            markers: Set<Marker>.of(_markers),
            onCameraMove: (position) {
              _showObjectsOnMap();
            },
          )
        : Center(
            child: CircularProgressIndicator(
              color: currentTheme.colorScheme.primary,
            ),
          );
  }
}

class MapObject {
  final Coordinates coordinates;
  final int count;
  final int? mainPhotoId;
  final int? id;

  MapObject({
    required this.coordinates,
    required this.count,
    this.mainPhotoId,
    this.id,
  });

  factory MapObject.fromJson(Map<String, dynamic> json) {
    return MapObject(
      coordinates: Coordinates.fromJson(json['coordinates']),
      count: json['count'],
      mainPhotoId: json['mainPhotoId'],
      id: json['id'],
    );
  }
}

class CustomMarkerWidget extends StatelessWidget {
  final int count;

  const CustomMarkerWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: Text(
        count.toString(),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
