import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';
import 'UI/Themes.dart';

void main() {
  Stripe.publishableKey = "pk_test_51N6bKSCkVoLPfCXzfYqskbTCIxe6Bt2B8aYLiuZAUEQaPB3TGmAekPo3rJyOgaU0IXYFWNcHfAxh9L4NdSjUgY0700tQqdVwxm";
  runApp(
    MaterialApp(
      navigatorKey: App.materialKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const Directionality(
        textDirection: TextDirection.ltr,
        child: CheckerPage(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class App {
  static final GlobalKey<NavigatorState> materialKey =
      GlobalKey<NavigatorState>();
}
