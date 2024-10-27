extension DatePrecisionCompare on DateTime {
  bool isBetweenDates(DateTime start, DateTime end) {
    DateTime dayStart;
    DateTime dayEnd;

    dayStart = DateTime(start.year, start.month, start.day);
    dayEnd = DateTime(end.year, end.month, end.day, 23, 59);

    return (isAfter(dayStart) || isAtSameMomentAs(dayStart)) &&
        (isBefore(dayEnd) || isAtSameMomentAs(dayEnd));
  }
}
