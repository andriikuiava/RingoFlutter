import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/AppTabBar/Home.dart';
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';
import 'package:ringoflutter/Classes/TokensClass.dart';
import 'package:ringoflutter/Security/EmailVerificationPage.dart';
import 'package:ringoflutter/Security/ForgotPassword.dart';
import 'package:ringoflutter/Security/Functions/ActivateAccount.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/Security/checkIsLoggedIn.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'Registration.dart';

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

  bool isRingoLoading = false;
  bool isGoogleLoading = false;
  bool isAppleLoading = false;

  Future<void> signInWithGoogle() async {
    setState(() {
      isGoogleLoading = true;
    });
    const storage = FlutterSecureStorage();
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email'],
          clientId:
              "445780816677-on7ff5l41ig1ervle491sc7vuvg4n5ro.apps.googleusercontent.com");
      GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account != null) {
        GoogleSignInAuthentication authentication =
            await account.authentication;
        String idToken = authentication.idToken ?? '';
        var response = await http.post(Uri.parse(ApiEndpoints.LOGIN_GOOGLE),
            body: jsonEncode({"idToken": idToken}),
            headers: {"Content-Type": "application/json"});
        if (response.statusCode == 200) {
          print("Logged in with Google");
          final jsonResponse = customJsonDecode(response.body);
          DateTime currentTime = DateTime.now();
          DateTime futureTime = currentTime.add(const Duration(seconds: 30));
          storage.write(key: "timestamp", value: futureTime.toString());
          storage.write(
              key: "access_token", value: jsonResponse['accessToken']);
          storage.write(
              key: "refresh_token", value: jsonResponse['refreshToken']);
          await checkTimestamp();
          var url = Uri.parse(ApiEndpoints.CURRENT_PARTICIPANT);
          var responseCheckIfActivated = await http.get(url, headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${jsonResponse['accessToken']}'
          });
          if (responseCheckIfActivated.statusCode == 200) {
            final jsonResponse =
                customJsonDecode(responseCheckIfActivated.body);
            print(jsonResponse);
            storage.write(key: "id", value: jsonResponse['id'].toString());
            if (jsonResponse['dateOfBirth'] == null) {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ActivateAccountPage(
                    usersEmail: jsonResponse['email'],
                    usersUsername: jsonResponse['username'],
                    usersName: jsonResponse['name'],
                  ),
                ),
              );
            } else {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(builder: (_) => const Home()),
              );
            }
          } else {
            print("Failed to check if account is activated");
            throw Exception('Failed to load participants');
          }
        } else if (response.statusCode == 401) {
          print("User not registered with Google");
          var responseSignUp = await http.post(
              Uri.parse(ApiEndpoints.SIGNUP_GOOGLE),
              body: jsonEncode({"idToken": idToken}),
              headers: {"Content-Type": "application/json"});
          if (responseSignUp.statusCode == 200) {
            var responseAfterSigningUp = await http.post(
                Uri.parse(ApiEndpoints.LOGIN_GOOGLE),
                body: jsonEncode({"idToken": idToken}),
                headers: {"Content-Type": "application/json"});
            if (responseAfterSigningUp.statusCode == 200) {
              print("Logged in with Google");
              print(responseAfterSigningUp.body);
              final jsonResponse =
                  customJsonDecode(responseAfterSigningUp.body);
              DateTime currentTime = DateTime.now();
              DateTime futureTime =
                  currentTime.add(const Duration(seconds: 30));
              storage.write(key: "timestamp", value: futureTime.toString());
              storage.write(
                  key: "access_token", value: jsonResponse['accessToken']);
              storage.write(
                  key: "refresh_token", value: jsonResponse['refreshToken']);
              await checkTimestamp();
              var url = Uri.parse(ApiEndpoints.CURRENT_PARTICIPANT);
              var responseCheckIfActivated = await http.get(url, headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${jsonResponse['accessToken']}'
              });
              if (responseCheckIfActivated.statusCode == 200) {
                final jsonResponse =
                    customJsonDecode(responseCheckIfActivated.body);
                print(jsonResponse);
                storage.write(key: "id", value: jsonResponse['id'].toString());
                if (jsonResponse['dateOfBirth'] == null) {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ActivateAccountPage(
                        usersEmail: jsonResponse['email'],
                        usersUsername: jsonResponse['username'],
                        usersName: jsonResponse['name'],
                      ),
                    ),
                  );
                } else {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(builder: (_) => const Home()),
                  );
                }
              } else {
                showErrorAlert("Error", "Failed to load participant", context);
                print("Failed to check if account is activated");
                throw Exception('Failed to load participants');
              }
            } else {
              showErrorAlert(
                  "Error", "Failed to register with Google", context);
              print("Failed to register with Google");
              throw Exception('Failed to load participants');
            }
          } else {
            showErrorAlert("Error", "Failed register with Google", context);
            print("Failed to register with Google");
            throw Exception('Failed to load participants');
          }
        }
      }
    } catch (error) {
      print('Error occurred during Google Sign-In: $error');
    }
    setState(() {
      isGoogleLoading = false;
    });
  }

  Future<Tokens> loginFunc(LoginCredentials loginCredentials, context) async {
    final Uri url = Uri.parse(ApiEndpoints.LOGIN_RINGO);
    final jsonBody = jsonEncode(loginCredentials.toJson());
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(url, headers: headers, body: jsonBody);
    const storage = FlutterSecureStorage();

    if (response.statusCode == 200) {
      final jsonResponse = customJsonDecode(response.body);
      DateTime currentTime = DateTime.now();
      DateTime futureTime = currentTime.add(const Duration(seconds: 30));
      storage.write(key: "timestamp", value: futureTime.toString());
      storage.write(key: "access_token", value: jsonResponse['accessToken']);
      storage.write(key: "refresh_token", value: jsonResponse['refreshToken']);

      Uri url = Uri.parse(ApiEndpoints.CURRENT_PARTICIPANT);
      var responseId = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jsonResponse['accessToken']}'
      });
      if (responseId.statusCode == 200) {
        final jsonResponse = customJsonDecode(responseId.body);
        print(jsonResponse);
        storage.write(key: "id", value: jsonResponse['id'].toString());
        if (jsonResponse['emailVerified']) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const Home()),
          );
        } else {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
                builder: (_) => EmailVerificationPage(
                      usersEmail: jsonResponse['email'],
                      usersUsername: jsonResponse['username'],
                    )),
          );
        }
      } else {
        throw Exception('Failed to load participant id');
      }

      return Tokens(
        accessToken: jsonResponse['accessToken'],
        refreshToken: jsonResponse['refreshToken'],
      );
    } else {
      setState(() {
        isRingoLoading = false;
      });
      showErrorAlert("Error", "Please check your credentials", context);
      throw Exception('Failed to login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    const storage = FlutterSecureStorage();

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    SizedBox(
                      height: 145,
                      child: Image.asset(
                          currentTheme.brightness == Brightness.light
                              ? 'assets/images/Ringo-Black.png'
                              : 'assets/images/Ringo-White.png'),
                    ),
                    const SizedBox(height: 12.0),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.colorScheme.primary,
                      ),
                      child: const Text("Login to Ringo"),
                    ),
                    const SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DefaultTextStyle(
                              style: TextStyle(
                                color: currentTheme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              child: const Text('Email'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 50,
                          child: CupertinoTextField(
                            autocorrect: false,
                            onChanged: (value) {
                              setState(() {
                                for (var symbol in value.split('')) {
                                  if (symbol == ' ') {
                                    _emailController.text =
                                        value.replaceAll(' ', '');
                                  }
                                }
                              });
                            },
                            clearButtonMode: OverlayVisibilityMode.editing,
                            cursorColor: currentTheme.colorScheme.primary,
                            controller: _emailController,
                            placeholder: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: currentTheme.colorScheme.primary,
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
                            color: currentTheme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          child: const Text('Password'),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 50,
                          child: CupertinoTextField(
                            autocorrect: false,
                            clearButtonMode: OverlayVisibilityMode.editing,
                            cursorColor: currentTheme.colorScheme.primary,
                            controller: _passwordController,
                            placeholder: 'Enter your password',
                            obscureText: true,
                            style: TextStyle(
                              color: currentTheme.colorScheme.primary,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
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
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 50,
                                child: CupertinoButton(
                                  color: currentTheme.colorScheme.background,
                                  onPressed: () async {
                                    setState(() {
                                      isRingoLoading = true;
                                    });
                                    LoginCredentials credentials =
                                        LoginCredentials(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                    Tokens receivedTokens =
                                        await loginFunc(credentials, context);
                                    storage.write(
                                        key: "access_token",
                                        value: receivedTokens.accessToken);
                                    storage.write(
                                        key: "refresh_token",
                                        value: receivedTokens.refreshToken);
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: (!isRingoLoading)
                                        ? Text(
                                            'Login',
                                            style: TextStyle(
                                              color: currentTheme
                                                  .colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CupertinoActivityIndicator(
                                              radius: 13,
                                              color: currentTheme
                                                  .colorScheme.primary,
                                              animating: true,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
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
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 50,
                                child: CupertinoButton(
                                  color: currentTheme.colorScheme.background,
                                  onPressed: () async {
                                    signInWithGoogle();
                                  },
                                  child: (!isGoogleLoading)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/google-logo.png',
                                              width: 24,
                                              height: 24,
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              'Continue with Google',
                                              style: TextStyle(
                                                color: currentTheme
                                                    .colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: currentTheme
                                                .colorScheme.primary,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        if (Platform.isIOS)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: currentTheme.shadowColor,
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Column(
                                    children: [
                                      SignInWithAppleButton(
                                        style: (currentTheme.brightness ==
                                                Brightness.light)
                                            ? SignInWithAppleButtonStyle.black
                                            : SignInWithAppleButtonStyle.white,
                                        text: 'Continue with Apple',
                                        height: 50,
                                        onPressed: () async {
                                          final credential =
                                              await SignInWithApple
                                                  .getAppleIDCredential(
                                            scopes: [
                                              AppleIDAuthorizationScopes.email,
                                              AppleIDAuthorizationScopes
                                                  .fullName,
                                            ],
                                          );
                                          var idToken =
                                              credential.identityToken;
                                          setState(() {
                                            isAppleLoading = true;
                                          });
                                          var response = await http.post(
                                              Uri.parse(
                                                  ApiEndpoints.LOGIN_APPLE),
                                              body: jsonEncode(
                                                  {"idToken": idToken}),
                                              headers: {
                                                "Content-Type":
                                                    "application/json"
                                              });
                                          if (response.statusCode == 200) {
                                            print("Logged in with Apple");
                                            final jsonResponse =
                                                customJsonDecode(response.body);
                                            DateTime currentTime =
                                                DateTime.now();
                                            DateTime futureTime =
                                                currentTime.add(const Duration(
                                                    seconds: 30));
                                            storage.write(
                                                key: "timestamp",
                                                value: futureTime.toString());
                                            storage.write(
                                                key: "access_token",
                                                value: jsonResponse[
                                                    'accessToken']);
                                            storage.write(
                                                key: "refresh_token",
                                                value: jsonResponse[
                                                    'refreshToken']);
                                            await checkTimestamp();
                                            var url = Uri.parse(ApiEndpoints
                                                .CURRENT_PARTICIPANT);
                                            var responseCheckIfActivated =
                                                await http.get(url, headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization':
                                                  'Bearer ${jsonResponse['accessToken']}'
                                            });
                                            if (responseCheckIfActivated
                                                    .statusCode ==
                                                200) {
                                              final jsonResponse =
                                                  customJsonDecode(
                                                      responseCheckIfActivated
                                                          .body);
                                              print(jsonResponse);
                                              storage.write(
                                                  key: "id",
                                                  value: jsonResponse['id']
                                                      .toString());
                                              if (jsonResponse['dateOfBirth'] ==
                                                  null) {
                                                navigatorKey.currentState
                                                    ?.pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ActivateAccountPage(
                                                      usersEmail:
                                                          jsonResponse['email'],
                                                      usersUsername:
                                                          jsonResponse[
                                                              'username'],
                                                      usersName:
                                                          jsonResponse['name'],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                navigatorKey.currentState
                                                    ?.pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const Home()),
                                                );
                                              }
                                            } else {
                                              setState(() {
                                                isAppleLoading = false;
                                              });
                                              showErrorAlert(
                                                  "Error",
                                                  "Failed to load participant",
                                                  context);
                                              print(
                                                  "Failed to check if account is activated");
                                              throw Exception(
                                                  'Failed to load participants');
                                            }
                                          } else if (response.statusCode ==
                                              401) {
                                            print(
                                                "User not registered with Apple");
                                            var responseSignUp = await http
                                                .post(
                                                    Uri.parse(ApiEndpoints
                                                        .SIGNUP_APPLE),
                                                    body: jsonEncode(
                                                        {"idToken": idToken}),
                                                    headers: {
                                                  "Content-Type":
                                                      "application/json"
                                                });
                                            if (responseSignUp.statusCode ==
                                                200) {
                                              var responseAfterSigningUp =
                                                  await http.post(
                                                      Uri.parse(ApiEndpoints
                                                          .LOGIN_APPLE),
                                                      body: jsonEncode(
                                                          {"idToken": idToken}),
                                                      headers: {
                                                    "Content-Type":
                                                        "application/json"
                                                  });
                                              if (responseAfterSigningUp
                                                      .statusCode ==
                                                  200) {
                                                print("Logged in with Apple");
                                                print(responseAfterSigningUp
                                                    .body);
                                                final jsonResponse =
                                                    customJsonDecode(
                                                        responseAfterSigningUp
                                                            .body);
                                                DateTime currentTime =
                                                    DateTime.now();
                                                DateTime futureTime =
                                                    currentTime.add(
                                                        const Duration(
                                                            seconds: 30));
                                                storage.write(
                                                    key: "timestamp",
                                                    value:
                                                        futureTime.toString());
                                                storage.write(
                                                    key: "access_token",
                                                    value: jsonResponse[
                                                        'accessToken']);
                                                storage.write(
                                                    key: "refresh_token",
                                                    value: jsonResponse[
                                                        'refreshToken']);
                                                await checkTimestamp();
                                                var url = Uri.parse(ApiEndpoints
                                                    .CURRENT_PARTICIPANT);
                                                var responseCheckIfActivated =
                                                    await http
                                                        .get(url, headers: {
                                                  'Content-Type':
                                                      'application/json',
                                                  'Authorization':
                                                      'Bearer ${jsonResponse['accessToken']}'
                                                });
                                                if (responseCheckIfActivated
                                                        .statusCode ==
                                                    200) {
                                                  final jsonResponse =
                                                      customJsonDecode(
                                                          responseCheckIfActivated
                                                              .body);
                                                  print(jsonResponse);
                                                  storage.write(
                                                      key: "id",
                                                      value: jsonResponse['id']
                                                          .toString());
                                                  if (jsonResponse[
                                                          'dateOfBirth'] ==
                                                      null) {
                                                    navigatorKey.currentState
                                                        ?.pushReplacement(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ActivateAccountPage(
                                                          usersEmail:
                                                              jsonResponse[
                                                                  'email'],
                                                          usersUsername:
                                                              jsonResponse[
                                                                  'username'],
                                                          usersName:
                                                              jsonResponse[
                                                                  'name'],
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    navigatorKey.currentState
                                                        ?.pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              const Home()),
                                                    );
                                                  }
                                                }
                                              }
                                            } else {
                                              setState(() {
                                                isAppleLoading = false;
                                              });
                                              showErrorAlert(
                                                  "Error",
                                                  "Failed to register with Apple ",
                                                  context);
                                              throw Exception(
                                                  'Failed to register with Apple');
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPassword(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: currentTheme.colorScheme.primary,
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
                                color: currentTheme.colorScheme.primary,
                                fontSize: 16,
                              ),
                              child: const Text("Don't have an account?"),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: currentTheme.colorScheme.primary,
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
            if (isAppleLoading)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.5),
                child: CupertinoActivityIndicator(
                  radius: 20,
                  color: currentTheme.colorScheme.background,
                  animating: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
