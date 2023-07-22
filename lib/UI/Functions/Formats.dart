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


String convertHourTimestamp(String timestamp) {
  DateTime parsedDateTime = DateTime.parse(timestamp);
  String formattedDate = parsedDateTime.day.toString();
  String formattedTime = parsedDateTime.hour.toString().padLeft(2, '0') +
      ':' +
      parsedDateTime.minute.toString().padLeft(2, '0');
  String formattedMonth;

  switch (parsedDateTime.month) {
    case 1:
      formattedMonth = 'January';
      break;
    case 2:
      formattedMonth = 'February';
      break;
    case 3:
      formattedMonth = 'March';
      break;
    case 4:
      formattedMonth = 'April';
      break;
    case 5:
      formattedMonth = 'May';
      break;
    case 6:
      formattedMonth = 'June';
      break;
    case 7:
      formattedMonth = 'July';
      break;
    case 8:
      formattedMonth = 'August';
      break;
    case 9:
      formattedMonth = 'September';
      break;
    case 10:
      formattedMonth = 'October';
      break;
    case 11:
      formattedMonth = 'November';
      break;
    case 12:
      formattedMonth = 'December';
      break;
    default:
      formattedMonth = '';
      break;
  }

  String formattedTimestamp = '$formattedMonth $formattedDate ${parsedDateTime.year}, $formattedTime';
  return formattedTimestamp;
}
