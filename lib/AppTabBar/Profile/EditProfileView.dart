import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ringoflutter/AppTabBar/Profile/Functions/SendPhoto.dart';
import 'package:ringoflutter/Classes/UserClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';

class EditProfile extends StatefulWidget {
  final User beforeEdit;

  const EditProfile({Key? key, required this.beforeEdit}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late DateTime dateController;
  late ValueNotifier<DateTime> _dateController;
  int selectedGender = 2;
  File? image;

  bool isFullNameValid = true;
  bool isUsernameValid = true;
  bool isFormValid = true;

  void validateFields() {
    setState(() {
      if (RegExp(r"^.{3,49}$").hasMatch(_fullNameController.text)) {
        isFullNameValid = true;
      } else {
        isFullNameValid = false;
      }

      if (RegExp(r"^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{2,29}$")
          .hasMatch(_usernameController.text)) {
        isUsernameValid = true;
      } else {
        isUsernameValid = false;
      }

      if (isFullNameValid && isUsernameValid) {
        isFormValid = true;
      } else {
        isFormValid = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _fullNameController.text = widget.beforeEdit.name;
    _usernameController.text = widget.beforeEdit.username;
    if (widget.beforeEdit.gender == "MALE") {
      selectedGender = 0;
    }
    if (widget.beforeEdit.gender == "FEMALE") {
      selectedGender = 1;
    }
    if (widget.beforeEdit.gender == "OTHER") {
      selectedGender = 2;
    }
    _dateController = ValueNotifier<DateTime>(DateTime.parse(widget.beforeEdit.dateOfBirth!));
  }

  void updateUser(File? image, int genderId, String dateOfBirth) async {
    await checkTimestamp();
    var selectedGender = "";
    if (genderId == 0) {
      selectedGender = "MALE";
    }
    if (genderId == 1) {
      selectedGender = "FEMALE";
    }
    if (genderId == 2) {
      selectedGender = "OTHER";
    }
    Uri url = Uri.parse('${ApiEndpoints.CURRENT_PARTICIPANT}');
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    var headers = {
      'Content-Type': "application/json; charset=UTF-8",
      'Authorization': "Bearer $token",
    };
    var body = jsonEncode({
      'name': _fullNameController.text,
      'username': _usernameController.text,
      'gender': selectedGender,
      'dateOfBirth': dateOfBirth,
    });
    var response = await http.put(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print("Uploaded!");
      if (image != null) {
        sendPhoto(image);
      }
    } else {
      print("Error during connection to the server.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final leadingPadding = screenWidth * 0.05;



    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          "Edit Profile",
          style: TextStyle(
            color: currentTheme.primaryColor,
            fontSize: 16,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            color: currentTheme.primaryColor,
          ),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 12.0),
            FractionallySizedBox(
              widthFactor: 0.9,
                child: Row(
                  children: [
                    (image == null)
                        ? (widget.beforeEdit.profilePictureId == null)
                    ? Icon(
                      CupertinoIcons.person_circle,
                      color: currentTheme.primaryColor,
                      size: 120,
                    )
                    : CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage("${ApiEndpoints.GET_PHOTO}/${widget.beforeEdit.profilePictureId}"),)
                        : CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(image!),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          CupertinoButton(
                            color: currentTheme.backgroundColor,
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
            ),
                const SizedBox(height: 12.0),
                Container(
                  padding: EdgeInsets.only(left: leadingPadding),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Full name'),
                  ),
                ),
                const SizedBox(height: 4.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoTextField(
                      onChanged: (value) {
                        validateFields();
                      },
                      maxLength: 49,
                      cursorColor: currentTheme.primaryColor,
                      controller: _fullNameController,
                      placeholder: 'Enter your name',
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
                const SizedBox(height: 8.0),
                if (!isFullNameValid)
                  Container(
                    padding: EdgeInsets.only(left: leadingPadding),
                    child: const DefaultTextStyle(
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      child: const Text('Full name is required'),
                    ),
                  ),
                const SizedBox(height: 12.0),
                Container(
                  padding: EdgeInsets.only(left: leadingPadding),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Username'),
                  ),
                ),
                const SizedBox(height: 4.0),
                SizedBox(
                  height: 50,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: CupertinoTextField(
                      maxLength: 30,
                      onChanged: (value) {
                        validateFields();
                      },
                      cursorColor: currentTheme.primaryColor,
                      controller: _usernameController,
                      placeholder: 'Enter your username',
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
                const SizedBox(height: 8.0),
                if (!isUsernameValid)
                  Container(
                    padding: EdgeInsets.only(left: leadingPadding),
                    child: const DefaultTextStyle(
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      child: const Text('Username is required'),
                    ),
                  ),
                const SizedBox(height: 12.0),
                Container(
                  padding: EdgeInsets.only(left: leadingPadding),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Date of birth'),
                  ),
                ),
                const SizedBox(height: 4.0),
                SizedBox(
                  height: 180,
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: _dateController,
                    builder: (context, value, _) {
                      return SizedBox(
                        height: 180,
                        child: CupertinoDatePicker(
                          minimumDate: DateTime(1900),
                          maximumDate: DateTime.now(),
                          mode: CupertinoDatePickerMode.date,
                          showDayOfWeek: true,
                          initialDateTime: value,
                          onDateTimeChanged: (DateTime newDate) {
                            _dateController.value = newDate;
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: EdgeInsets.only(left: leadingPadding),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    child: const Text('Gender'),
                  ),
                ),
                const SizedBox(height: 4.0),
                CupertinoSlidingSegmentedControl<int>(
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
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    1: Text(
                      'Female',
                      style: TextStyle(
                        color: currentTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    2: Text(
                      'Other',
                      style: TextStyle(
                        color: currentTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  },
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 50,
                      child: CupertinoButton(
                        color: currentTheme.backgroundColor,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: currentTheme.primaryColor,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 50,
                      child: CupertinoButton(
                        color: isFormValid
                            ? currentTheme.backgroundColor
                            : currentTheme.backgroundColor.withOpacity(0.5),
                        onPressed: () async {
                          validateFields();
                          if (isFormValid) {
                            DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                            String formattedTimestamp = dateFormat.format(_dateController.value);
                            updateUser(image, selectedGender, formattedTimestamp);
                            Navigator.pop(context);
                          } else {
                            null;
                          }
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: isFormValid
                                  ? currentTheme.primaryColor
                                  : currentTheme.primaryColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
        ],
      ),
    );
  }
}
