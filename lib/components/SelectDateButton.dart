import 'package:flutter/material.dart';

class SelectDateButton extends StatelessWidget {
  SelectDateButton({this.title, this.onPress});

  final String title;
  final Function onPress;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var textStyle = TextStyle(
      color: Colors.white,
      fontSize: 17,fontWeight: FontWeight.bold
    );
    return GestureDetector(
      onTap: (){
        onPress();
      },
      child: Container(
        height: 40,
        width: 190,
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: new Border.all(
              color: Colors.white,
              width: 1.0,
              style: BorderStyle.solid
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text(title, style: textStyle)),
            Icon(Icons.arrow_drop_down, size: 30, color: Colors.white,)

          ],
        ),
      ),
    );
  }
}
