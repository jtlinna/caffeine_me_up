import 'package:intl/intl.dart';

final DateFormat _format = new DateFormat('dd.MM.yyyy HH:mm');

String formatDateTime(DateTime time) {
  return _format.format(time);
}