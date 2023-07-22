import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';
import 'package:ringoflutter/Security/Functions/RefreshTokenFunc.dart';

Future<bool> checkTimestamp() async {
  final storage = FlutterSecureStorage();
  String currentTime = DateTime.now().toString();
  String? storedTime = await storage.read(key: 'timestamp');

  if (storedTime != null) {
    DateTime current = DateTime.parse(currentTime);
    DateTime stored = DateTime.parse(storedTime);

    if (current.compareTo(stored) > 0) {
      var token = await storage.read(key: 'refresh_token');
      await refreshTokens(token!);
      return false;
    } else {
      // print(stored);
      return true;
    }
  } else {
    logOut();
    throw Exception('No timestamp found');
  }
}
