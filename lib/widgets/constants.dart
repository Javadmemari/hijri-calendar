import 'package:shamsi_date/shamsi_date.dart';
import '../classes/utils.dart';

const List<String> gregorianMonthNames = [
  '', 'ژانویه', 'فوریه', 'مارس', 'آوریل', 'مه', 'ژوئن',
  'جولای', 'آگوست', 'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر'
];

const List<String> weekDays = [
  'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'
];

const List<String> shortWeekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

const List<String> monthNames = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
];

const List<String> holidayNames = [
  'روز تعطیل', 'مناسبت خاص', 'یادبود', 'تاریخ ویژه'
];

const List<String> moonMonthName = [
  '', 'محرم', 'صفر', 'ربیع‌الاول', 'ربیع‌الثانی', 'جمادی‌الاول', 'جمادی‌الثانی',
  'رجب', 'شعبان', 'رمضان', 'شوال', 'ذی‌القعده', 'ذی‌الحجه'
];

String convertToPersianNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], persian[i]);
  }
  return input;
}
String getMoonMonthName(int month) {
  return moonMonthName[month];
}

String getGregorianMonthName(int month) {
  return gregorianMonthNames[month];
}

String formatFullJalali(Jalali date) {
  final weekDay = weekDays[date.weekDay - 1];  // استفاده از weekDays
  final monthName = monthNames[date.month - 1];  // استفاده از monthNames
  final formattedShort = formatJalali(date); // مثلاً ۱۴۰۴/۰۱/۲۲

  return '$formattedShort - $weekDay ${convertToPersianNumber(date.day.toString())} $monthName ${convertToPersianNumber(date.year.toString())}';
}

String getFullSelectedDateString(Jalali selectedDay, Map<String, dynamic> holidays) {
  final key = '${selectedDay.month}/${selectedDay.day}';
  final dayData = holidays[key];

  final jalaliStr = formatFullJalali(selectedDay); // مثل جمعه 22 فروردین 1404
  String moonStr = '';
  String gregorianStr = '';

  if (dayData != null) {
    final moon = dayData['moon'];
    final gregorian = dayData['gregorian'];

    if (moon != null) {
      moonStr = '${moon['day']} ${getMoonMonthName(moon['month'])} ${moon['year']}';
    }
    if (gregorian != null) {
      gregorianStr = '${gregorian['day']} ${getGregorianMonthName(gregorian['month'])} ${gregorian['year']}';
    }
  }

  return '$jalaliStr'
      '${moonStr.isNotEmpty ? ' - $moonStr' : ''}'
      '${gregorianStr.isNotEmpty ? ' - $gregorianStr' : ''}';
}