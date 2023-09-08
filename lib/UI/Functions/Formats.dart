import 'package:intl/intl.dart';

String convertTimestampToBigDate(String timestamp) {
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

String startTimeFromTimestamp(String timestampStart, String? timestampEnd) {
  DateTime parsedDateTimeStart = DateTime.parse('${timestampStart}Z').toLocal();
  String formattedDateStart = parsedDateTimeStart.day.toString();
  String formattedTimeStart = '${parsedDateTimeStart.hour.toString().padLeft(2, '0')}:${parsedDateTimeStart.minute.toString().padLeft(2, '0')}';
  String formattedMonthStart;

    switch (parsedDateTimeStart.month) {
      case 1:
        formattedMonthStart = 'Jan';
        break;
      case 2:
        formattedMonthStart = 'Feb';
        break;
      case 3:
        formattedMonthStart = 'Mar';
        break;
      case 4:
        formattedMonthStart = 'Apr';
        break;
      case 5:
        formattedMonthStart = 'May';
        break;
      case 6:
        formattedMonthStart = 'Jun';
        break;
      case 7:
        formattedMonthStart = 'Jul';
        break;
      case 8:
        formattedMonthStart = 'Aug';
        break;
      case 9:
        formattedMonthStart = 'Sep';
        break;
      case 10:
        formattedMonthStart = 'Oct';
        break;
      case 11:
        formattedMonthStart = 'Nov';
        break;
      case 12:
        formattedMonthStart = 'Dec';
        break;
      default:
        formattedMonthStart = '';
        break;
    }

  if (timestampEnd == null) {
    String formattedTimestamp = '$formattedMonthStart $formattedDateStart ${parsedDateTimeStart.year}, $formattedTimeStart';
    return formattedTimestamp;
  } else {

    DateTime parsedDateTimeEnd = DateTime.parse('${timestampEnd}Z').toLocal();
    String formattedDateEnd = parsedDateTimeEnd.day.toString();
    String formattedTimeEnd = '${parsedDateTimeEnd.hour.toString().padLeft(2, '0')}:${parsedDateTimeEnd.minute.toString().padLeft(2, '0')}';
    String formattedMonthEnd;

    switch (parsedDateTimeEnd.month) {
      case 1:
        formattedMonthEnd = 'Jan';
        break;
      case 2:
        formattedMonthEnd = 'Feb';
        break;
      case 3:
        formattedMonthEnd = 'Mar';
        break;
      case 4:
        formattedMonthEnd = 'Apr';
        break;
      case 5:
        formattedMonthEnd = 'May';
        break;
      case 6:
        formattedMonthEnd = 'Jun';
        break;
      case 7:
        formattedMonthEnd = 'Jul';
        break;
      case 8:
        formattedMonthEnd = 'Aug';
        break;
      case 9:
        formattedMonthEnd = 'Sep';
        break;
      case 10:
        formattedMonthEnd = 'Oct';
        break;
      case 11:
        formattedMonthEnd = 'Nov';
        break;
      case 12:
        formattedMonthEnd = 'Dec';
        break;
      default:
        formattedMonthEnd = '';
        break;
    }

    String formattedTimestamp = '';

    int durationInHours = parsedDateTimeEnd.difference(parsedDateTimeStart).inHours;

    if (durationInHours < 24) {
      formattedTimestamp = '$formattedMonthStart $formattedDateStart ${parsedDateTimeStart.year}, $formattedTimeStart - $formattedTimeEnd';
    } else {
      formattedTimestamp = '$formattedMonthStart $formattedDateStart ${parsedDateTimeStart.year}, $formattedTimeStart\n$formattedMonthEnd $formattedDateEnd ${parsedDateTimeEnd.year}, $formattedTimeEnd';
    }
    return formattedTimestamp;
  }
}

String convertToKilometersOrMeters(int meters) {
  if (meters >= 1000) {
    double kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(1)}km';
  } else {
    return '${meters.toInt()}m';
  }
}

String convertDateTimeToTimestamp(DateTime dateTime) {
  String year = dateTime.year.toString().padLeft(4, '0');
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');

  return '$year-$month-${day}T$hour:$minute';
}

bool checkIfExpired(String timestamp) {
  DateTime now = DateTime.now();

  DateTime targetDate = DateTime.parse(timestamp);

  if (now.isAfter(targetDate)) {
    return true;
  } else {
    return false;
  }
}

String convertToUtc(DateTime dateTime) {
  final utcDateTime = dateTime.toUtc();

  final formattedUtcTimestamp =
      "${utcDateTime.year}-${_twoDigits(utcDateTime.month)}-${_twoDigits(utcDateTime.day)}T${_twoDigits(utcDateTime.hour)}:${_twoDigits(utcDateTime.minute)}";
  return formattedUtcTimestamp;
}

String _twoDigits(int n) {
  if (n >= 10) {
    return "$n";
  }
  return "0$n";
}