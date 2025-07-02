import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:provider/provider.dart';
import '../classes/calendar_settings.dart';
import 'package:derham_accontancy/widgets/custom_container.dart';
import 'package:derham_accontancy/style/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_button.dart';
import '../classes/utils.dart';
import 'package:remixicon/remixicon.dart';
import 'package:derham_accontancy/services/holiday_service.dart';
import '../widgets/constants.dart';
import '../widgets/calendar_helpers.dart';

class ShamsiCalendarField extends StatefulWidget {
  final Function(Jalali)? onDateSelected;
  final Jalali? initialSelectedDate;

  const ShamsiCalendarField({
    super.key,
    this.initialSelectedDate,
    this.onDateSelected,
  });

  @override
  State<ShamsiCalendarField> createState() => _ShamsiCalendarFieldState();
}

class _ShamsiCalendarFieldState extends State<ShamsiCalendarField> {
  TextEditingController controller = TextEditingController();
  final holidayService = HolidayService();


  Future<Map<String, dynamic>?>? holidaysFuture;

  @override
  void initState() {
    super.initState();
    holidaysFuture = holidayService.getHolidays(Jalali.now().year);
  }

  Future<void> _openCalendar(BuildContext context) async {
    // final holidays = await _holidaysFuture;

    Jalali? selectedDate = await showDialog(
      context: context,
      builder: (context) => ShamsiCalendar(
        initialSelectedDate: widget.initialSelectedDate,
        formTextField:true,
        onDateSelected: (date) {
           Navigator.pop(context, date);
        },

      ),
    );
    if (selectedDate != null) {
      setState(() {
         controller.text = formatJalali(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCalendar(context),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'تاریخ',
            suffixIcon: Icon(RemixIcons.calendar_todo_line),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class ShamsiCalendar extends StatelessWidget {
  final Function(Jalali)? onDateSelected;
  final Jalali? initialSelectedDate;
  final Map<String, dynamic>? holidays;
  final bool formTextField;

  const ShamsiCalendar({
    Key? key,
    this.initialSelectedDate,
    this.onDateSelected,
    this.holidays,
    this.formTextField = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ShamsiCalendarWidget(
        onDateSelected: onDateSelected,
        initialSelectedDate: initialSelectedDate,
        year: Jalali.now().year,
        holidays: holidays,
        formTextField: formTextField,
      ),
    );
  }
}

class ShamsiCalendarWidget extends StatefulWidget {
  final Function(Jalali)? onDateSelected;
  final Jalali? initialSelectedDate;
  final int year;
  final Map<String, dynamic>? holidays;
  final bool formTextField;

  const ShamsiCalendarWidget({
    super.key,
    this.initialSelectedDate,
    this.onDateSelected,
    required this.year,
    this.holidays,
    this.formTextField = false,
  });

  @override
  ShamsiCalendarWidgetState createState() => ShamsiCalendarWidgetState();
}

class ShamsiCalendarWidgetState extends State<ShamsiCalendarWidget> {
  late Jalali focusedMonth;
  Jalali? selectedDay;
  bool hasNoHolidayData = false;
  Map<String, dynamic> holidays = {
  }; // اینجا می‌خواهیم تعطیلات و رویدادها را ذخیره کنیم
  final holidayService = HolidayService();
  int currentYear = Jalali.now().year; // ذخیره سال جاری

  @override
  void initState() {
    super.initState();
    focusedMonth = selectedDay = widget.initialSelectedDate ?? Jalali.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {}); // نمایش بخش انتخاب‌شده بلافاصله پس از اجرا
    });
    loadHolidays();
  }

  Future<void> loadHolidays([int? year]) async {
    // استفاده از currentYear به عنوان پیش‌فرض اگر year ارسال نشده باشد
    int loadYear = year ?? currentYear;

    setState(() {
      holidays = {};
      hasNoHolidayData = false; // پیش‌فرض
    });

    // ارسال loadYear به جای currentYear برای بارگذاری تعطیلات سال مشخص
    var holidaysData = await holidayService.getHolidays(loadYear);

    if (holidaysData == null || holidaysData.isEmpty) {
      setState(() {
        holidays = {};
        hasNoHolidayData = true; // تنظیم فلگ برای نمایش آیکون
      });
    } else {
      setState(() {
        holidays = holidaysData;
        hasNoHolidayData = false;
      });
    }
  }

  void _goToNextMonth() {
    setState(() {
      focusedMonth = focusedMonth.addMonths(1);
      if (focusedMonth.year != currentYear) {
        currentYear = focusedMonth.year; // سال تغییر کرده است
        loadHolidays(); // درخواست تعطیلات جدید برای سال جدید
      }
    });
  }
  void _goToPreviousMonth() {
    setState(() {
      focusedMonth = focusedMonth.addMonths(-1);
      if (focusedMonth.year != currentYear) {
        currentYear = focusedMonth.year; // سال تغییر کرده است
        loadHolidays();
      }
    });
  }
  void _selectToday() {
    final today = Jalali.now();

    setState(() {
      focusedMonth = Jalali(today.year, today.month, 1); // فقط به ماه و سال امروز برو
      selectedDay = today; // و روز امروز رو انتخاب کن
    });

    loadHolidays(today.year); // بارگذاری تعطیلات جدید پس از انتخاب امروز

    widget.onDateSelected?.call(today); // اختیاری: می‌خوای رویداد بفرستی به بیرون
  }

  bool _isHoliday(Jalali date) {
    String dateKey = '${date.month}/${date.day}';
    return holidays.containsKey(dateKey) &&
        holidays[dateKey]['holiday'] == true; // چک کردن تعطیلات
  }
  bool _hasEvent(Jalali date) {
    String dateKey = '${date.month}/${date.day}';
    return holidays.containsKey(dateKey) &&
        holidays[dateKey]['event'] != null &&
        holidays[dateKey]['event'].isNotEmpty; // چک کردن رویداد
  }
  bool _isToday(Jalali date) {
    final today = Jalali.now();
    return date.year == today.year && date.month == today.month &&
        date.day == today.day;
  }

  void _showMonthPickerDialog(BuildContext context) {
    showMonthPicker(
      context: context,
      currentYear: focusedMonth.year,
      onMonthSelected: (Jalali newMonth) {
        setState(() {
          focusedMonth = newMonth;
          loadHolidays(focusedMonth.year);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<CalendarSettings>(context);
    final orderedWeekDays = [
      ...shortWeekDays.sublist(settings.startWeekday),
      ...shortWeekDays.sublist(0, settings.startWeekday)
    ];

    final firstDayOfMonth = focusedMonth.withDay(1);
    final daysInMonth = focusedMonth.monthLength;
    final firstWeekDay = firstDayOfMonth.weekDay % 7;
    final adjustedWeekDay = firstWeekDay == 0 ? 6 : firstWeekDay - 1;
    String eventMessage = '';

    if (selectedDay != null) {
      String dateKey = '${selectedDay!.month}/${selectedDay!.day}';
      List<dynamic> events = holidays[dateKey]?['event'] ?? [];
      bool isholiday = holidays[dateKey]?['holiday'] ?? false;
      if (events.isNotEmpty) {
        if (isholiday) {
          eventMessage = 'رویدادها: ${events.join(', ')} - تعطیل';
        } else {
          eventMessage = 'رویدادها: ${events.join(', ')}';
        }
      } else {
        if (isholiday) {
          eventMessage = 'تعطیل';
        } else {
          eventMessage = '';
        }
      }
  }
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth > 360 ? 300 : constraints.maxWidth;
        double height = constraints.maxHeight > 360 ? 450 : constraints.maxHeight;
        double daySize = (width - 20) / 7;

        return CustomContainer(
          width: width,
          height: height,
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: _goToPreviousMonth, icon: const Icon(Icons.chevron_left)),
                  SizedBox(
                    width: 100,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showMonthPickerDialog(context),
                        child: Text(
                          monthNames[focusedMonth.month - 1],
                          style: AppStyles.inputTextStyle.copyWith(
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          showYearPickerDialog(
                            context: context,
                            currentYear: currentYear,
                            onYearSelected: (year) {
                              setState(() {
                                focusedMonth = focusedMonth.withYear(year);
                                currentYear = year;
                              });
                              loadHolidays(); // بارگذاری تعطیلات
                            },
                          );
                        },
                        child: Text(
                          convertToPersianNumber(focusedMonth.year.toString()),
                          style: AppStyles.inputTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                  IconButton(onPressed: _goToNextMonth, icon: const Icon(Icons.chevron_right)),
                ],
              ),
              const SizedBox(height: 2),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 240,
                  maxHeight: 240,
                ),
                child:
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1000),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.1, 0), // از راست به چپ
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: GridView.builder(
                      key: ValueKey(focusedMonth.toString()),
                      itemCount: 7 + daysInMonth + adjustedWeekDay,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index < 7) {
                          return Container(
                            decoration: BoxDecoration(
                              color: settings.selectedDayColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade400, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              orderedWeekDays[index],
                              style: AppStyles.labelTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: settings.selectedDayTextColor,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          );
                        } else if (index < 7 + adjustedWeekDay) {
                          return const SizedBox.shrink();
                        } else {
                          final day = index - 7 - adjustedWeekDay + 1;
                          final jDate = focusedMonth.withDay(day);
                          final isSelected = selectedDay?.toString() == jDate.toString();
                          final isToday = _isToday(jDate);
                          final isHoliday = _isHoliday(jDate);

                          return GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity != null) {
                                if (details.primaryVelocity! < 0) {
                                  _goToNextMonth();
                                } else if (details.primaryVelocity! > 0) {
                                  _goToPreviousMonth();
                                }
                              }
                            },
                            onTap: () {
                              setState(() => selectedDay = jDate);
                            },
                            onDoubleTap: () {
                              widget.onDateSelected?.call(jDate);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? settings.selectedDayColor
                                    : (isToday
                                    ? settings.todayColor
                                    : (isHoliday
                                    ? Colors.redAccent
                                    : settings.backgroundColor)),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey.shade400, width: 0.2),
                              ),
                              child: Stack(
                                children: [
                                  // تاریخ قمری بالا چپ
                                  Positioned(
                                    top: 1,
                                    left: 1,
                                    child: Builder(
                                      builder: (context) {
                                        final key = '${jDate.month}/${jDate.day}';
                                        final data = holidays[key];
                                        final moon = data?['moon'];
                                        return moon != null
                                            ? Text(
                                          convertToPersianNumber(moon['day'].toString()),
                                          style: AppStyles.inputTextStyle.copyWith(fontSize: 7,color: Colors.green),
                                        )
                                            : const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  // تاریخ میلادی پایین چپ
                                  Positioned(
                                    bottom: 1,
                                    left: 1,
                                    child: Builder(
                                      builder: (context) {
                                        final key = '${jDate.month}/${jDate.day}';
                                        final data = holidays[key];
                                        final gregorian = data?['gregorian'];
                                        return gregorian != null
                                            ? Text(
                                          convertToPersianNumber(gregorian['day'].toString()),
                                          style: AppStyles.inputTextStyle.copyWith(fontSize: 7,color: Colors.yellow),
                                        )
                                            : const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  // روز شمسی وسط
                                  Center(
                                    child: Text(
                                      convertToPersianNumber(day.toString()),
                                      style: AppStyles.labelTextStyle.copyWith(
                                        fontSize: daySize * 0.3,
                                        color: isSelected || isToday || isHoliday
                                            ? settings.selectedDayTextColor
                                            : settings.dayTextColor,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),
          Expanded(
            child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: selectedDay != null
                ? CustomContainer(
              key: ValueKey(selectedDay.toString()),
              margin: const EdgeInsets.all(4),
                    child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'انتخاب‌شده: ${getFullSelectedDateString(selectedDay!, holidays)}',
                      style: AppStyles.inputTextStyle.copyWith(fontWeight: FontWeight.w300),
                    ),

                    const SizedBox(height: 6),
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomButton(
                            backgroundColor: Theme
                                .of(context)
                                .brightness == Brightness.dark
                                ? const Color(0xFFBB86FA)
                                : const Color(0xFF578E98),
                            hoverColor: Theme
                                .of(context)
                                .brightness == Brightness.dark
                                ? const Color(0xFFe0c7ff)
                                : const Color(0xFFA4D1D9),
                            pressedColor: Theme
                                .of(context)
                                .brightness == Brightness.dark
                                ? const Color(0xFFe0c7ff)
                                : const Color(0xFFA4D1D9),
                            textColor: Theme
                                .of(context)
                                .brightness == Brightness.dark
                                ? const Color(0xFF212121)
                                : const Color(0xFFEDEDED),
                            width: MediaQuery.of(context).size.width>600?120.0: 0.3 * MediaQuery.of(context).size.width,
                            height: 25,
                            text: 'امروز',
                            icon: (FontAwesomeIcons.solidCalendarDays),
                            onPressed: _selectToday,
                          ),
                          const SizedBox(height: 15),
                          if(widget.formTextField)
                            CustomButton(
                              backgroundColor: Theme
                                  .of(context)
                                  .brightness == Brightness.dark
                                  ? const Color(0xFFBB86FA)
                                  : const Color(0xFF578E98),
                              hoverColor: Theme
                                  .of(context)
                                  .brightness == Brightness.dark
                                  ? const Color(0xFFe0c7ff)
                                  : const Color(0xFFA4D1D9),
                              pressedColor: Theme
                                  .of(context)
                                  .brightness == Brightness.dark
                                  ? const Color(0xFFe0c7ff)
                                  : const Color(0xFFA4D1D9),
                              textColor: Theme
                                  .of(context)
                                  .brightness == Brightness.dark
                                  ? const Color(0xFF212121)
                                  : const Color(0xFFEDEDED),
                              width: MediaQuery.of(context).size.width>600?120.0: 0.3 * MediaQuery.of(context).size.width,
                              height: 25,
                              text: 'تأیید تاریخ',
                              icon: RemixIcons.checkbox_circle_line,
                              onPressed: () {
                                if (selectedDay != null) {
                                  widget.onDateSelected?.call(selectedDay!);
                                }
                              },
                            ),
                        ],
                      ),

                    const SizedBox(height: 6,),

                    if (_hasEvent(selectedDay!)||_isHoliday(selectedDay!))
                      Expanded(
                          child: CustomContainer(
                        height: 53,
                        verticalScroll: true,
                        child: Text(eventMessage,style: AppStyles.labelTextStyle.copyWith(fontSize: 10,fontWeight: FontWeight.w300)),
                      ),
                      ),
              if (hasNoHolidayData)
                Padding(
                  padding: const EdgeInsets.all(8.0),

                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('.برای دیدن رویدادها باید به اینترنت وصل باشید',style: AppStyles.labelTextStyle,selectionColor: Colors.redAccent,),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ),


                  ],
                ),
                )
                  : const SizedBox.shrink(), // اگه چیزی انتخاب نشده
        ),
            ),
            ],
          ),
        );
      },
    );
  }
}

