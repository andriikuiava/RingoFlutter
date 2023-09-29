import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ringoflutter/Classes/Answer.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';

class FormCompletion extends StatefulWidget {
  final EventFull event;
  final int selectedTicketType;

  const FormCompletion(
      {super.key, required this.event, required this.selectedTicketType});

  @override
  _FormCompletionState createState() => _FormCompletionState();
}

class _FormCompletionState extends State<FormCompletion> {
  final storage = const FlutterSecureStorage();
  List<Answer> answers = [];
  bool isFormCompleted = false;
  bool isLoading = false;

  void prepareFieldsForAnswers() {
    if (widget.event.registrationForm != null) {
      for (var question in widget.event.registrationForm!.questions) {
        switch (question.type) {
          case 'INPUT_FIELD':
            answers.add(Answer(questionId: question.id, content: ''));
            break;
          case 'MULTIPLE_CHOICE':
            answers.add(Answer(questionId: question.id, optionIds: []));
            break;
          case 'CHECKBOX':
            answers.add(Answer(questionId: question.id, optionIds: []));
            break;
        }
      }
    }
  }

  void checkIfFormIsCompleted() {
    isFormCompleted = true;
    if (widget.event.registrationForm != null) {
      for (var question in widget.event.registrationForm!.questions) {
        final answer =
            answers.firstWhere((answer) => answer.questionId == question.id);
        if (question.required) {
          switch (question.type) {
            case 'INPUT_FIELD':
              if (answer.content == '') {
                isFormCompleted = false;
                return;
              }
              break;
            case 'MULTIPLE_CHOICE':
              if (answer.optionIds!.isEmpty) {
                isFormCompleted = false;
                return;
              }
              break;
            case 'CHECKBOX':
              if (answer.optionIds!.isEmpty) {
                isFormCompleted = false;
                return;
              }
              break;
          }
        }
      }
    }
  }

