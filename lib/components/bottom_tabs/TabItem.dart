import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  TabItem({this.title, this.image, this.isSelected, this.onPress});
  final bool isSelected;
  final String title;
  final String image;
  final Function onPress;
  var unSelectColor = Colors.white30;
  var selectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var iconColor = isSelected ? selectedColor : unSelectColor;
    var textStyle = TextStyle(
      color: isSelected ? selectedColor : unSelectColor,
      fontSize: 12
    );
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(image), width: 30, height: 30, color: iconColor,),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(title, style: textStyle),
            )
          ],
        ),
      ),
    );
  }

}