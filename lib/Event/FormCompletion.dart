import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';
import 'package:ringoflutter/Classes/Answer.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class FormCompletion extends StatefulWidget {
  final EventFull event;
  const FormCompletion({super.key, required this.event});


  @override
  _FormCompletionState createState() => _FormCompletionState();
}

class _FormCompletionState extends State<FormCompletion> {
  final storage = const FlutterSecureStorage();
  List<Answer> answers = [];
  bool isFormCompleted = false;

  void prepareFieldsForAnswers() {
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

  void checkIfFormIsCompleted() {
    for (var question in widget.event.registrationForm!.questions) {
      final answer = answers.firstWhere((answer) => answer.questionId == question.id);
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
      } else {
        isFormCompleted = true;
      }
    }
  }

  void getTicket() async {
    await checkTimestamp();
    var token = await storage.read(key: 'access_token');
    var url = Uri.parse('${ApiEndpoints.SEARCH}/${widget.event.id}/${ApiEndpoints.JOIN}');
    print(url);
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    Map<String, dynamic> body = {
      "answers": answers.map((answer) => answer.toJson()).toList(),
    };
    print(body);
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      showSuccessAlert("Success", "You have successfully joined the event", context);
      Navigator.pop(context);
    } else {
      showErrorAlert("Error", "Something went wrong", context);
    }
  }



  @override
  void initState() {
    super.initState();
    prepareFieldsForAnswers();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        middle: Text(
        'FormCompletion',
        style: TextStyle(color: currentTheme.primaryColor),
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
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.73,
              child: ListView.builder(
                itemCount: widget.event.registrationForm!.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.event.registrationForm!.questions[index];
                  switch (question.type) {
                    case 'INPUT_FIELD':
                      return buildInputFieldQuestion(question);
                    case 'MULTIPLE_CHOICE':
                      return buildMultipleChoiceQuestion(question);
                    case 'CHECKBOX':
                      return buildCheckboxQuestion(question);
                  }
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.010),
            Container(
              height: 50,
              child: Material(
                elevation: (isFormCompleted) ? 6 : 0,
                borderRadius: BorderRadius.circular(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    color: isFormCompleted
                        ? currentTheme.backgroundColor
                        : currentTheme.primaryColor.withOpacity(0.2),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: CupertinoButton(
                      child: Text(
                        "${isFormCompleted ? 'Submit' : 'Please complete the form'}",
                        style: TextStyle(
                          color: isFormCompleted
                              ? currentTheme.primaryColor
                              : currentTheme.primaryColor.withOpacity(0.6),
                        ),
                      ),
                      onPressed: () {
                        checkIfFormIsCompleted();
                        if (isFormCompleted) {
                          getTicket();
                        } else {
                          showErrorAlert("Error", "Please fill the form", context);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputFieldQuestion(Question question) {
    final currentTheme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "${question.content}${question.required ? ' *' : ''}",
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          CupertinoTextField(
            maxLength: question.maxCharacters,
            decoration: BoxDecoration(
              color: currentTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.all(16),
            placeholder: 'Answer here',
            clearButtonMode: OverlayVisibilityMode.editing,
            style: TextStyle(
              fontSize: 16,
              color: currentTheme.primaryColor,
            ),
            cursorColor: currentTheme.primaryColor,
            onChanged: (value) {
              final answer = answers.firstWhere((answer) => answer.questionId == question.id);
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
      margin: EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  "${question.content}${question.required ? ' *' : ''}",
                  style: TextStyle(
                    fontSize: 16,
                    color: currentTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Container(
                child: CupertinoButton(
                  child: Icon(
                    (answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.isNotEmpty)
                        ? CupertinoIcons.clear_circled_solid
                        : CupertinoIcons.clear_circled,
                    color: currentTheme.primaryColor,
                  ),
                  onPressed: () {
                    final answer = answers.firstWhere((answer) => answer.questionId == question.id);
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
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return GestureDetector(
                onTap: () {
                  final answer = answers.firstWhere((answer) => answer.questionId == question.id);
                  if (answer.optionIds!.isNotEmpty) {
                    answer.optionIds!.clear();
                  }
                  answer.optionIds!.add(option.id);
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                            ? CupertinoIcons.smallcircle_fill_circle
                            : CupertinoIcons.circle,
                        color: currentTheme.primaryColor,
                      ),
                      SizedBox(width: 16),
                      Text(
                        option.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: currentTheme.primaryColor,
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
      margin: EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              "${question.content}${question.required ? ' *' : ''}",
              style: TextStyle(
                fontSize: 16,
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: question.options!.length,
            itemBuilder: (context, index) {
              final option = question.options![index];
              return GestureDetector(
                onTap: () {
                  final answer = answers.firstWhere((answer) => answer.questionId == question.id);
                  if (answer.optionIds!.contains(option.id)) {
                    answer.optionIds!.remove(option.id);
                  } else {
                    answer.optionIds!.add(option.id);
                  }
                  checkIfFormIsCompleted();
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        answers.firstWhere((answer) => answer.questionId == question.id).optionIds!.contains(option.id)
                            ? CupertinoIcons.checkmark_square_fill
                            : CupertinoIcons.square,
                        color: currentTheme.primaryColor,
                      ),
                      SizedBox(width: 16),
                      Text(
                        option.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: currentTheme.primaryColor,
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