  void getTicket() async {
    setState(() {
      isLoading = true;
    });
    await checkTimestamp();
    var token = await storage.read(key: 'access_token');
    var url = Uri.parse(
        '${ApiEndpoints.SEARCH}/${widget.event.id}/${ApiEndpoints.JOIN}/ticket-types/${widget.selectedTicketType}');
    print(url);
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    Map<String, dynamic> body = {
      "answers": answers.map((answer) => answer.toJson()).toList(),
    };
    print(body);
    var response = await http.post(url,
        headers: headers,
        body:
            (widget.event.registrationForm == null) ? null : jsonEncode(body));
    if (response.statusCode == 200) {
      showSuccessAlert(
          "Success", "You have successfully joined the event", context);
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.statusCode);
      print(response.body);
      showErrorAlert("Error", "Something went wrong", context);
    }
  }

  @override
  void initState() {
    super.initState();
    prepareFieldsForAnswers();
    checkIfFormIsCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
          'Form completion',
          style: TextStyle(color: currentTheme.colorScheme.primary),
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
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                itemCount: (widget.event.registrationForm == null)
                    ? 2
                    : 2 + widget.event.registrationForm!.questions.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    if (widget.event.registrationForm == null) {
                      return Container();
                    } else {
                      return buildNameAndDescriptionOfTheForm(
                          widget.event.registrationForm!);
                    }
                  } else if (widget.event.registrationForm != null &&
                      (index != 0 &&
                          index !=
                              widget.event.registrationForm!.questions.length +
                                  1)) {
                    final question =
                        widget.event.registrationForm!.questions[index - 1];
                    switch (question.type) {
                      case 'INPUT_FIELD':
                        return buildInputFieldQuestion(question);
                      case 'MULTIPLE_CHOICE':
                        return buildMultipleChoiceQuestion(question);
                      case 'CHECKBOX':
                        return buildCheckboxQuestion(question);
                    }
                  } else {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      height: 50,
                      child: Material(
                        elevation: (isFormCompleted) ? 6 : 0,
                        borderRadius: BorderRadius.circular(12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            color: isFormCompleted
                                ? currentTheme.colorScheme.background
                                : currentTheme.colorScheme.primary
                                    .withOpacity(0.2),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: CupertinoButton(
                              child: (isLoading)
                                  ? CupertinoActivityIndicator(
                                      color: currentTheme.colorScheme.primary,
                                    )
                                  : Text(
                                      isFormCompleted
                                          ? 'Get ticket'
                                          : 'Please complete the form',
                                      style: TextStyle(
                                        color: isFormCompleted
                                            ? currentTheme.colorScheme.primary
                                            : currentTheme.colorScheme.primary
                                                .withOpacity(0.6),
                                      ),
                                    ),
                              onPressed: () {
                                checkIfFormIsCompleted();
                                if (isFormCompleted) {
                                  getTicket();
                                } else {
                                  showErrorAlert(
                                      "Error", "Please fill the form", context);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNameAndDescriptionOfTheForm(RegistrationForm registrationForm) {
    var currentTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          color: currentTheme.colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    registrationForm.title,
                    style: TextStyle(
                      fontSize: 22,
                      color: currentTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  child: Text(
                    "${registrationForm.description}",
                    style: TextStyle(
                      fontSize: 18,
                      color: currentTheme.colorScheme.primary,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputFieldQuestion(Question question) {
    final currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "${question.content}${question.required ? ' *' : ''}",
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            maxLength: question.maxCharacters,
            decoration: BoxDecoration(
              color: currentTheme.colorScheme.background,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(16),
            placeholder: 'Answer here',
            clearButtonMode: OverlayVisibilityMode.editing,
            style: TextStyle(
              fontSize: 16,
              color: currentTheme.colorScheme.primary,
            ),
            cursorColor: currentTheme.colorScheme.primary,
            onChanged: (value) {
              final answer = answers
                  .firstWhere((answer) => answer.questionId == question.id);
              answer.content = value;
              checkIfFormIsCompleted();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget buildMultipleChoiceQuestion(Question question) {
    var currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  "${question.content}${question.required ? ' *' : ''}",
                  style: TextStyle(
                    fontSize: 16,
                    color: currentTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                child: CupertinoButton(
                  child: Icon(
                    (answers
                            .firstWhere(
                                (answer) => answer.questionId == question.id)
                            .optionIds!
                            .isNotEmpty)
                        ? CupertinoIcons.clear_circled_solid
                        : CupertinoIcons.clear_circled,
                    color: currentTheme.colorScheme.primary,
                  ),
                  onPressed: () {
                    final answer = answers.firstWhere(
                        (answer) => answer.questionId == question.id);
                    if (answer.optionIds!.isNotEmpty) {
                      answer.optionIds!.clear();
                    }
                    checkIfFormIsCompleted();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return GestureDetector(
                onTap: () {
                  final answer = answers
                      .firstWhere((answer) => answer.questionId == question.id);
                  if (answer.optionIds!.isNotEmpty) {
                    answer.optionIds!.clear();
                  }
                  answer.optionIds!.add(option.id);
                  checkIfFormIsCompleted();
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentTheme.colorScheme.background,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        answers
                                .firstWhere((answer) =>
                                    answer.questionId == question.id)
                                .optionIds!
                                .contains(option.id)
                            ? CupertinoIcons.smallcircle_fill_circle
                            : CupertinoIcons.circle,
                        color: currentTheme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        option.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: currentTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildCheckboxQuestion(Question question) {
    var currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              "${question.content}${question.required ? ' *' : ''}",
              style: TextStyle(
                fontSize: 16,
                color: currentTheme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return GestureDetector(
                onTap: () {
                  final answer = answers
                      .firstWhere((answer) => answer.questionId == question.id);
                  if (answer.optionIds!.contains(option.id)) {
                    answer.optionIds!.remove(option.id);
                  } else {
                    answer.optionIds!.add(option.id);
                  }
                  checkIfFormIsCompleted();
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentTheme.colorScheme.background,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        answers
                                .firstWhere((answer) =>
                                    answer.questionId == question.id)
                                .optionIds!
                                .contains(option.id)
                            ? CupertinoIcons.checkmark_square_fill
                            : CupertinoIcons.square,
                        color: currentTheme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        option.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: currentTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
