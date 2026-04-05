import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.title,
    required this.image,
    required this.isSelected,
    required this.onPress,
  });

  final bool isSelected;
  final String title;
  final String image;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? Colors.white : Colors.white54;
    final textStyle = TextStyle(
      color: iconColor,
      fontSize: 12,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
    );

    return Expanded(
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(image, width: 26, height: 26, color: iconColor),
            const SizedBox(height: 4),
            Text(title, style: textStyle),
          ],
        ),
      ),
    );
  }
}