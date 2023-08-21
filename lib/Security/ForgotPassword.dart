import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();

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
            color: currentTheme.textTheme.headline1!.color,
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
      child: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
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
                  Spacer(),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child:  SizedBox(
                  height: 50,
                  child: CupertinoTextField(
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
                    Text(
                      'Please enter a valid email',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  Spacer(),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: CupertinoButton(
                  color: isEmailValid ? currentTheme.primaryColor : currentTheme.backgroundColor,
                  child: Text(
                    'Send',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isEmailValid ? currentTheme.backgroundColor : currentTheme.primaryColor,
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
                      Navigator.pop(context);
                    } else {
                      var body = customJsonDecode(response.body);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text("Error"),
                            content: Text(body["message"]),
                            actions: [
                              CupertinoDialogAction(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
