import 'package:intl/intl.dart';

/// Shared date formatting helpers for Firestore contracts.
class DateUtil {
  DateUtil._();

  static final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd');

  static String toDateKey(DateTime value) => _dateKeyFormat.format(value);
}
