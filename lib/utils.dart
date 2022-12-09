class Utils{
  // 날짜를 숫자로 변경하는 함수
  static int getFormatTime(DateTime date){
    return int.parse("${date.year}${makeTwoDigit(date.month)}${makeTwoDigit(date.day)}");
  }

  static DateTime numToDateTime(int date){
    String _d = date.toString();
    // 20221205
    int year = int.parse(_d.substring(0, 4));
    int month = int.parse(_d.substring(4, 6));
    int day = int.parse(_d.substring(6, 8));

    return DateTime(year, month, day);
  }

  static DateTime stringToDateTime(String date){
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(4, 6));
    int day = int.parse(date.substring(6, 8));

    return DateTime(year, month, day);
  }

  static String makeTwoDigit(int num){
    /*
    2 => 02
    10 => 10
    3 => 03 으로 변경
     */
    return num.toString().padLeft(2, "0");
  }
}