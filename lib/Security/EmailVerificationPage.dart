import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/Security/Functions/LogoutFunc.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/api_endpoints.dart';

class EmailVerificationPage extends StatefulWidget {
  final String usersEmail;
  const EmailVerificationPage({Key? key, required this.usersEmail}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResendActive = true;
  int _resendTimer = 300;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> deleteAccount() async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse("${ApiEndpoints.CURRENT_PARTICIPANT}");
    var headers = {
      'Authorization': 'Bearer ${token}',
    };
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
      print('Account deleted');
      logOut();
    } else {
      print('Account not deleted');
    }
  }


  Future<void> resendEmail() async {
    setState(() {
      _isResendActive = false;
      _resendTimer = 30;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _isResendActive = true;
          _timer.cancel();
        }
      });
    });
    await checkTimestamp();
    var storage = FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    Uri url = Uri.parse('${ApiEndpoints.RESEND_CONFIRMATION_LINK}');
    var headers = {
      'Authorization': 'Bearer ${token}'
    };
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      print('Email sent');
    } else {
      throw Exception('Failed to send email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.mail_solid,
              size: 100,
              color: currentTheme.primaryColor,
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                'E-mail was sent to',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.primaryColor,
                    decoration: TextDecoration.none
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                widget.usersEmail,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.primaryColor,
                    decoration: TextDecoration.none
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please verify your e-mail address to continue',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: currentTheme.primaryColor,
                  decoration: TextDecoration.none
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: currentTheme.primaryColor,
                    onPrimary: currentTheme.backgroundColor,
                    backgroundColor: currentTheme.primaryColor,
                  ),
                  onPressed: () async {
                    deleteAccount();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.arrow_turn_down_left,
                        color: currentTheme.backgroundColor,
                        size: 20,
                      ),
                      Text(
                        'Start over',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: currentTheme.backgroundColor,
                            decoration: TextDecoration.none
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 40,
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: currentTheme.primaryColor,
                      onPrimary: currentTheme.backgroundColor,
                      backgroundColor: currentTheme.primaryColor,
                    ),
                    onPressed: _isResendActive
                        ? () async {
                      await resendEmail();
                    }
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.refresh,
                          color: _isResendActive
                              ? currentTheme.backgroundColor
                              : currentTheme.primaryColor,
                          size: 20,
                        ),
                        Text(
                          _isResendActive
                              ? 'Resend'
                              : 'Try again in $_resendTimer s',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: _isResendActive
                                ? currentTheme.backgroundColor
                                : currentTheme.primaryColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     primary: currentTheme.primaryColor,
                //     onPrimary: currentTheme.backgroundColor,
                //     backgroundColor: currentTheme.primaryColor,
                //   ),
                //   onPressed: () async {
                //     logOut();
                //   },
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Icon(
                //         CupertinoIcons.square_arrow_left,
                //         color: currentTheme.backgroundColor,
                //         size: 20,
                //       ),
                //       Text(
                //         'Log out',
                //         style: TextStyle(
                //             fontSize: 12,
                //             fontWeight: FontWeight.normal,
                //             color: currentTheme.backgroundColor,
                //             decoration: TextDecoration.none
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Spacer(),
              ],
            )
          ],
        )
      ),
    );
  }
}
