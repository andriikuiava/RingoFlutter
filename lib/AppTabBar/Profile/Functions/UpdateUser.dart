import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:ringoflutter/AppTabBar/Profile/Functions/SendPhoto.dart';

void updateUser(String name, String username, File? image, int genderId, String dateOfBirth) async {
  checkTimestamp();
  var selectedGender = "";
  if (genderId == 0) {
    selectedGender = "MALE";
  }
  if (genderId == 1) {
    selectedGender = "FEMALE";
  }
  if (genderId == 2) {
    selectedGender = "OTHER";
  }
  Uri url = Uri.parse('http://localhost:8080/api/participants');
  var storage = new FlutterSecureStorage();
  var token = await storage.read(key: "access_token");
  var headers = {
    'Authorization': "Bearer $token",
    'Content-Type': "application/json",
  };
  var body = jsonEncode({
    'name': name,
    'username': username,
    'gender': selectedGender,
    'dateOfBirth': dateOfBirth,
  });
  print(jsonDecode(body));
  var response = await http.put(url, headers: headers, body: body);
  if (response.statusCode == 200) {
    print("Uploaded!");
    if (image != null) {
      sendPhoto(image);
    }
  } else {
    print("Error during connection to the server.");
  }
}
