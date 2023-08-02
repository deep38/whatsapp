import 'package:whatsapp/utils/global.dart';

final _weekday = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];
final _months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

extension DescribeDate on DateTime {
  String describe() {
    final current = DateTime.now();
    final difference = this.difference(current);

    String description = switch (difference) {
      Duration(inDays: -9) ||
      Duration(inDays: -8) ||
      Duration(inDays: -7) ||
      Duration(inDays: -6) ||
      Duration(inDays: -5) ||
      Duration(inDays: -4) ||
      Duration(inDays: -3) ||
      Duration(inDays: -2) =>
        _weekday[weekday - 1],
      Duration(inDays: -1) => "Yesterday",
      Duration(inDays: 0) => "Today",
      _ => "$day ${_months[month]} $year"
    };

    return description;
  }

  String describeTime() {
    final current = DateTime.now();
    final difference = this.difference(current);

    String description = switch (difference) {
      
      Duration(inDays: -1) => "Yesterday",
      Duration(inDays: 0) => convertTimeToString(millisecondsSinceEpoch),

      Duration(inDays: _) => "${'$day'.padLeft(2, '0')}/${'$month'.padLeft(2, '0')}/$year"
    };

    return description;
  }
}
