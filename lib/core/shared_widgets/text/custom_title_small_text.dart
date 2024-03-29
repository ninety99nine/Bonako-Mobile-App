import 'package:flutter/material.dart';

class CustomTitleSmallText extends StatelessWidget {
  
  final String text;
  final Color? color;
  final int? maxLines;
  final TextStyle? style;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final TextOverflow? overflow;

  const CustomTitleSmallText(this.text, {
    super.key,
    this.color,
    this.style,
    this.margin,
    this.padding,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: color,
        ).merge(style)
      ),
    );
  }
}