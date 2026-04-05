import 'package:flutter/material.dart';
import 'tab_item.dart';
import 'tab_item_data.dart';

class BottomTab extends StatelessWidget {
  const BottomTab({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTabTapped,
  });

  final List<TabItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  @override
  Widget build(BuildContext context) {
    final children = items
        .map(
          (item) => TabItem(
            title: item.title,
            image: item.image,
            isSelected: item.index == currentIndex,
            onPress: () => onTabTapped(item.index),
          ),
        )
        .toList(growable: false);

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      height: 74,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: children),
      ),
    );
  }
}