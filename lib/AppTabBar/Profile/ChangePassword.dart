import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _repeatNewPasswordController;
  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _repeatNewPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            color: currentTheme.primaryColor,
          ),
        ),
        middle: Text('Settings',
        style: TextStyle(
          color: currentTheme.primaryColor,
        ),),
      ),
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.only(left: 24),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Current password'),
                  ),
                ),
                const SizedBox(height: 6.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _oldPasswordController,
                      placeholder: 'Enter your current password',
                      keyboardType: TextInputType.text,
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
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.only(left: 24),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('New password'),
                  ),
                ),
                const SizedBox(height: 6.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _newPasswordController,
                      placeholder: 'Enter your new password',
                      keyboardType: TextInputType.text,
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
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.only(left: 24),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Repeat new password'),
                  ),
                ),
                const SizedBox(height: 6.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _repeatNewPasswordController,
                      placeholder: 'Repeat your new password',
                      keyboardType: TextInputType.text,
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
                const SizedBox(height: 20.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoButton(
                      color: currentTheme.colorScheme.background,
                      onPressed: () {
                        checkTimestamp();
                        changePassword(_oldPasswordController.text,
                            _newPasswordController.text
                        );
                      },
                      child: Text('Change password',
                        style: TextStyle(
                          color: currentTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoButton(
                      color: currentTheme.colorScheme.background,
                      onPressed: () {
                        logOut();
                      },
                      child: Text('Log out',
                        style: TextStyle(
                          color: currentTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                  ),
                ),
              ]
            )
          )
        ],
      )
    );
  }
  void changePassword(String oldPassword, String newPassword) async {
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('http://localhost:8080/api/auth/change-password');
    var headers = {
      'Authorization': "Bearer $token",
      'Content-Type': "application/json",
    };
    var body = {
      'password': oldPassword,
      'newPassword': newPassword,
    };
    print(headers);
    var response = await http.post(url, headers: headers, body: json.encode(body));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      await storage.write(key: "access_token", value: jsonResponse['accessToken']);
      await storage.write(key: "refresh_token", value: jsonResponse['refreshToken']);

      DateTime currentTime = DateTime.now();
      DateTime futureTime = currentTime.add(const Duration(minutes: 5));
      storage.write(key: "timestamp", value: futureTime.toString());

      Navigator.pop(context);
    } else {
      print('Password not changed');
    }
  }
}
