import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final Color activeBgColor;
  final Color inactiveBgColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final FontWeight? activeFontWeight;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.margin,
    this.activeBgColor = const Color(0xffDBEAFE),
    this.inactiveBgColor = Colors.white,
    this.activeTextColor = const Color(0xff2563EB),
    this.inactiveTextColor = Colors.black87,
    this.borderColor = const Color(0xffCBD5E1),
    this.borderRadius = 30,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    this.activeFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(right: 10),
        padding: padding,
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : inactiveBgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? activeTextColor : inactiveTextColor,
            fontWeight: isActive ? activeFontWeight : null,
          ),
        ),
      ),
    );
  }
}
