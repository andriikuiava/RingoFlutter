import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ringoflutter/Security/Functions/RegisterFunc.dart';
import 'package:intl/intl.dart';
import 'package:ringoflutter/Classes/RegistrationCredentialsClass.dart';
import 'dart:io';
import 'package:ringoflutter/AppTabBar/Profile/Functions/SendPhoto.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late DateTime dateController;
  int selectedGender = 2;
  File? image;


  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    dateController = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          'Sign Up',
          style: TextStyle(
            color: currentTheme.primaryColor,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.back,
            color: currentTheme.primaryColor, // Set the desired color here
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
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
                      // Icon(
                      //   CupertinoIcons.person_circle,
                      //   color: currentTheme.primaryColor,
                      //   size: 120,
                      // )
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
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Full name'),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 50,
                    child: CupertinoTextField(
                      cursorColor: currentTheme.primaryColor,
                      controller: _fullNameController,
                      placeholder: 'Enter your name',
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
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Username'),
                  ),
                  const SizedBox(height: 8.0),
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
                ],
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            SliverToBoxAdapter(
              child: Column(
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
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            SliverToBoxAdapter(
              child: Column(
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
                      obscureText: true,
                      cursorColor: currentTheme.primaryColor,
                      controller: _passwordController,
                      placeholder: 'Enter your password',
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
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Date of birth'),
                  ),
                  const SizedBox(height: 8.0),
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
                ],
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Gender'),
                  ),
                  const SizedBox(height: 8.0),
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
                ],
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 26),
            ),
            SliverToBoxAdapter(
              child: Row(
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
                        onPressed: () {
                          String genderText = '';
                          if (selectedGender == 0) {
                            genderText = "MALE";
                          }
                          if (selectedGender == 1) {
                            genderText = "FEMALE";
                          }
                          if (selectedGender == 2) {
                            genderText = "OTHER";
                          }

                          DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                          String formattedTimestamp = dateFormat.format(dateController);
                          registerUser(
                            RegistrationCredentials(
                                name: _fullNameController.text,
                                username: _usernameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                dateOfBirth: formattedTimestamp,
                                gender: genderText,
                              )
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Register',
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
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}
