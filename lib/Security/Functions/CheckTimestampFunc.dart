import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';

Future<bool> checkTimestamp() async {
  const storage = FlutterSecureStorage();
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
      return false;
    } else {
      return true;
    }
  } else {
    throw Exception('No timestamp found');
    return false;
  }
}

Future<bool> refreshTokens(String refreshToken) async {
  const storage = FlutterSecureStorage();
  final url = Uri.parse(ApiEndpoints.REFRESH_TOKENS);
  final headers = {
    'Authorization': 'Bearer $refreshToken',
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = customJsonDecode(response.body);
      await storage.write(
          key: "access_token", value: jsonResponse['accessToken']);
      await storage.write(
          key: "refresh_token", value: jsonResponse['refreshToken']);

      final DateTime currentTime = DateTime.now();
      final DateTime futureTime = currentTime.add(const Duration(seconds: 30));
      storage.write(key: "timestamp", value: futureTime.toString());

      return true;
    } else if (response.statusCode == 401) {
      logOut();
      throw Exception('Token refresh failed, unauthorized');
      return false;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception('An error occurred while refreshing tokens: $e');
  }
}

class TokenRefreshFailedException implements Exception {
  final String message;

  TokenRefreshFailedException([this.message = 'Token refresh failed']);

  @override
  String toString() => 'TokenRefreshFailedException: $message';
}
