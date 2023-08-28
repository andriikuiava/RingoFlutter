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
  if (input.isEmpty) {
    return input;
  }

  String firstLetter = input[0].toUpperCase();
  String restOfWord = input.substring(1).toLowerCase();

  return firstLetter + restOfWord;
}


String convertHourTimestamp(String timestamp) {
  DateTime parsedDateTime = DateTime.parse(timestamp);
  String formattedDate = parsedDateTime.day.toString();
  String formattedTime = '${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}';
  String formattedMonth;

  switch (parsedDateTime.month) {
    case 1:
      formattedMonth = 'Jan';
      break;
    case 2:
      formattedMonth = 'Feb';
      break;
    case 3:
      formattedMonth = 'Mar';
      break;
    case 4:
      formattedMonth = 'Apr';
      break;
    case 5:
      formattedMonth = 'May';
      break;
    case 6:
      formattedMonth = 'Jun';
      break;
    case 7:
      formattedMonth = 'Jul';
      break;
    case 8:
      formattedMonth = 'Aug';
      break;
    case 9:
      formattedMonth = 'Sep';
      break;
    case 10:
      formattedMonth = 'Oct';
      break;
    case 11:
      formattedMonth = 'Nov';
      break;
    case 12:
      formattedMonth = 'Dec';
      break;
    default:
      formattedMonth = '';
      break;
  }

  String formattedTimestamp = '$formattedMonth $formattedDate ${parsedDateTime.year}, $formattedTime';
  return formattedTimestamp;
}
