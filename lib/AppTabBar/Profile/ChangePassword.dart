import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ringoflutter/Security/Functions/LogOutFunc.dart';
import 'package:flutter/animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ringoflutter/api_endpoints.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  bool _expandChangePassword = false;
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

  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> deleteAccount() async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('${ApiEndpoints.CURRENT_PARTICIPANT}');
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
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandChangePassword = !_expandChangePassword;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 24),
                    child: Row(
                      children: [
                        DefaultTextStyle(
                          style: TextStyle(
                            color: currentTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          child: const Text('Change Password'),
                        ),
                        const SizedBox(width: 10.0),
                        Icon(
                            _expandChangePassword
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: currentTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _expandChangePassword
                    ? Column(
                    children: [
                      const SizedBox(height: 20.0),
                      Container(
                          padding: const EdgeInsets.only(left: 24),
                          child: Row(
                            children: [
                              DefaultTextStyle(
                                style: TextStyle(
                                  color: currentTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                child: const Text('Current password'),
                              ),
                              Spacer(),
                            ],
                          )
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
                          child: Row(
                            children: [
                              DefaultTextStyle(
                                style: TextStyle(
                                  color: currentTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                child: const Text('New password'),
                              ),
                              Spacer(),
                            ],
                          )
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
                        child: Row(
                          children: [
                            DefaultTextStyle(
                              style: TextStyle(
                                color: currentTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              child: const Text('Repeat new password'),
                            ),
                            Spacer(),
                          ],
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
                    ],
                  )
                    : const SizedBox.shrink(),
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoButton(
                      color: currentTheme.colorScheme.background,
                      onPressed: () {
                        logOut();
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Align icon and text in the center
                          children: [
                            Icon(
                              CupertinoIcons.square_arrow_left,
                              color: currentTheme.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 10,),
                            Text('Log out',
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
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoButton(
                      color: currentTheme.colorScheme.background,
                      onPressed: deleteAccount,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.delete,
                              color: currentTheme.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 10,),
                            Text('Delete account',
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
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
  void changePassword(String oldPassword, String newPassword) async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('${ApiEndpoints.CHANGE_PASSWORD}');
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
      final jsonResponse = customJsonDecode(response.body);
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
