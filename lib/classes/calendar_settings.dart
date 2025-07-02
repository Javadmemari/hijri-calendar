import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarSettings extends ChangeNotifier {
  int startWeekday;
  Color backgroundColor;
  Color selectedDayColor;
  Color todayColor;
  Color dayTextColor;
  Color selectedDayTextColor;

  CalendarSettings({
    required this.startWeekday,
    required this.backgroundColor,
    required this.selectedDayColor,
    required this.todayColor,
    required this.dayTextColor,
    required this.selectedDayTextColor,
  });

  static CalendarSettings defaultSettings() {
    return CalendarSettings(
      startWeekday: 0,
      backgroundColor: Colors.transparent,
      selectedDayColor: Colors.blue,
      todayColor: Colors.orange,
      dayTextColor: Colors.black,
      selectedDayTextColor: Colors.white,
    );
  }

  static String colorToHex(Color color) => '#${color.value.toRadixString(16).padLeft(8, '0')}';
  static Color hexToColor(String hex) => Color(int.parse(hex.replaceFirst('#', ''), radix: 16));

  static Future<CalendarSettings> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return CalendarSettings(
      startWeekday: prefs.getInt('calendar_start_weekday') ?? 0,
      backgroundColor: Colors.transparent,
      selectedDayColor: prefs.containsKey('calendar_selected_day_color')
          ? hexToColor(prefs.getString('calendar_selected_day_color')!)
          : Colors.blue,
      todayColor: prefs.containsKey('calendar_today_color')
          ? hexToColor(prefs.getString('calendar_today_color')!)
          : Colors.orange,
      dayTextColor: prefs.containsKey('calendar_day_text_color')
          ? hexToColor(prefs.getString('calendar_day_text_color')!)
          : Colors.black,
      selectedDayTextColor: prefs.containsKey('calendar_selected_day_text_color')
          ? hexToColor(prefs.getString('calendar_selected_day_text_color')!)
          : Colors.white,
    );
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendar_selected_day_color', colorToHex(selectedDayColor));
    await prefs.setString('calendar_today_color', colorToHex(todayColor));
    await prefs.setString('calendar_day_text_color', colorToHex(dayTextColor));
    await prefs.setString('calendar_selected_day_text_color', colorToHex(selectedDayTextColor));
    await prefs.setInt('calendar_start_weekday', startWeekday);
  }

  // ✅ اگر خواستی رنگی رو تغییر بدی و به‌روزرسانی انجام بشه:
  void updateSelectedDayColor(Color color) {
    selectedDayColor = color;
    notifyListeners();
  }

// بقیه متدهای تغییر رنگ هم می‌تونی اضافه کنی مشابه بالا
}
