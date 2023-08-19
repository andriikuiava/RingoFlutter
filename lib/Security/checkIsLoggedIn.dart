import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/main.dart';
import 'package:ringoflutter/Security/LoginPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Security/EmailVerificationPage.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:ringoflutter/Security/Functions/ActivateAccount.dart';

final GlobalKey<NavigatorState> navigatorKey = App.materialKey;

class CheckerPage extends StatefulWidget {
  const CheckerPage({Key? key}) : super(key: key);

  @override
  _CheckerPageState createState() => _CheckerPageState();
}

class _CheckerPageState extends State<CheckerPage> {
  @override
  void initState() {
    super.initState();
    doWhenLoaded();
  }

  void doWhenLoaded() async {
    final storage = FlutterSecureStorage();
    String currentTime = DateTime.now().toString();
    String? storedTime = await storage.read(key: 'timestamp');
    print(storedTime);

    if (storedTime != null) {
      await checkTimestamp();
      var storage = FlutterSecureStorage();
      var token = await storage.read(key: "access_token");
      DateTime current = DateTime.parse(currentTime);
      DateTime stored = DateTime.parse(storedTime);
      Uri url = Uri.parse('${ApiEndpoints.CURRENT_PARTICIPANT}');
      var responseId = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${token}'
      });
      print(responseId.body);
      if (responseId.statusCode == 200) {
        final jsonResponse = jsonDecode(responseId.body);
        storage.write(
            key: "id",
            value: jsonResponse['id'].toString());
        if (!jsonResponse['emailVerified']) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => EmailVerificationPage(usersEmail: jsonResponse['email'],)),
          );
        } else {
          if (jsonResponse['dateOfBirth'] == null) {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => ActivateAccountPage(usersEmail: jsonResponse['email'], usersUsername: jsonResponse['username'], usersName: jsonResponse['name'],),),
            );
          } else {
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => const Home()),
            );
          }
        }
      } else {
        throw Exception('Failed to load participants');
      }
    } else {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      throw Exception('No timestamp found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
