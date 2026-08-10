import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.pistachio;
    final fgColor = textColor ?? AppColors.white;

    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              color: isOutlined ? bgColor : fgColor,
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: isOutlined ? bgColor : fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isOutlined ? bgColor : fgColor,
                ),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: height ?? 56,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bgColor, width: 2.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: child,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: height ?? 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                    color: Color.lerp(bgColor, Colors.black, 0.24)!,
                    offset: const Offset(0, 5))
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              onPressed == null ? AppColors.buttonDisabled : bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: child,
      ),
    );
  }
}
