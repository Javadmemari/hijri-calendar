import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SlowScrollPhysics extends ScrollPhysics {
  const SlowScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(parent: ancestor);
  }

  @override
  double get minFlingVelocity => super.minFlingVelocity * 7; // کاهش سرعت
  @override
  double get maxFlingVelocity => super.maxFlingVelocity * 0.1; // کاهش سرعت پرتابی
  @override
  double get dragStartDistanceMotionThreshold => 9.0; // حساسیت به لمس
}

class CustomContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final TextDirection textDirection;
  final double width;
  final double? height;
  final bool horizontalScroll;
  final bool verticalScroll;
  final bool noBackground;
  final double borderWidth;

  const CustomContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.margin,
    this.width = double.infinity,
    this.height,
    this.textDirection = TextDirection.rtl,
    this.horizontalScroll = false,
    this.verticalScroll = false,
    this.noBackground = false,
    this.borderWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = Theme.of(context).brightness == Brightness.dark
    ? const [Color(0xFF2C2C2C), Color(0xFF444444)]
    : const [Color(0xFFF2F2F2), Color(0xFFEAEAEA)];


    ScrollController scrollController = ScrollController(); // مقداردهی داخل build

    return Directionality(
      textDirection: textDirection,
      child: Container(
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: noBackground ? null : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
            width: borderWidth,
          ),
          boxShadow: noBackground
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: (verticalScroll || horizontalScroll)
            ? SingleChildScrollView(
          controller: scrollController,
          scrollDirection: horizontalScroll ? Axis.horizontal : Axis.vertical,
          physics: const SlowScrollPhysics(),
          child: child,
        )
            : child,
      ),
    );
  }
}
