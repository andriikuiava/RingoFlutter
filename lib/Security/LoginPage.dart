import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';
import 'package:ringoflutter/Classes/TokensClass.dart';
import 'package:ringoflutter/Security/Functions/LoginFunc.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';
import 'Registration.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';

Future<void> signInWithGoogle() async {
  try {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email'], clientId: "445780816677-on7ff5l41ig1ervle491sc7vuvg4n5ro.apps.googleusercontent.com");
    GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account != null) {
      GoogleSignInAuthentication authentication = await account.authentication;
      String idToken = authentication.idToken ?? '';

      var url = Uri.parse('http://localhost:8080/api/participants/sign-up/google');
      var body = {'token': idToken};
      var headers = {'Content-Type': 'application/json'};
      var encodedBody = jsonEncode(body);

      var response = await http.post(url, body: encodedBody, headers: headers);
      if (response.statusCode == 200) {
        print('Google Sign-In success: $response');
      } else {
        print('Google Sign-In failed: ${response.statusCode}');
      }
    } else {
      print('Google Sign-In cancelled.');
    }
  } catch (error) {
    print('Error occurred during Google Sign-In: $error');
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    const storage = FlutterSecureStorage();

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30.0),
              SizedBox(
                height: 145,
                child: Image.asset(currentTheme.brightness == Brightness.light
                    ? 'assets/images/Ringo-Black.png'
                    : 'assets/images/Ringo-White.png'
                ),
              ),
              const SizedBox(height: 12.0),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: currentTheme.primaryColor,
                ),
                child: const Text("Login to Ringo"),
              ),
              const SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Email'),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 50,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _emailController,
                      placeholder: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: currentTheme.primaryColor,
                        fontSize: 16,
                      ),
                      decoration: BoxDecoration(
                        color: currentTheme.colorScheme.background,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Password'),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 50,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _passwordController,
                      placeholder: 'Enter your password',
                      obscureText: true,
                      style: TextStyle(
                        color: currentTheme.primaryColor,
                        fontSize: 16,
                      ),
                      decoration: BoxDecoration(
                        color: currentTheme.colorScheme.background,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36.0),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: currentTheme.shadowColor,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            color: currentTheme.colorScheme.background,
                            onPressed: () async {
                              LoginCredentials credentials = LoginCredentials(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              Tokens receivedTokens =
                              await loginFunc(credentials);
                              storage.write(
                                  key: "access_token",
                                  value: receivedTokens.accessToken);
                              storage.write(
                                  key: "refresh_token",
                                  value: receivedTokens.refreshToken);
                                                        },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: currentTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0), // Added space between the buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: currentTheme.shadowColor,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            color: currentTheme.colorScheme.background,
                            onPressed: () async {
                              signInWithGoogle();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google-logo.png',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: currentTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0), // Added space between the buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: currentTheme.shadowColor,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            color: currentTheme.primaryColor,
                            onPressed: () {},
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: currentTheme.colorScheme.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0), // Added space between the buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove padding around the text
                          ),
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: currentTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultTextStyle(
                        style: TextStyle(
                          color: currentTheme.primaryColor,
                          fontSize: 16,
                        ),
                        child: const Text("Don't have an account?"),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove padding around the text
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistrationPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: currentTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
