import 'package:calendar/model/EventVO.dart';
import 'package:calendar/utils/date_utils.dart';
import 'package:calendar/utils/lunar_solar_utils.dart';
import 'package:flutter/material.dart';

class EventItem extends StatelessWidget {
  const EventItem({super.key, required this.event});

  final EventVO event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool darkSurface = Theme.of(context).brightness == Brightness.dark;
    final dayOfWeek = getNameDayOfWeek(event.date);
    final lunarDates = convertSolar2Lunar(event.date.day, event.date.month, event.date.year, 7);
    final lunarDay = lunarDates[0];
    final lunarMonth = lunarDates[1];
    final title = '$dayOfWeek • ${event.date.day}/${event.date.month}';
    final subtitle = 'Âm lịch $lunarDay/$lunarMonth';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: darkSurface ? Colors.white.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkSurface ? Colors.white.withValues(alpha: 0.10) : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2B6CF6).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.event_available_rounded,
                color: darkSurface ? Colors.white : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.event,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
