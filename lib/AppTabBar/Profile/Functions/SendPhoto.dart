import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';

Future<XFile?> pickImage() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    return image;
  } on PlatformException catch (e) {
    print('Failed to pick image: $e');
    return null;
  }
}

Future<XFile?> takeImage() async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    return image;
  } on PlatformException catch (e) {
    print('Failed to pick image: $e');
    return null;
  }
}

Future<void> sendPhoto(File image) async {
  await checkTimestamp();

  Uri url = Uri.parse(ApiEndpoints.SET_PROFILE_PICTURE);
  const storage = FlutterSecureStorage();
  var token = await storage.read(key: "access_token");

  var request = http.MultipartRequest("PUT", url);
  request.headers['Authorization'] = 'Bearer $token';

  var fileStream = http.ByteStream(image.openRead());
  var length = await image.length();
  var multipartFile = http.MultipartFile(
    'file',
    fileStream,
    length,
    filename: image.path.split("/").last,
    contentType: MediaType.parse('image/jpeg'), // Updated line
  );

  request.files.add(multipartFile);

  var response = await request.send();
  if (response.statusCode == 200) {
    print("Uploaded!");
  } else {
    print("Error during connection to the server.");
  }
}
