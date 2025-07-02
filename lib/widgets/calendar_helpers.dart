import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../widgets/constants.dart';
import '../style/styles.dart';

void showMonthPicker({
  required BuildContext context,
  required int currentYear,
  required Function(Jalali newFocusedMonth) onMonthSelected,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ListView.builder(
        itemCount: monthNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Center(child: Text(monthNames[index], style: AppStyles.labelTextStyle)),
            onTap: () {
              final selectedMonth = Jalali(currentYear, index + 1, 1);
              onMonthSelected(selectedMonth);
              Navigator.pop(context);
            },
          );
        },
      );
    },
  );
}

Future<void> showYearPickerDialog({
  required BuildContext context,
  required int currentYear,
  required void Function(int selectedYear) onYearSelected,
}) async {
  final ScrollController scrollController = ScrollController(
    initialScrollOffset: (currentYear - 1300) * 50,
  );

  await showModalBottomSheet(
    context: context,
    builder: (_) {
      return SizedBox(
        height: 500,
        child: ListView.builder(
          controller: scrollController,
          itemCount: 121,
          itemBuilder: (context, index) {
            int year = 1300 + index;
            return ListTile(
              title: Text(
                convertToPersianNumber(year.toString()),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                onYearSelected(year); // بازگشت سال انتخاب شده به بیرون
              },
            );
          },
        ),
      );
    },
  );
}

