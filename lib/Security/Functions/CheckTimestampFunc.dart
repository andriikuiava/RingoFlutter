import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';
import 'package:ringoflutter/Classes/TokensClass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> checkTimestamp() async {
  final storage = FlutterSecureStorage();
  final String currentTime = DateTime.now().toString();
  final String? storedTime = await storage.read(key: 'timestamp');

  if (storedTime != null) {
    final DateTime current = DateTime.parse(currentTime);
    final DateTime stored = DateTime.parse(storedTime);

    if (current.compareTo(stored) > 0) {
      final String? refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        final bool refreshSuccess = await refreshTokens(refreshToken);
        return refreshSuccess;
      }
      logOut();
      return false;
    } else {
      return true;
    }
  } else {
    logOut();
    throw Exception('No timestamp found');
  }
}

Future<bool> refreshTokens(String refreshToken) async {
  final storage = FlutterSecureStorage();
  final url = Uri.parse('http://localhost:8080/api/auth/refresh-token');
  final headers = {
    'Authorization': 'Bearer $refreshToken',
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      await storage.write(key: "access_token", value: jsonResponse['accessToken']);
      await storage.write(key: "refresh_token", value: jsonResponse['refreshToken']);

      final DateTime currentTime = DateTime.now();
      final DateTime futureTime = currentTime.add(const Duration(seconds: 30));
      storage.write(key: "timestamp", value: futureTime.toString());

      return true;
    } else {
      logOut();
      return false;
    }
  } catch (e) {
    logOut();
    throw Exception('An error occurred while refreshing tokens: $e');
  }
}


class TokenRefreshFailedException implements Exception {
  final String message;

  TokenRefreshFailedException([this.message = 'Token refresh failed']);

  @override
  String toString() => 'TokenRefreshFailedException: $message';
}
