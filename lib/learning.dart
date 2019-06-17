import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class Learning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return   MaterialApp(
      title: 'Flutter Demo',
      home: PageView.builder(
        itemBuilder: (context, position) {
          return Container(
            color: position % 2 == 0 ? Colors.pink : Colors.cyan,
            child: Text(
              position.toString()
            ),
          );
        },
      )
    );
  }
}
