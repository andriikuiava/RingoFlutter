import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/TokensClass.dart';
import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';

Future<Tokens> refreshTokens(String refreshToken) async {
  const storage = FlutterSecureStorage();
  var url = Uri.parse('http://localhost:8080/api/auth/refresh-token');
  var headers = {
    'Authorization': 'Bearer $refreshToken',
  };

  try {
    var response = await http.get(url, headers: headers);

    if (storage.read(key: 'refreshToken') != null) {
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        await storage.write(key: "access_token", value: jsonResponse['accessToken']);
        await storage.write(key: "refresh_token", value: jsonResponse['refreshToken']);

        DateTime currentTime = DateTime.now();
        DateTime futureTime = currentTime.add(const Duration(minutes: 5));
        storage.write(key: "timestamp", value: futureTime.toString());

        return Tokens(
          accessToken: jsonResponse['accessToken'],
          refreshToken: jsonResponse['refreshToken'],
        );
      } else {
        logOut();
        throw Exception('Failed to refresh tokens');
      }
    } else {
      logOut();
      throw Exception('No refresh token found');
    }
  } catch (e) {
    logOut();
    throw Exception('An error occurred while refreshing tokens: $e');
  }
}
