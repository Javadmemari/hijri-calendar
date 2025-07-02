import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'shamsi_calender.dart';

class ShamsiCalendarDialog extends StatelessWidget {
  final Jalali? initialDate;
  final ValueChanged<Jalali> onDateSelected;

  const ShamsiCalendarDialog({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 360,
        height: 360,
        child: ShamsiCalendar(
          initialSelectedDate: initialDate,
          onDateSelected: (selected) {
            onDateSelected(selected);
            Navigator.of(context).pop(); // بستن دیالوگ بعد از انتخاب تاریخ
          },
        ),
      ),
    );
  }
}
