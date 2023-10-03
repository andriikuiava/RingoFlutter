import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_share/social_share.dart';

class StickerPageToShare extends StatefulWidget {
  final EventFull event;
  StickerPageToShare({Key? key, required this.event}) : super(key: key);

  @override
  _StickerPageToShareState createState() => _StickerPageToShareState();
}

class _StickerPageToShareState extends State<StickerPageToShare> {
  bool isOtherLoading = false;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = Theme.of(context);
    ScreenshotController screenshotController = ScreenshotController();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
            "Share event",
            style: TextStyle(
              color: currentTheme.colorScheme.primary,
              fontSize: 18,
            ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            color: currentTheme.colorScheme.primary,
            size: 24,
          ),
        ),
      ),
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Screenshot(
                controller: screenshotController,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        color: currentTheme.primaryColor,
                        child: ListTile(
                          leading: (widget.event.host.profilePictureId != null)
                              ? CircleAvatar(
                            radius: 24,
                            backgroundColor: currentTheme.colorScheme.background,
                            backgroundImage: NetworkImage(
                              "${ApiEndpoints.GET_PHOTO}/${widget.event.host.profilePictureId}",
                            ),
                          )
                              : null,
                          title: Text(
                            widget.event.name,
                            style: TextStyle(
                              color: currentTheme.scaffoldBackgroundColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Hosted by ${widget.event.host.name}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        color: currentTheme.colorScheme.background,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 56,
                                height: MediaQuery.of(context).size.width - 56,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    "${ApiEndpoints.GET_PHOTO}/${widget.event.mainPhoto.mediumQualityId}",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar_today,
                                    color: currentTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8,),
                                  Text(
                                    startTimeFromTimestamp(widget.event.startTime!, widget.event.endTime),
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.map_pin,
                                    color: currentTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8,),
                                  Text(
                                    widget.event.address!,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.money_dollar_circle,
                                    color: currentTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8,),
                                  Text(
                                    (widget.event.price != null)
                                    ? (widget.event.price == 0)
                                      ? "Free"
                                      : "from ${widget.event.currency!.symbol}${widget.event.price!.toStringAsFixed(2)}"
                                    : constructPrice(widget.event),
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8,),
                              Row(
                                children: [
                                  Text(
                                    "www.ringo-events.com",
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: currentTheme.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
              const SizedBox(height: 12,),
              Container(
                width: MediaQuery.of(context).size.width - 20,
                child: CupertinoButton(
                  color: currentTheme.colorScheme.background,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Icon(
                        CupertinoIcons.share,
                        color: currentTheme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8,),
                      Text(
                        "Share",
                        style: TextStyle(
                          color: currentTheme.colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  onPressed: () async {
                    var facebookAppId = "1020391179152310";
                    var avaliableApps = await SocialShare.checkInstalledAppsForShare();
                    showAdaptiveActionSheet(
                      context: context,
                      title: const Text('Share event'),
                      androidBorderRadius: 30,
                      actions: <BottomSheetAction>[
                        if (avaliableApps!['instagram'] == true)
                          BottomSheetAction(
                              title: const Text('Add to Instagram Story'),
                              onPressed: (context) async {
                                Navigator.pop(context);
                                screenshotController.capture().then((Uint8List? image) async {
                                  var file = await DefaultCacheManager().putFile(
                                    "123",
                                    image!,
                                  );
                                  await SocialShare.shareInstagramStory(
                                    appId: facebookAppId,
                                    imagePath: file.path,
                                    backgroundTopColor: currentTheme.brightness == Brightness.light ? "#dddddd" : "#666666",
                                    backgroundBottomColor: currentTheme.brightness == Brightness.light ? "#dddddd" : "#666666",
                                    backgroundResourcePath:
                                    "assets/images/Ringo-Black.png",
                                    attributionURL:
                                    "https://ringo-events.com/event/${widget.event.id}",
                                  );
                                });
                              }
                          ),
                        if (avaliableApps['facebook'] == true)
                          BottomSheetAction(
                              title: const Text('Add to Facebook Story'),
                              onPressed: (context) async {
                                Navigator.pop(context);
                                screenshotController.capture().then((Uint8List? image) async {
                                  var file = await DefaultCacheManager().putFile(
                                    "${ApiEndpoints.GET_PHOTO}/${widget.event.mainPhoto.mediumQualityId}",
                                    image!,
                                  );
                                  await SocialShare.shareFacebookStory(
                                    appId: facebookAppId,
                                    imagePath: file.path,
                                    backgroundTopColor: currentTheme.brightness == Brightness.light ? "#dddddd" : "#666666",
                                    backgroundBottomColor: currentTheme.brightness == Brightness.light ? "#dddddd" : "#666666",
                                    backgroundResourcePath:
                                    "assets/images/Ringo-Black.png",
                                    attributionURL:
                                    "https://ringo-events.com/event/${widget.event.id}",
                                  );
                                });
                              }
                          ),
                        BottomSheetAction(title: (isOtherLoading) ? CupertinoActivityIndicator(color: currentTheme.primaryColor,) : Text('Other options'), onPressed: (context) async {
                          Navigator.pop(context);
                          setState(() {
                            isOtherLoading = true;
                          });
                          var file = await DefaultCacheManager().getSingleFile(
                              "${ApiEndpoints.GET_PHOTO}/${widget.event.mainPhoto.mediumQualityId}");
                          await Share.shareXFiles(
                            [
                              XFile(
                                file.path,
                              ),
                            ],
                            text:
                            "Check out ${widget.event.name} by ${widget.event.host.name} on Ringo!\nhttps://ringo-events.com/event/${widget.event.id}",
                          );
                          setState(() {
                            isOtherLoading = false;
                          });
                        }),
                      ],
                      cancelAction: CancelAction(
                        title: Text('Cancel',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            )
                        ),
                      ),
                    );
                    await Future.delayed(Duration(seconds: 5));
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 52,),
            ],
          )
        ),
      ),
    );
  }
}



