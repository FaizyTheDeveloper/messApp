import 'package:flutter/material.dart';

class MyDate {
  static String getFormatedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    } else {
      return '${sent.day} ${_getMonth(sent)}';
    }
  }

  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 2:
        return 'Apr';
      case 2:
        return 'May';
      case 2:
        return 'Jun';
      case 2:
        return 'Jul';
      case 2:
        return 'Aug';
      case 2:
        return 'Sep';
      case 2:
        return 'Oct';
      case 2:
        return 'Nov';
      case 2:
        return 'Dec';
    }
    return 'N/A';
  }
}
