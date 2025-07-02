import 'dart:async';
import 'dart:convert';
import 'dart:io';  // برای استفاده از File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';  // برای پیدا کردن مسیر ذخیره‌سازی
import 'package:connectivity_plus/connectivity_plus.dart';
class HolidayService {
  Future<bool> _isConnectedToInternet() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // print('No internet connection');
        return false;
      }
      // در اینجا به صورت پرینت وضعیت اتصال اینترنت رو نشون می‌دهیم
      // print('Connected to the internet');
      return true;
    } catch (e) {
      // print('Error checking connectivity: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getHolidays(int year) async {
    final url = Uri.parse('https://pnldev.com/api/calender?year=$year');

    try {
      // ابتدا چک می‌کنیم که آیا فایل ذخیره شده برای سال مورد نظر وجود دارد یا نه
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/holidays_$year.json';
      final file = File(filePath);

      if (await file.exists()) {
        // اگر فایل وجود داشت، داده‌ها را از فایل می‌خوانیم
        final fileContent = await file.readAsString();

        // بررسی صحت داده‌ها
        try {
          final Map<String, dynamic> json = jsonDecode(fileContent);

          // بررسی صحت ساختار داده‌ها (وجود 'status' و 'result')
          if (json['status'] == true && json['result'] != null) {
            return _parseHolidays(json['result']);  // پردازش داده‌ها
          } else {
            debugPrint('Error: Invalid status or missing result in file.');
            // فایل ذخیره شده غیرقابل استفاده است پس باید از اینترنت بارگذاری کنیم
            return await _fetchAndSaveHolidays(year, url);
          }
        } catch (e) {
          debugPrint('Error decoding JSON from file: $e');
          // در صورتی که مشکل در پردازش داده‌ها باشد، دوباره داده‌ها را از API می‌گیریم
          return await _fetchAndSaveHolidays(year, url);
        }
      } else {
        // اگر فایل وجود نداشت یا مشکلی در خواندن آن بود، از API داده‌ها را می‌گیریم
        return await _fetchAndSaveHolidays(year, url);
      }
    } catch (e) {
      debugPrint('Error loading holidays: $e');
      // print('❌ داده‌ها قابل بارگذاری نیستند.');
    }

    return null;
  }



  // تابعی برای درخواست از API و ذخیره داده‌ها در فایل
  Future<Map<String, dynamic>?> _fetchAndSaveHolidays(int year, Uri url) async {
    try {
      bool isConnected = await _isConnectedToInternet();
      if (!isConnected) {
        // print('📴 اینترنت قطع است. لطفاً اتصال اینترنت خود را بررسی کنید.');
        return null;
      }

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json['status'] == true && json['result'] != null) {
          final result = json['result'] as Map<String, dynamic>;
          await _saveFile(year, response.body);
          return _parseHolidays(result);
        }
      } else {
        // print('⚠️ خطا در دریافت داده‌ها از سرور. کد وضعیت: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ خطا هنگام دریافت تعطیلات: $e');
    }

    // print('❌ داده‌ای دریافت نشد یا اتصال با مشکل مواجه شد.');
    return null;
  }


  // تابعی برای پردازش داده‌ها و استخراج تعطیلات و رویدادها
  Map<String, dynamic> _parseHolidays(Map<String, dynamic> result) {
    Map<String, dynamic> holidays = {};
    result.forEach((month, daysMap) {
      (daysMap as Map<String, dynamic>).forEach((day, value) {
        if (value['holiday'] == true || value['event'] != null) {
          final key = '$month/$day';
          holidays[key] = value;
        }
      });
    });
    return holidays;
  }

  // تابعی برای ذخیره‌سازی فایل
  Future<void> _saveFile(int year, String data) async {
    try {
      // گرفتن مسیر ذخیره‌سازی
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/holidays_$year.json';

      // ایجاد فایل و نوشتن داده‌ها در آن
      final file = File(filePath);
      await file.writeAsString(data);

      debugPrint('File saved at: $filePath');
    } catch (e) {
      debugPrint('Error saving file: $e');
    }
  }
}
