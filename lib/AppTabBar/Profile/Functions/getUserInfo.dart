import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Classes/UserClass.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';

Future<User> getUserInfo() async {
  await checkTimestamp();
  const storage = FlutterSecureStorage();
  Uri url = Uri.parse('${ApiEndpoints.CURRENT_PARTICIPANT}');
  var token = await storage.read(key: 'access_token');
  var headers = {
    'Authorization': 'Bearer $token',
  };
  var response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    return User.fromJson(customJsonDecode(response.body));
  } else {
    throw Exception('Failed to load user');
  }
}
