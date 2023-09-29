import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Security/LoginPage.dart';
import 'package:ringoflutter/api_endpoints.dart';

class EmailVerificationPage extends StatefulWidget {
  final String usersEmail;
  final String usersUsername;

  const EmailVerificationPage(
      {Key? key, required this.usersEmail, required this.usersUsername})
      : super(key: key);

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

  Future<void> resendEmail() async {
    setState(() {
      _isResendActive = false;
      _resendTimer = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _isResendActive = true;
          _timer.cancel();
        }
      });
    });
    Uri url = Uri.parse(
        '${ApiEndpoints.RESEND_CONFIRMATION_LINK}?username=${widget.usersUsername}');
    var response = await http.get(url);
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
            color: currentTheme.colorScheme.primary,
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
                  color: currentTheme.colorScheme.primary,
                  decoration: TextDecoration.none),
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
                  color: currentTheme.colorScheme.primary,
                  decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
              'Please verify your e-mail address to continue',
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: currentTheme.colorScheme.primary,
                  decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: currentTheme.colorScheme.background,
                  backgroundColor: currentTheme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_turn_down_left,
                      color: currentTheme.colorScheme.background,
                      size: 20,
                    ),
                    Text(
                      'Start over',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: currentTheme.colorScheme.background,
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: currentTheme.colorScheme.background,
                    backgroundColor: currentTheme.colorScheme.primary,
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
                            ? currentTheme.colorScheme.background
                            : currentTheme.colorScheme.primary,
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
                              ? currentTheme.colorScheme.background
                              : currentTheme.colorScheme.primary,
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
              //     primary: currentTheme.colorScheme.primary,
              //     onPrimary: currentTheme.colorScheme.background,
              //     backgroundColor: currentTheme.colorScheme.primary,
              //   ),
              //   onPressed: () async {
              //     logOut();
              //   },
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Icon(
              //         CupertinoIcons.square_arrow_left,
              //         color: currentTheme.colorScheme.background,
              //         size: 20,
              //       ),
              //       Text(
              //         'Log out',
              //         style: TextStyle(
              //             fontSize: 12,
              //             fontWeight: FontWeight.normal,
              //             color: currentTheme.colorScheme.background,
              //             decoration: TextDecoration.none
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const Spacer(),
            ],
          )
        ],
      )),
    );
  }
}
