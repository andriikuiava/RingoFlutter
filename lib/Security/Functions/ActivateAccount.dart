import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/LoginCredentialsClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:ringoflutter/AppTabBar/Profile/Functions/SendPhoto.dart';
import 'package:intl/intl.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'dart:convert';
import 'package:ringoflutter/AppTabBar/Home.dart';
import '../checkIsLoggedIn.dart';



class ActivateAccountPage extends StatefulWidget {
  final String usersEmail;
  final String usersUsername;
  final String? usersName;
  const ActivateAccountPage({Key? key, required this.usersEmail, required this.usersUsername, required this.usersName}) : super(key: key);

  @override
  State<ActivateAccountPage> createState() => _ActivateAccountPageState();
}


late TextEditingController _usernameController;
late TextEditingController _nameController;
late TextEditingController _emailController;
late DateTime dateController;
int selectedGender = 2;
File? image;

class _ActivateAccountPageState extends State<ActivateAccountPage> {
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.usersUsername);
    _nameController = TextEditingController(text: widget.usersName);
    _emailController = TextEditingController(text: widget.usersEmail);
    dateController = DateTime.now();
  }

  void activateAccount() async {
    await checkTimestamp();
    var url = Uri.parse(ApiEndpoints.CURRENT_PARTICIPANT);
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedTimestamp = dateFormat.format(dateController);
    var genderString = 'OTHER';
    if (selectedGender == 0) {
      genderString = "MALE";
    } else if (selectedGender == 1) {
      genderString = "FEMALE";
    } else {
      genderString = "OTHER";
    }
    var body = {
      'name': _nameController.text,
      'username': _usernameController.text,
      'dateOfBirth': formattedTimestamp,
      'gender': genderString,
    };
    var jsonBody = jsonEncode(body);
    var response = await http.put(url, headers: headers, body: jsonBody);
    if (response.statusCode == 200) {
      var activateResponse = await http.post(
        Uri.parse(ApiEndpoints.ACTIVATE_ACCOUNT),
        headers: headers,
      );
      if (image != null) {
        sendPhoto(image!);
      }
      print('User activated successfully');
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } else {
      print('User activation failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text('Activate Account',
            style: TextStyle(
                color: currentTheme.primaryColor,
            ),
        ),
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          (image == null)
                              ? Icon(
                            CupertinoIcons.person_circle,
                            color: currentTheme.primaryColor,
                            size: 120,
                          )
                              : CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(image!),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                CupertinoButton(
                                  color: currentTheme.colorScheme.background,
                                  minSize: 40,
                                  padding: EdgeInsets.zero,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 15),
                                      Icon(
                                        CupertinoIcons.photo_fill,
                                        color: currentTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Choose from photos",
                                        style: TextStyle(
                                          color: currentTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    final pickedImage = await pickImage();
                                    if (pickedImage != null) {
                                      setState(() {
                                        image = File(pickedImage.path);
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                CupertinoButton(
                                  color: currentTheme.colorScheme.background,
                                  minSize: 40,
                                  padding: EdgeInsets.zero,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 15),
                                      Icon(
                                        CupertinoIcons.camera_fill,
                                        color: currentTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Take a photo",
                                        style: TextStyle(
                                          color: currentTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    final pickedImage = await takeImage();
                                    if (pickedImage != null) {
                                      setState(() {
                                        image = File(pickedImage.path);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Full Name',
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _nameController,
                      placeholder: 'Enter your full name',
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
                  SizedBox(height: 20),
                  Text('Username',
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _usernameController,
                      placeholder: 'Enter your username',
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
                  SizedBox(height: 20),
                  Text('Email',
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: CupertinoTextField(
                      enabled: false,
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
                  SizedBox(height: 20),
                  Text('Date of Birth',
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      showDayOfWeek: true,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() => dateController = newDate);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Gender',
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, // Take up the full available width
                    child: SizedBox(
                      width: 320, // Set the desired width for the gender picker
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: selectedGender,
                        onValueChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                        children: {
                          0: Text(
                            'Male',
                            style: TextStyle(
                              color: currentTheme.primaryColor,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          1: Text(
                            'Female',
                            style: TextStyle(
                              color: currentTheme.primaryColor,
                              fontSize: 16,
                              decoration: TextDecoration.none,

                            ),
                          ),
                          2: Text(
                            'Other',
                            style: TextStyle(
                              color: currentTheme.primaryColor,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Spacer(),
                      ClipRRect(
                        borderRadius: defaultWidgetCornerRadius,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 50,
                          color: currentTheme.backgroundColor,
                          child: CupertinoButton(
                            onPressed: activateAccount,
                            child: Text('Finish Registration',
                              style: TextStyle(
                                color: currentTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
