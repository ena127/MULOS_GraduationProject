class FormatUtil{

  static timestampToString (int timestamp){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    int hour = dateTime.hour;
    int minute = dateTime.minute;

    return "$year - $month - $day - $hour:$minute";
  }

}