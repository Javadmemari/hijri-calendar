import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'widgets/shamsi_calender.dart';  // مسیر رو طبق پروژه‌ات تنظیم کن

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تقویم شمسی',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto', // فونت پیش‌فرض ساده
      ),
      home: const ShamsiCalendarTestPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShamsiCalendarTestPage extends StatefulWidget {
  const ShamsiCalendarTestPage({super.key});

  @override
  State<ShamsiCalendarTestPage> createState() => _ShamsiCalendarTestPageState();
}

class _ShamsiCalendarTestPageState extends State<ShamsiCalendarTestPage> {
  Jalali? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تست تقویم شمسی'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ShamsiCalendarField(
              initialSelectedDate: selectedDate,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تاریخ انتخاب‌شده: $date')),
                );
              },
            ),
            const SizedBox(height: 20),
            if (selectedDate != null)
              Text(
                'تاریخ انتخاب‌شده: ${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}',
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
