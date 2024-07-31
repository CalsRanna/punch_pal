extension DateTimeExtension on DateTime {
  String formattedWeekday(int length) {
    final week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return week[weekday - 1].substring(0, length.clamp(1, 3));
  }
}
