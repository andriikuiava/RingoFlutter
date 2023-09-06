import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/api_endpoints.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  bool isEmailValid = false;

  void validateEmail() {
    setState(() {
      if (RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
          .hasMatch(_emailController.text)) {
        isEmailValid = true;
      } else {
        isEmailValid = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Forgot Password",
          style: TextStyle(
            color: currentTheme.textTheme.displayLarge!.color,
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: currentTheme.primaryColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: currentTheme.scaffoldBackgroundColor,
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: currentTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      child: const Text('Email'),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child:  SizedBox(
                    height: 50,
                    child: CupertinoTextField(
                      autocorrect: false,
                      clearButtonMode: OverlayVisibilityMode.editing,
                      maxLength: 256,
                      onChanged: (value) {
                        validateEmail();
                      },
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 25,
                    ),
                    if (!isEmailValid)
                      const Text(
                        'Please enter a valid email',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: CupertinoButton(
                    color: isEmailValid ? currentTheme.primaryColor : currentTheme.colorScheme.background,
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isEmailValid ? currentTheme.colorScheme.background : currentTheme.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      var url = Uri.parse(ApiEndpoints.FORGOT_PASSWORD);
                      final headers = {'Content-Type': 'application/json'};
                      final jsonBody = jsonEncode({
                        "email": _emailController.text,
                      });
                      print(url);
                      print(headers);
                      print(jsonBody);
                      final response = await http.post(url, headers: headers, body: jsonBody);
                      if (response.statusCode == 200) {
                        showSuccessAlert("Success", "A password reset link has been sent to your email", context);
                        Navigator.pop(context);
                      } else {
                        showErrorAlert("Error", "An error occurred while sending a request", context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
