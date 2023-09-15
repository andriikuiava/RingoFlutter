import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/ReviewClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';

class RateHost extends StatefulWidget {
  final Review? review;
  final bool createdReview;
  final int organisationId;

  const RateHost({Key? key, this.review, required this.createdReview, required this.organisationId}) : super(key: key);

  @override
  _RateHostState createState() => _RateHostState();
}

class _RateHostState extends State<RateHost> {
  int newRating = 3;
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
    if (widget.createdReview && widget.review != null) {
      _reviewController.text = widget.review!.comment!;
      newRating = widget.review!.rate;
    }
  }

  void deleteReview() async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    var url = Uri.parse("${ApiEndpoints.GET_ORGANISATION}/${widget.organisationId}/${ApiEndpoints.REVIEWS}");
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
      showSuccessAlert("Review deleted", null, context);
      Navigator.pop(context);
    } else {
      showErrorAlert("Error", "An error occurred deleting review", context);
      print("Error occurred deleting a review");
    }
  }

  void createReview() async {
    await checkTimestamp();
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: "access_token");
    var url = Uri.parse("${ApiEndpoints.GET_ORGANISATION}/${widget.organisationId}/${ApiEndpoints.REVIEWS}");
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode({
      "rate": newRating,
      "comment": _reviewController.text,
    });

    if (!widget.createdReview) {
      var response = await http.post(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        showSuccessAlert("Review created", null, context);
        Navigator.pop(context);
      } else {
        showErrorAlert("Error", "An error occurred creating review", context);
        print("Error occurred creating a review");
      }
    } else {
      var response = await http.put(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        showSuccessAlert("Review edited", null, context);
        Navigator.pop(context);
      } else {
        showErrorAlert("Error", "An error occurred editing review", context);
        print("Error occurred editing review");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          widget.createdReview
          ? 'Edit a review'
          : 'Rate this host',
          style: TextStyle(
            color: currentTheme.colorScheme.primary,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            color: currentTheme.colorScheme.primary,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              ClipRRect(
                borderRadius: defaultWidgetCornerRadius,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  color: currentTheme.colorScheme.background,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          RatingBar.builder(
                            itemSize: 24,
                            initialRating: widget.review?.rate.toDouble() ?? 3.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              CupertinoIcons.star_fill,
                              color: currentTheme.colorScheme.primary,
                            ),
                            onRatingUpdate: (rating) {
                              newRating = rating.toInt();
                            },
                          ),
                          const Spacer(),
                          if (widget.createdReview)
                            GestureDetector(
                              onTap: deleteReview,
                              child: Icon(
                                CupertinoIcons.delete,
                                size: 24,
                                color: currentTheme.colorScheme.primary,
                              ),
                            ),
                          const SizedBox(width: 10,)
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: CupertinoTextField(
                          maxLength: 2048,
                          cursorColor: currentTheme.colorScheme.primary,
                          placeholder: 'Create a review',
                          controller: _reviewController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          style: TextStyle(
                            color: currentTheme.colorScheme.primary,
                            fontSize: 16,
                          ),
                          decoration: BoxDecoration(
                            color: currentTheme.colorScheme.background,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onChanged: (value) {
                            // validateForm();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: defaultWidgetCornerRadius,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            color: currentTheme.colorScheme.background,
                            child: CupertinoButton(
                              color: currentTheme.colorScheme.primary,
                              onPressed: createReview,
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: currentTheme.scaffoldBackgroundColor,
                                ),
                              ),
                            )
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
