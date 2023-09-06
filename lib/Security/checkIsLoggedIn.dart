import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/Security/EmailVerificationPage.dart';
import 'package:ringoflutter/Security/Functions/ActivateAccount.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/Security/LoginPage.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:ringoflutter/main.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
    const storage = FlutterSecureStorage();
    String currentTime = DateTime.now().toString();
    String? storedTime = await storage.read(key: 'timestamp');
    print(storedTime);
    var isConnect = await InternetConnectionChecker().hasConnection;
    if (storedTime != null && isConnect) {
      await checkTimestamp();
      var storage = const FlutterSecureStorage();
      var token = await storage.read(key: "access_token");
      DateTime current = DateTime.parse(currentTime);
      DateTime stored = DateTime.parse(storedTime);
      Uri url = Uri.parse(ApiEndpoints.CURRENT_PARTICIPANT);
      var responseId = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      if (responseId.statusCode == 200) {
        final jsonResponse = customJsonDecode(responseId.body);
        storage.write(
            key: "id",
            value: jsonResponse['id'].toString());
        if (!jsonResponse['emailVerified']) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => EmailVerificationPage(usersEmail: jsonResponse['email'], usersUsername: jsonResponse['username'],)),
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
      if (isConnect) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const Home()),
        );
      }
      throw Exception('No timestamp found');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: currentTheme.primaryColor,
        ),
      ),
    );
  }
}
