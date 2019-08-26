/// parse a date
DateTime dateFromUtcOffset(String dateStr, String timeZoneOffset) {
  DateTime d = DateTime.parse(dateStr);
  if (timeZoneOffset.startsWith("+")) {
    final of = int.parse(timeZoneOffset.replaceFirst("+", ""));
    d = d.add(Duration(hours: of));
  } else if (timeZoneOffset.startsWith("-")) {
    final of = int.parse(timeZoneOffset.replaceFirst("-", ""));
    d = d.subtract(Duration(hours: of));
  }
  return d;
}
