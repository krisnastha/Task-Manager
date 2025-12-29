import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String toShortDate() => DateFormat("MMM d, yyyy").format(this);
}
