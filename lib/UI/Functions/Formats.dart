import 'package:intl/intl.dart';

String convertTimestampToBigDate(String timestamp) {
  // Parse the input timestamp
  DateTime dateTime = DateTime.parse(timestamp);

  // Create a DateFormat object with the desired output format
  DateFormat formatter = DateFormat('dd MMMM yyyy');

  // Format the DateTime object using the formatter
  String formattedDate = formatter.format(dateTime);

  return formattedDate;
}

String capitalizeFirstLetter(String input) {
  if (input == null || input.isEmpty) {
    return input;
  }

  String firstLetter = input[0].toUpperCase();
  String restOfWord = input.substring(1).toLowerCase();

  return firstLetter + restOfWord;
}
