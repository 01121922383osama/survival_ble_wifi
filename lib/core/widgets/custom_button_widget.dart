import 'package:flutter/material.dart';
import 'package:survival/core/extension/screen_utils.dart';

class CustomIconButton extends StatelessWidget {
  final String textButton;
  final void Function() onPressed;
  final Color? color;
  final double? width;
  final double? height;
  final Widget? widget;
  const CustomIconButton({
    super.key,
    this.textButton = '',
    required this.onPressed,
    this.color,
    this.width,
    this.height,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        backgroundColor: color,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.center,
        minimumSize: Size(width ?? context.width * 0.7, height ?? 50),
      ),
      onPressed: onPressed,
      child:
          widget ??
          Text(
            textButton,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
    );
  }
}
