import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Classes/UserClass.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';

Future<User> getUserInfo() async {
  checkTimestamp();
  final storage = new FlutterSecureStorage();
  Uri url = Uri.parse('http://localhost:8080/api/participants');
  var token = await storage.read(key: 'access_token');
  var headers = {
    'Authorization': 'Bearer $token',
  };
  var response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load user');
  }
}
