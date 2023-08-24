import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ringoflutter/Classes/RegistrationFormClass.dart';

class FormCompletion extends StatefulWidget {
  final RegistrationForm form;
  const FormCompletion({super.key, required this.form});

  @override
  _FormCompletionState createState() => _FormCompletionState();
}

class _FormCompletionState extends State<FormCompletion> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('FormCompletion'),
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
      child: ListView.builder(
        itemCount: widget.form.questions.length,
        itemBuilder: (context, index) {
          final question = widget.form.questions[index];

          switch (question.type) {
            case 'INPUT_FIELD':
              return buildInputFieldQuestion(question);
            case 'MULTIPLE_CHOICE':
              return buildMultipleChoiceQuestion(question);
            default:
              return buildUnsupportedQuestion(question);
          }
        },
      ),
    );
  }
}

Widget buildInputFieldQuestion(Question question) {
  return Text('Input field question: ${question.content}');
}

Widget buildMultipleChoiceQuestion(Question question) {
  return Text('Multiple choice question: ${question.content}');
}

Widget buildUnsupportedQuestion(Question question) {
  return Text('Unsupported question type: ${question.type}');
}