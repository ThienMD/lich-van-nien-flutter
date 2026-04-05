import 'package:flutter/material.dart';

class SelectDateButton extends StatelessWidget {
  const SelectDateButton({
    super.key,
    required this.title,
    required this.onPress,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
  });

  final String title;
  final VoidCallback onPress;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedForeground = foregroundColor ?? colorScheme.onSurface;
    final resolvedBackground = backgroundColor ?? colorScheme.surfaceContainerHighest;
    final resolvedBorder = borderColor ?? colorScheme.outlineVariant;

    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: resolvedForeground,
          fontWeight: FontWeight.w700,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: resolvedBackground,
            border: Border.all(color: resolvedBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title, style: textStyle),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, size: 24, color: resolvedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
