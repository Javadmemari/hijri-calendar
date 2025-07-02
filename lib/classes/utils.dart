import 'package:shamsi_date/shamsi_date.dart';

String formatToPersian(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], persian[i]);
  }
  return input;
}

String formatJalali(Jalali date) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final formatted = '${date.year}/${twoDigits(date.month)}/${twoDigits(date.day)}';
  return formatToPersian(formatted);
}
