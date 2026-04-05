import 'package:flutter/material.dart';
import 'package:calendar/components/calendar/constants.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.currentMonth,
    required this.onPreviousPress,
    required this.onNextPress,
  });

  final DateTime currentMonth;
  final VoidCallback onPreviousPress;
  final VoidCallback onNextPress;

  @override
  Widget build(BuildContext context) {
    final month = currentMonth.month;
    final year = currentMonth.year;
    final title = '${months[month - 1]} $year'.toUpperCase();
    final subtitle = 'Vuốt ngang để chuyển tháng';
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          _HeaderButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onPreviousPress,
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          _HeaderButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onNextPress,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.70)),
          ),
          child: Icon(icon, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}