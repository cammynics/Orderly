import 'package:intl/intl.dart';

import 'constants.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: currencyLocale,
  symbol: currencySymbol,
  decimalDigits: 2,
);
final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy · h:mm a');

String formatCurrency(num amount) => _currencyFormat.format(amount);

String formatDate(DateTime date) => _dateFormat.format(date);

String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
