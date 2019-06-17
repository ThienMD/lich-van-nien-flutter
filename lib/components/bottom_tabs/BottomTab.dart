import 'package:flutter/material.dart';
import 'TabItemData.dart';
import 'TabItem.dart';
class BottomTab extends StatelessWidget {
  @required BottomTab({this.items, this.currentIndex, this.onTabTapped});
  final List<TabItemData>items;
  final int currentIndex;
  final Function onTabTapped;
  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List();
     items.forEach((item) {
      var tabItem = TabItem(
        title: item.title,
        image: item.image,
        isSelected: item.index == currentIndex,
        onPress: (){
          onTabTapped(item.index);
        },
      );
       children.add(tabItem);
    });
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5)
        ),
        child: Row(
          children: children
        ),
      ),
    );
  }
}