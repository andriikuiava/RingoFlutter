import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Classes/OrganisationClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HostPage extends StatelessWidget {
  final int hostId;

  const HostPage({Key? key, required this.hostId}) : super(key: key);

  Future<Organisation> getHostById() async {
    checkTimestamp();
    final storage = new FlutterSecureStorage();
    var token = await storage.read(key: 'access_token');
    Uri url = Uri.parse('http://localhost:8080/api/organisations/${hostId}');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return Organisation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load host');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return FutureBuilder<Organisation>(
      future: getHostById(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CupertinoPageScaffold(
            backgroundColor: currentTheme.scaffoldBackgroundColor,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: currentTheme.scaffoldBackgroundColor,
              middle: Text(
                "Organisation",
                style: TextStyle(
                  color: currentTheme.primaryColor,
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
            child: Center(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.9,
                        decoration: BoxDecoration(
                          color: currentTheme.backgroundColor,
                          borderRadius: defaultWidgetCornerRadius,
                        ),
                        constraints: BoxConstraints(maxWidth: double.infinity),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10,),
                                if (snapshot.data!.profilePictureId! != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 9),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage: NetworkImage(
                                          'http://localhost:8080/api/photos/${snapshot
                                              .data!.profilePictureId!}',
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 9,),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data!.name!,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: currentTheme.primaryColor,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "@${snapshot.data!.username}"!,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  snapshot.data!.description!,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: currentTheme.primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8,),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.9,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: currentTheme.scaffoldBackgroundColor,
                                ),
                                onPressed: () {},
                                child: Text(
                                  "Contact host",
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: currentTheme.primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6,),
                          ],
                        )
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }
}