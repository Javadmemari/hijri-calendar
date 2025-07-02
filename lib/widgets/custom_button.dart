import 'package:flutter/material.dart';
import 'dart:io';

class CustomButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? pressedColor;
  final Color? textColor;
  final bool iconRight;
  final double width;
  final double height;
  final double sizeIcon;
  final double fontSize;
  final Axis iconPosition;
  final bool isPrimary; // تعیین نوع دکمه (اصلی یا ثانویه)

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.hoverColor,
    this.pressedColor,
    this.textColor,
    this.iconRight = false,
    this.width = 80,
    this.height = 40,
    this.sizeIcon = 12,
    this.fontSize = 14,
    this.iconPosition = Axis.horizontal,
    this.isPrimary = true, // پیش‌فرض دکمه اصلی
  }) : super(key: key);

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: Container(
          width: widget.width,
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.iconPosition == Axis.vertical
              ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: getTextColor(),size: widget.sizeIcon),
              const SizedBox(height: 4),
              Text(widget.text,
                  style: TextStyle(
                    color: getTextColor(),
                    fontSize: widget.fontSize,
                    fontFamily: 'Kalame',
                    fontWeight: FontWeight.w700,
                  )),
            ],
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.iconRight
                ? [
              Text(widget.text,
                  style: TextStyle(
                    color: getTextColor(),
                    fontSize: widget.fontSize,
                    fontFamily: 'Kalame',
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(width: 8),
              Icon(widget.icon, color: getTextColor(),size: widget.sizeIcon),
            ]
                : [
              Icon(widget.icon, color: getTextColor(),size: widget.sizeIcon),
              const SizedBox(width: 8),
              Text(widget.text,
                  style: TextStyle(
                    color: getTextColor(),
                    fontSize: widget.fontSize,
                    fontFamily: 'Kalame',
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Color getBackgroundColor() {
    Color defaultColor = widget.isPrimary
        ? (Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFBB86FA)
        : const Color(0xFF578E98))
        : (Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1DE1CD)
        : const Color(0xFF7d7d7d));

    Color baseColor = widget.backgroundColor ?? defaultColor;

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return _isHovered ? (widget.hoverColor ?? baseColor) : baseColor;
    } else {
      return _isPressed ? (widget.pressedColor ?? baseColor) : baseColor;
    }
  }

  Color getHoverColor() {
    if (widget.hoverColor != null) return widget.hoverColor!;
    return widget.isPrimary
        ? (Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFe0c7ff)
        : const Color(0xFFA4D1D9))
        : (Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF26fbe6)
        : const Color(0xFFc3c3c3));
  }

  Color getPressedColor() {
    if (widget.pressedColor != null) return widget.pressedColor!;
    return getHoverColor();
  }

  Color getTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF212121)
        : const Color(0xFFEDEDED);
  }
}
