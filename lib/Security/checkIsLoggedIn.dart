import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/main.dart';
import 'package:ringoflutter/Security/LoginPage.dart';

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
      DateTime current = DateTime.parse(currentTime);
      DateTime stored = DateTime.parse(storedTime);
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const Home()),
      );
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
