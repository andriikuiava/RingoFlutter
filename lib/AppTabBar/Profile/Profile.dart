import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/AppTabBar/Profile/Functions/getUserInfo.dart';
import 'package:ringoflutter/Classes/UserClass.dart';
import 'package:ringoflutter/AppTabBar/Profile/EditProfileView.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/AppTabBar/Profile/ChangePassword.dart';
import 'package:ringoflutter/AppTabBar/Profile/SavedEvents.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> userInfoFuture;

  @override
  void initState() {
    super.initState();
    userInfoFuture = getUserInfo();
  }

  Future<void> _refreshData() async {
    await checkTimestamp();
    setState(() {
      userInfoFuture = getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        trailing: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const ChangePasswordView(),
              ),
            );
          },
          child: Icon(
            CupertinoIcons.settings_solid,
            color: currentTheme.primaryColor,
            size: 26,
          ),
        ),
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          'Profile',
          style: TextStyle(
            color: currentTheme.primaryColor,
          ),
        ),
      ),
      child: VisibilityDetector(
        key: Key("profile"),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 1) {
            _refreshData();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: defaultWidgetPadding,
                child: ClipRRect(
                  borderRadius: defaultWidgetCornerRadius,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    color: currentTheme.colorScheme.background,
                    child: FutureBuilder<User>(
                      future: getUserInfo(),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'An ${snapshot.error} occurred',
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final data = snapshot.data;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    if (data!.profilePictureId != null)
                                      Padding(
                                        padding: defaultWidgetPadding,
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: NetworkImage(
                                            'http://localhost:8080/api/photos/${data.profilePictureId}',
                                          ),
                                        ),
                                      ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8,),
                                            Text(
                                              data.name,
                                              style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: currentTheme.primaryColor,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '@${data.username}',
                                              style: const TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 10,),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(width: 12,),
                                    const Icon(
                                      CupertinoIcons.calendar,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8,),
                                    Text(
                                      (data.dateOfBirth == null) ? 'No date of birth provided' : convertTimestampToBigDate(data.dateOfBirth!),
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: currentTheme.primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6,),
                                Row(
                                  children: [
                                    const SizedBox(width: 12,),
                                    const Icon(
                                      CupertinoIcons.person,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8,),
                                    Text(
                                      (data.gender == null) ? 'No gender provided' : capitalizeFirstLetter(data.gender!),
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: currentTheme.primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const SizedBox(width: 12,),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: currentTheme.colorScheme.background, backgroundColor: currentTheme.primaryColor,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => EditProfile(beforeEdit: data),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.pencil,
                                            size: 22,
                                          ),
                                          SizedBox(width: 5,),
                                          Text('Edit Profile')
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                              ],
                            );
                          }
                        }
                        return const Center();
                      },
                    ),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.95,
                child: SavedEventsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}