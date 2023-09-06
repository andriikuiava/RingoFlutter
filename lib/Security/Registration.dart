import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ringoflutter/AppTabBar/Profile/Functions/SendPhoto.dart';
import 'package:ringoflutter/Classes/RegistrationCredentialsClass.dart';
import 'package:ringoflutter/Security/Functions/RegisterFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';


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
  late TextEditingController _repeatPasswordController;
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
    _repeatPasswordController = TextEditingController();
    dateController = DateTime.now();
  }

  bool isNameValid = true;
  bool isUsernameValid = true;
  bool isEmailValid = true;
  bool isPasswordValid = true;

  bool isCapitalLetter = false;
  bool isSmallLetter = false;
  bool isNumber = false;
  bool isSpecialSymbol = false;
  bool is8Characters = false;


  bool isFormValid = false;

  bool isLoading = false;

  void validateForm() {
    setState(() {
      isNameValidFunc();
      isUsernameValidFunc();
      isEmailValidFunc();
      isPasswordValidFunc();
      if (isNameValid && isUsernameValid && isEmailValid && isPasswordValid) {
        isFormValid = true;
      } else {
        isFormValid = false;
      }
    });
  }

  void isNameValidFunc() {
    setState(() {
      if (RegExp(r"^.{3,49}$").hasMatch(_fullNameController.text)) {
        isNameValid = true;
      } else {
        isNameValid = false;
      }
    });
  }

  void isUsernameValidFunc() {
    setState(() {
      if (RegExp(r"^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{2,29}$")
          .hasMatch(_usernameController.text)) {
        isUsernameValid = true;
      } else {
        isUsernameValid = false;
      }
    });
  }

  void isEmailValidFunc() {
    setState(() {
      if (RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
          .hasMatch(_emailController.text)) {
        isEmailValid = true;
      } else {
        isEmailValid = false;
      }
    });
  }

  void isPasswordValidFunc() {
    if (RegExp(r"(?=.*[A-Z])").hasMatch(_passwordController.text)) {
      isCapitalLetter = true;
    } else {
      isCapitalLetter = false;
    }
    if (RegExp(r"(?=.*[a-z])").hasMatch(_passwordController.text)) {
      isSmallLetter = true;
    } else {
      isSmallLetter = false;
    }

    if (RegExp(r"(?=.*[0-9])").hasMatch(_passwordController.text)) {
      isNumber = true;
    } else {
      isNumber = false;
    }

    if (RegExp(r'(?=.*[!@#$%^&*(),.?\":{}|<>])').hasMatch(_passwordController.text)) {
      isSpecialSymbol = true;
    } else {
      isSpecialSymbol = false;
    }

    if (RegExp(r"^.{8,64}$").hasMatch(_passwordController.text)) {
      is8Characters = true;
    } else {
      is8Characters = false;
    }

    setState(() {
      if (RegExp(r"((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W]).{8,64})")
          .hasMatch(_passwordController.text)) {
        isPasswordValid = true;
      } else {
        isPasswordValid = false;
      }
    });
  }

  void showPasswordRequirements() {
    showModalBottomSheet<void>(
      elevation: 0,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Column(
            children: [
              if (!isCapitalLetter)
                const Text(
                  '- Password must contain a capital letter',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (!isSmallLetter)
                const Text(
                  '- Password must contain a small letter',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (!isNumber)
                const Text(
                  '- Password must contain number',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (!isSpecialSymbol)
                const Text(
                  '- Password must contain a special symbol',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (!is8Characters)
                const Text(
                  '- Password must be from 8 to 64 characters long',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
            ],
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: Text('Close',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
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
            color: currentTheme.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                        autocorrect: false,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        maxLength: 49,
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
                        onChanged: (value) {
                          if (!isNameValid) {
                            isNameValidFunc();
                            validateForm();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (!isNameValid)
                      const Text(
                        "Name is required",
                        style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                    const SizedBox(width: 8.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DefaultTextStyle(
                          style: TextStyle(
                            color: currentTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          child: const Text('Username'),
                        ),
                        const SizedBox(width: 8.0),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet<void>(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoActionSheet(
                                  title: const Text('Username should be unique, and can contain only letters, numbers, underscores and dots',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),),
                                  actions: <CupertinoActionSheetAction>[
                                    CupertinoActionSheetAction(
                                      child: Text('Close',
                                        style: TextStyle(
                                          color: currentTheme.primaryColor,
                                        ),),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            CupertinoIcons.info,
                            size: 16.0,
                            color: currentTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 50,
                      child: CupertinoTextField(
                        autocorrect: false,
                        clearButtonMode: OverlayVisibilityMode.editing,
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
                        maxLength: 30,
                        onChanged: (value) {
                          if (!isUsernameValid) {
                            isUsernameValidFunc();
                            validateForm();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (!isUsernameValid)
                      const Text(
                        "Username is required",
                        style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                        autocorrect: false,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        maxLength: 256,
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
                        onChanged: (value) {
                          setState(() {
                            for (var symbol in value.split('')) {
                              if (symbol == ' ') {
                                _emailController.text = value.replaceAll(' ', '');
                              }
                            }
                          });
                          if (!isEmailValid) {
                            isEmailValidFunc();
                            validateForm();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (!isEmailValid)
                      const Text(
                        "Email is required",
                        style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                    Row(
                      children: [
                        DefaultTextStyle(
                          style: TextStyle(
                            color: currentTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          child: const Text('Password'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 50,
                      child: CupertinoTextField(
                        autocorrect: false,
                        clearButtonMode: OverlayVisibilityMode.editing,
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
                        onChanged: (value) {
                          if (!isPasswordValid) {
                            isPasswordValidFunc();
                            validateForm();
                          }
                        },
                        maxLength: 64,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (!isPasswordValid)
                      Row(
                        children: [
                          const Text(
                            "Password is required",
                            style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              showPasswordRequirements();
                            },
                            child: const Icon(
                              CupertinoIcons.info,
                              size: 16.0,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20.0),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: currentTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      child: const Text('Repeat password'),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 50,
                      child: CupertinoTextField(
                        autocorrect: false,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        obscureText: true,
                        cursorColor: currentTheme.primaryColor,
                        controller: _repeatPasswordController,
                        placeholder: 'Repeat your password',
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: currentTheme.primaryColor,
                          fontSize: 16,
                        ),
                        decoration: BoxDecoration(
                          color: currentTheme.colorScheme.background,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onChanged: (value) {
                          if (!isPasswordValid) {
                            isPasswordValidFunc();
                            validateForm();
                          }
                        },
                        maxLength: 64,
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
                        minimumDate: DateTime(1900),
                        maximumDate: DateTime.now().add(const Duration(seconds: 5)),
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
                      width: double.infinity,
                      child: SizedBox(
                        width: 320,
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
                      child: SizedBox(
                        height: 50,
                        child: CupertinoButton(
                          color: isFormValid
                              ? currentTheme.primaryColor
                              : currentTheme.colorScheme.background,
                          onPressed: () {
                            validateForm();
                            if (isFormValid) {
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

                              if (_passwordController.text == _repeatPasswordController.text) {
                                setState(() {
                                  isLoading = true;
                                });
                                registerUser(
                                    RegistrationCredentials(
                                        name: _fullNameController.text,
                                        username: _usernameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        dateOfBirth: formattedTimestamp,
                                        gender: genderText
                                    ),
                                    context
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                showErrorAlert("Error", "Passwords do not match", context);
                              }
                            } else {
                              null;
                            }
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: (!isLoading)
                              ? Text(
                              'Register',
                              style: TextStyle(
                                color: isFormValid
                                    ? currentTheme.colorScheme.background
                                    : currentTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                              : CupertinoActivityIndicator(
                              color: currentTheme.colorScheme.background,
                              radius: 13,
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
      ),
    );
  }
}
