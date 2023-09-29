import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ringoflutter/api_endpoints.dart';

class StickerPageToShare extends StatefulWidget {
  final EventFull event;
  StickerPageToShare({Key? key, required this.event}) : super(key: key);

  @override
  _StickerPageToShareState createState() => _StickerPageToShareState();

  ScreenshotController screenshotController = ScreenshotController();
}

class _StickerPageToShareState extends State<StickerPageToShare> {
  @override
  Widget build(BuildContext context) {
    var currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: const Text("Share event"),
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
                controller: widget.screenshotController,
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
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 56,
                                height: MediaQuery.of(context).size.width - 56,
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
                                    CupertinoIcons.calendar,
                                    color: currentTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 4,),
                                  Text(
                                    widget.event.startTime.toString().substring(0, 10),
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
            ],
          )
        ),
      ),
    );
  }
}


